import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/job.dart';
import '../models/service_category.dart';
import 'firebase_sync_service.dart';
import 'firebase_config.dart';

class JobService {
  static final JobService _instance = JobService._internal();
  factory JobService() => _instance;
  JobService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseSyncService _syncService = FirebaseSyncService();
  final ImagePicker _imagePicker = ImagePicker();

  // Créer un nouveau job
  Future<String> createJob({
    required String userId,
    required String userFirstName,
    required String userLastName,
    String? userImageUrl,
    String? userPhoneNumber,
    required String title,
    required String description,
    required String category,
    required double budget,
    required DateTime deadline,
    required double latitude,
    required double longitude,
    required String address,
    List<File> images = const [],
    List<File> videos = const [],
    JobPriority priority = JobPriority.medium,
    bool isUrgent = false,
    Map<String, dynamic> requirements = const {},
    List<String> tags = const [],
    String language = 'fr',
  }) async {
    try {
      // Valider les données
      _validateJobData(
        title: title,
        description: description,
        budget: budget,
        deadline: deadline,
        images: images,
        videos: videos,
      );

      // Upload des médias
      List<String> imageUrls = await _uploadImages(images, userId);
      List<String> videoUrls = await _uploadVideos(videos, userId);

      // Créer le job via le service de synchronisation
      Map<String, dynamic> jobData = {
        'userId': userId,
        'userFirstName': userFirstName,
        'userLastName': userLastName,
        'userImageUrl': userImageUrl,
        'userPhoneNumber': userPhoneNumber,
        'title': title,
        'description': description,
        'category': category,
        'images': imageUrls,
        'videos': videoUrls,
        'location': GeoPoint(latitude, longitude),
        'address': address,
        'budget': budget,
        'currency': 'DZD',
        'deadline': deadline,
        'priority': priority.toString().split('.').last,
        'isUrgent': isUrgent,
        'requirements': requirements,
        'language': language,
        'tags': tags,
        'metadata': FirebaseConfig.defaultMetadata,
      };

      String jobId = await _syncService.createJob(jobData);
      return jobId;
    } catch (e) {
      throw JobException('Erreur lors de la création du job: $e');
    }
  }

  // Obtenir tous les jobs d'un utilisateur
  Stream<List<Job>> getUserJobs(String userId) {
    return _firestore
        .collection(FirebaseConfig.jobsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Job.fromFirestore(doc))
            .toList());
  }

  // Obtenir un job par ID
  Future<Job?> getJobById(String jobId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(FirebaseConfig.jobsCollection)
          .doc(jobId)
          .get();

      if (doc.exists) {
        return Job.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw JobException('Erreur lors de la récupération du job: $e');
    }
  }

  // Mettre à jour un job
  Future<void> updateJob(String jobId, Map<String, dynamic> updates) async {
    try {
      // Vérifier que seuls les champs autorisés peuvent être modifiés
      Map<String, dynamic> allowedUpdates = {
        'title': updates['title'],
        'description': updates['description'],
        'budget': updates['budget'],
        'deadline': updates['deadline'],
        'priority': updates['priority'],
        'isUrgent': updates['isUrgent'],
        'requirements': updates['requirements'],
        'tags': updates['tags'],
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Nettoyer les valeurs null
      allowedUpdates.removeWhere((key, value) => value == null);

      await _firestore
          .collection(FirebaseConfig.jobsCollection)
          .doc(jobId)
          .update(allowedUpdates);
    } catch (e) {
      throw JobException('Erreur lors de la mise à jour du job: $e');
    }
  }

  // Annuler un job
  Future<void> cancelJob(String jobId, String userId) async {
    try {
      // Vérifier que l'utilisateur est bien le propriétaire du job
      DocumentSnapshot jobDoc = await _firestore
          .collection(FirebaseConfig.jobsCollection)
          .doc(jobId)
          .get();

      if (!jobDoc.exists) {
        throw JobException('Job introuvable');
      }

      Job job = Job.fromFirestore(jobDoc);
      if (job.userId != userId) {
        throw JobException('Vous n\'êtes pas autorisé à annuler ce job');
      }

      if (job.status != JobStatus.pending) {
        throw JobException('Ce job ne peut plus être annulé');
      }

      // Annuler le job
      await _firestore
          .collection(FirebaseConfig.jobsCollection)
          .doc(jobId)
          .update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Mettre à jour la demande de travail correspondante
      await _updateJobRequestStatus(jobId, 'cancelled');

      // Notifier le travailleur si le job était accepté
      if (job.acceptedByWorkerId != null) {
        await _notifyWorkerJobCancelled(jobId, job.acceptedByWorkerId!);
      }
    } catch (e) {
      throw JobException('Erreur lors de l\'annulation du job: $e');
    }
  }

  // Évaluer un travailleur après completion
  Future<void> rateWorker(String jobId, String userId, double rating, String comment) async {
    try {
      // Vérifier que l'utilisateur est bien le propriétaire du job
      DocumentSnapshot jobDoc = await _firestore
          .collection(FirebaseConfig.jobsCollection)
          .doc(jobId)
          .get();

      if (!jobDoc.exists) {
        throw JobException('Job introuvable');
      }

      Job job = Job.fromFirestore(jobDoc);
      if (job.userId != userId) {
        throw JobException('Vous n\'êtes pas autorisé à évaluer ce job');
      }

      if (job.status != JobStatus.completed) {
        throw JobException('Ce job doit être terminé pour être évalué');
      }

      if (job.userRating != null) {
        throw JobException('Ce job a déjà été évalué');
      }

      // Mettre à jour le job avec l'évaluation
      await _firestore
          .collection(FirebaseConfig.jobsCollection)
          .doc(jobId)
          .update({
        'userRating': rating,
        'userComment': comment,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Mettre à jour la note du travailleur
      if (job.acceptedByWorkerId != null) {
        await _updateWorkerRating(job.acceptedByWorkerId!, rating, comment);
      }
    } catch (e) {
      throw JobException('Erreur lors de l\'évaluation: $e');
    }
  }

  // Ajouter des images à un job existant
  Future<void> addImagesToJob(String jobId, String userId, List<File> images) async {
    try {
      // Vérifier les permissions
      await _verifyJobOwnership(jobId, userId);

      // Upload des nouvelles images
      List<String> newImageUrls = await _uploadImages(images, userId);

      // Ajouter les nouvelles images aux existantes
      DocumentSnapshot jobDoc = await _firestore
          .collection(FirebaseConfig.jobsCollection)
          .doc(jobId)
          .get();

      if (jobDoc.exists) {
        Job job = Job.fromFirestore(jobDoc);
        List<String> allImages = [...job.images, ...newImageUrls];

        // Vérifier la limite d'images
        if (allImages.length > FirebaseConfig.maxImagesPerJob) {
          throw JobException('Limite d\'images dépassée');
        }

        await _firestore
            .collection(FirebaseConfig.jobsCollection)
            .doc(jobId)
            .update({
          'images': allImages,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw JobException('Erreur lors de l\'ajout d\'images: $e');
    }
  }

  // Rechercher des jobs par catégorie et localisation
  Stream<List<Job>> searchJobs({
    String? category,
    double? latitude,
    double? longitude,
    double? maxDistance,
    double? minBudget,
    double? maxBudget,
    List<String>? tags,
  }) {
    Query query = _firestore.collection(FirebaseConfig.jobsCollection);

    // Filtrer par catégorie
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    // Filtrer par budget
    if (minBudget != null) {
      query = query.where('budget', isGreaterThanOrEqualTo: minBudget);
    }
    if (maxBudget != null) {
      query = query.where('budget', isLessThanOrEqualTo: maxBudget);
    }

    // Filtrer par statut actif
    query = query.where('status', whereIn: ['pending', 'accepted']);

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      List<Job> jobs = snapshot.docs
          .map((doc) => Job.fromFirestore(doc))
          .toList();

      // Filtrer par distance si spécifiée
      if (latitude != null && longitude != null && maxDistance != null) {
        LatLng userLocation = LatLng(latitude, longitude);
        jobs = jobs.where((job) {
          double distance = job.calculateDistance(userLocation);
          return distance <= maxDistance;
        }).toList();
      }

      // Filtrer par tags si spécifiés
      if (tags != null && tags.isNotEmpty) {
        jobs = jobs.where((job) {
          return tags.any((tag) => job.tags.contains(tag));
        }).toList();
      }

      return jobs;
    });
  }

  // Obtenir les statistiques des jobs d'un utilisateur
  Future<Map<String, dynamic>> getUserJobStats(String userId) async {
    try {
      QuerySnapshot jobsSnapshot = await _firestore
          .collection(FirebaseConfig.jobsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      List<Job> jobs = jobsSnapshot.docs
          .map((doc) => Job.fromFirestore(doc))
          .toList();

      int totalJobs = jobs.length;
      int pendingJobs = jobs.where((job) => job.status == JobStatus.pending).length;
      int acceptedJobs = jobs.where((job) => job.status == JobStatus.accepted).length;
      int completedJobs = jobs.where((job) => job.status == JobStatus.completed).length;
      int cancelledJobs = jobs.where((job) => job.status == JobStatus.cancelled).length;

      double totalSpent = jobs
          .where((job) => job.finalPrice != null)
          .fold(0.0, (sum, job) => sum + (job.finalPrice ?? 0.0));

      return {
        'totalJobs': totalJobs,
        'pendingJobs': pendingJobs,
        'acceptedJobs': acceptedJobs,
        'completedJobs': completedJobs,
        'cancelledJobs': cancelledJobs,
        'totalSpent': totalSpent,
        'successRate': totalJobs > 0 ? (completedJobs / totalJobs) * 100 : 0.0,
      };
    } catch (e) {
      throw JobException('Erreur lors de la récupération des statistiques: $e');
    }
  }

  // Upload des images
  Future<List<String>> _uploadImages(List<File> images, String userId) async {
    List<String> imageUrls = [];
    
    for (int i = 0; i < images.length; i++) {
      try {
        String fileName = 'job_images/$userId/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        Reference ref = _storage.ref().child(fileName);
        
        UploadTask uploadTask = ref.putFile(images[i]);
        TaskSnapshot snapshot = await uploadTask;
        
        String downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      } catch (e) {
        print('Erreur lors de l\'upload de l\'image $i: $e');
      }
    }
    
    return imageUrls;
  }

  // Upload des vidéos
  Future<List<String>> _uploadVideos(List<File> videos, String userId) async {
    List<String> videoUrls = [];
    
    for (int i = 0; i < videos.length; i++) {
      try {
        String fileName = 'job_videos/$userId/${DateTime.now().millisecondsSinceEpoch}_$i.mp4';
        Reference ref = _storage.ref().child(fileName);
        
        UploadTask uploadTask = ref.putFile(videos[i]);
        TaskSnapshot snapshot = await uploadTask;
        
        String downloadUrl = await snapshot.ref.getDownloadURL();
        videoUrls.add(downloadUrl);
      } catch (e) {
        print('Erreur lors de l\'upload de la vidéo $i: $e');
      }
    }
    
    return videoUrls;
  }

  // Validation des données du job
  void _validateJobData({
    required String title,
    required String description,
    required double budget,
    required DateTime deadline,
    required List<File> images,
    required List<File> videos,
  }) {
    if (title.trim().isEmpty) {
      throw JobException('Le titre est requis');
    }
    if (title.length < 10) {
      throw JobException('Le titre doit contenir au moins 10 caractères');
    }
    if (description.trim().isEmpty) {
      throw JobException('La description est requise');
    }
    if (description.length < 20) {
      throw JobException('La description doit contenir au moins 20 caractères');
    }
    if (budget <= 0) {
      throw JobException('Le budget doit être supérieur à 0');
    }
    if (deadline.isBefore(DateTime.now())) {
      throw JobException('La date limite ne peut pas être dans le passé');
    }
    if (images.length > FirebaseConfig.maxImagesPerJob) {
      throw JobException('Trop d\'images (max: ${FirebaseConfig.maxImagesPerJob})');
    }
    if (videos.length > FirebaseConfig.maxVideosPerJob) {
      throw JobException('Trop de vidéos (max: ${FirebaseConfig.maxVideosPerJob})');
    }
  }

  // Vérifier la propriété du job
  Future<void> _verifyJobOwnership(String jobId, String userId) async {
    DocumentSnapshot jobDoc = await _firestore
        .collection(FirebaseConfig.jobsCollection)
        .doc(jobId)
        .get();

    if (!jobDoc.exists) {
      throw JobException('Job introuvable');
    }

    Job job = Job.fromFirestore(jobDoc);
    if (job.userId != userId) {
      throw JobException('Vous n\'êtes pas autorisé à modifier ce job');
    }
  }

  // Mettre à jour le statut de la demande de travail
  Future<void> _updateJobRequestStatus(String jobId, String status) async {
    try {
      QuerySnapshot requests = await _firestore
          .collection(FirebaseConfig.jobRequestsCollection)
          .where('jobId', isEqualTo: jobId)
          .get();

      if (requests.docs.isNotEmpty) {
        await requests.docs.first.reference.update({'status': status});
      }
    } catch (e) {
      print('Erreur lors de la mise à jour de la demande de travail: $e');
    }
  }

  // Notifier le travailleur de l'annulation
  Future<void> _notifyWorkerJobCancelled(String jobId, String workerId) async {
    try {
      await _firestore
          .collection(FirebaseConfig.notificationsCollection)
          .add({
        'userId': workerId,
        'type': 'jobCancelled',
        'title': 'Job annulé',
        'body': 'Un utilisateur a annulé le job que vous aviez accepté',
        'data': {'jobId': jobId},
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur lors de la notification du travailleur: $e');
    }
  }

  // Mettre à jour la note du travailleur
  Future<void> _updateWorkerRating(String workerId, double rating, String comment) async {
    try {
      DocumentSnapshot workerDoc = await _firestore
          .collection(FirebaseConfig.workersCollection)
          .doc(workerId)
          .get();

      if (workerDoc.exists) {
        Map<String, dynamic> workerData = workerDoc.data() as Map<String, dynamic>;
        double currentRating = (workerData['rating'] ?? 0.0).toDouble();
        int totalReviews = workerData['totalReviews'] ?? 0;

        double newRating = ((currentRating * totalReviews) + rating) / (totalReviews + 1);

        await _firestore
            .collection(FirebaseConfig.workersCollection)
            .doc(workerId)
            .update({
          'rating': newRating,
          'totalReviews': totalReviews + 1,
        });
      }
    } catch (e) {
      print('Erreur lors de la mise à jour de la note du travailleur: $e');
    }
  }

  // Obtenir les catégories de services
  Stream<List<ServiceCategory>> getServiceCategories() {
    return _firestore
        .collection(FirebaseConfig.serviceCategoriesCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceCategory.fromFirestore(doc))
            .toList());
  }

  // Obtenir une catégorie par ID
  Future<ServiceCategory?> getServiceCategoryById(String categoryId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(FirebaseConfig.serviceCategoriesCollection)
          .doc(categoryId)
          .get();

      if (doc.exists) {
        return ServiceCategory.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw JobException('Erreur lors de la récupération de la catégorie: $e');
    }
  }
}

// Exception personnalisée pour les jobs
class JobException implements Exception {
  final String message;
  JobException(this.message);

  @override
  String toString() => 'JobException: $message';
}