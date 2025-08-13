import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/worker.dart';
import '../models/service_category.dart';
import 'firebase_config.dart';

class WorkerService {
  static final WorkerService _instance = WorkerService._internal();
  factory WorkerService() => _instance;
  WorkerService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtenir tous les travailleurs disponibles
  Stream<List<Worker>> getAvailableWorkers({
    String? category,
    double? latitude,
    double? longitude,
    double? maxDistance,
    double? minRating,
    List<String>? services,
  }) {
    Query query = _firestore
        .collection(FirebaseConfig.workersCollection)
        .where('status', isEqualTo: 'verified')
        .where('isOnline', isEqualTo: true);

    // Filtrer par catégorie de service
    if (category != null) {
      query = query.where('services', arrayContains: category);
    }

    // Filtrer par services spécifiques
    if (services != null && services.isNotEmpty) {
      query = query.where('services', arrayContainsAny: services);
    }

    // Filtrer par note minimale
    if (minRating != null) {
      query = query.where('rating', isGreaterThanOrEqualTo: minRating);
    }

    return query
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) {
      List<Worker> workers = snapshot.docs
          .map((doc) => Worker.fromFirestore(doc))
          .toList();

      // Filtrer par distance si spécifiée
      if (latitude != null && longitude != null && maxDistance != null) {
        LatLng userLocation = LatLng(latitude, longitude);
        workers = workers.where((worker) {
          if (worker.currentLocation == null) return false;
          double? distance = worker.calculateDistance(userLocation);
          return distance != null && distance <= maxDistance;
        }).toList();
      }

      // Trier par score final (note + ancienneté)
      workers.sort((a, b) => b.finalScore.compareTo(a.finalScore));

      return workers;
    });
  }

  // Obtenir les travailleurs à proximité
  Stream<List<Worker>> getNearbyWorkers({
    required double latitude,
    required double longitude,
    double maxDistance = 10.0, // 10 km par défaut
    String? category,
  }) {
    Query query = _firestore
        .collection(FirebaseConfig.workersCollection)
        .where('status', isEqualTo: 'verified')
        .where('isOnline', isEqualTo: true);

    if (category != null) {
      query = query.where('services', arrayContains: category);
    }

    return query.snapshots().map((snapshot) {
      List<Worker> workers = snapshot.docs
          .map((doc) => Worker.fromFirestore(doc))
          .toList();

      // Filtrer par distance
      LatLng userLocation = LatLng(latitude, longitude);
      workers = workers.where((worker) {
        if (worker.currentLocation == null) return false;
        double? distance = worker.calculateDistance(userLocation);
        return distance != null && distance <= maxDistance;
      }).toList();

      // Trier par distance
      workers.sort((a, b) {
        double? distanceA = a.calculateDistance(userLocation);
        double? distanceB = b.calculateDistance(userLocation);
        if (distanceA == null && distanceB == null) return 0;
        if (distanceA == null) return 1;
        if (distanceB == null) return -1;
        return distanceA.compareTo(distanceB);
      });

      return workers;
    });
  }

  // Obtenir un travailleur par ID
  Future<Worker?> getWorkerById(String workerId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(FirebaseConfig.workersCollection)
          .doc(workerId)
          .get();

      if (doc.exists) {
        return Worker.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw WorkerException('Erreur lors de la récupération du travailleur: $e');
    }
  }

  // Rechercher des travailleurs par nom
  Stream<List<Worker>> searchWorkersByName(String searchQuery) {
    if (searchQuery.trim().isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection(FirebaseConfig.workersCollection)
        .where('status', isEqualTo: 'verified')
        .where('isOnline', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      List<Worker> workers = snapshot.docs
          .map((doc) => Worker.fromFirestore(doc))
          .toList();

      // Filtrer par nom (recherche insensible à la casse)
      String query = searchQuery.toLowerCase();
      workers = workers.where((worker) {
        return worker.firstName.toLowerCase().contains(query) ||
               worker.lastName.toLowerCase().contains(query) ||
               worker.fullName.toLowerCase().contains(query);
      }).toList();

      // Trier par note
      workers.sort((a, b) => b.rating.compareTo(a.rating));

      return workers;
    });
  }

  // Obtenir les travailleurs recommandés
  Stream<List<Worker>> getRecommendedWorkers({
    required String userId,
    String? category,
    double? latitude,
    double? longitude,
    int limit = 10,
  }) async* {
    try {
      // Obtenir l'historique des jobs de l'utilisateur
      QuerySnapshot userJobs = await _firestore
          .collection(FirebaseConfig.jobsCollection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .get();

      // Analyser les préférences de l'utilisateur
      Map<String, int> categoryPreferences = {};
      Map<String, double> workerPreferences = {};

      for (QueryDocumentSnapshot jobDoc in userJobs.docs) {
        Map<String, dynamic> jobData = jobDoc.data() as Map<String, dynamic>;
        String jobCategory = jobData['category'] ?? '';
        String? workerId = jobData['acceptedByWorkerId'];
        double? rating = jobData['userRating'];

        // Compter les préférences de catégorie
        if (jobCategory.isNotEmpty) {
          categoryPreferences[jobCategory] = (categoryPreferences[jobCategory] ?? 0) + 1;
        }

        // Analyser les préférences de travailleurs
        if (workerId != null && rating != null) {
          workerPreferences[workerId] = (workerPreferences[workerId] ?? 0) + rating;
        }
      }

      // Construire la requête
      Query query = _firestore
          .collection(FirebaseConfig.workersCollection)
          .where('status', isEqualTo: 'verified')
          .where('isOnline', isEqualTo: true);

      // Prioriser les catégories préférées
      if (category != null) {
        query = query.where('services', arrayContains: category);
      } else if (categoryPreferences.isNotEmpty) {
        // Utiliser la catégorie la plus populaire
        String preferredCategory = categoryPreferences.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
        query = query.where('services', arrayContains: preferredCategory);
      }

      QuerySnapshot workersSnapshot = await query.limit(limit * 2).get();

      List<Worker> workers = workersSnapshot.docs
          .map((doc) => Worker.fromFirestore(doc))
          .toList();

      // Calculer le score de recommandation
      for (Worker worker in workers) {
        double recommendationScore = 0.0;

        // Bonus pour les catégories préférées
        for (String service in worker.services) {
          if (categoryPreferences.containsKey(service)) {
            recommendationScore += categoryPreferences[service]! * 0.5;
          }
        }

        // Bonus pour les travailleurs bien notés par l'utilisateur
        if (workerPreferences.containsKey(worker.id)) {
          recommendationScore += workerPreferences[worker.id]! * 2.0;
        }

        // Bonus pour la proximité
        if (latitude != null && longitude != null && worker.currentLocation != null) {
          double? distance = worker.calculateDistance(LatLng(latitude, longitude));
          if (distance != null && distance <= 5.0) { // 5 km
            recommendationScore += 3.0;
          } else if (distance != null && distance <= 10.0) { // 10 km
            recommendationScore += 1.0;
          }
        }

        // Bonus pour la note globale
        recommendationScore += worker.rating * 0.5;

        // Bonus pour l'expérience
        recommendationScore += worker.experienceYears * 0.3;

        // Mettre à jour le score temporairement
        worker = worker.copyWith(
          metadata: {
            ...worker.metadata,
            'recommendationScore': recommendationScore,
          },
        );
      }

      // Trier par score de recommandation
      workers.sort((a, b) {
        double scoreA = (a.metadata['recommendationScore'] ?? 0.0).toDouble();
        double scoreB = (b.metadata['recommendationScore'] ?? 0.0).toDouble();
        return scoreB.compareTo(scoreA);
      });

      // Retourner les meilleurs résultats
      yield workers.take(limit).toList();
    } catch (e) {
      throw WorkerException('Erreur lors de la récupération des recommandations: $e');
    }
  }

  // Obtenir les travailleurs favoris d'un utilisateur
  Stream<List<Worker>> getFavoriteWorkers(String userId) {
    return _firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(userId)
        .snapshots()
        .asyncMap((userDoc) async {
      if (!userDoc.exists) return [];

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      List<String> favoriteWorkerIds = List<String>.from(userData['favoriteWorkers'] ?? []);

      if (favoriteWorkerIds.isEmpty) return [];

      // Récupérer les travailleurs favoris
      List<Worker> favoriteWorkers = [];
      for (String workerId in favoriteWorkerIds) {
        try {
          Worker? worker = await getWorkerById(workerId);
          if (worker != null) {
            favoriteWorkers.add(worker);
          }
        } catch (e) {
          print('Erreur lors de la récupération du travailleur favori $workerId: $e');
        }
      }

      // Trier par note
      favoriteWorkers.sort((a, b) => b.rating.compareTo(a.rating));
      return favoriteWorkers;
    });
  }

  // Ajouter/retirer un travailleur des favoris
  Future<void> toggleFavoriteWorker(String userId, String workerId) async {
    try {
      DocumentReference userRef = _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId);

      DocumentSnapshot userDoc = await userRef.get();
      if (!userDoc.exists) {
        throw WorkerException('Utilisateur introuvable');
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      List<String> favoriteWorkers = List<String>.from(userData['favoriteWorkers'] ?? []);

      if (favoriteWorkers.contains(workerId)) {
        // Retirer des favoris
        favoriteWorkers.remove(workerId);
      } else {
        // Ajouter aux favoris
        favoriteWorkers.add(workerId);
      }

      await userRef.update({
        'favoriteWorkers': favoriteWorkers,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw WorkerException('Erreur lors de la mise à jour des favoris: $e');
    }
  }

  // Obtenir les statistiques des travailleurs
  Future<Map<String, dynamic>> getWorkerStats(String workerId) async {
    try {
      // Récupérer le travailleur
      Worker? worker = await getWorkerById(workerId);
      if (worker == null) {
        throw WorkerException('Travailleur introuvable');
      }

      // Récupérer les jobs acceptés par ce travailleur
      QuerySnapshot acceptedJobs = await _firestore
          .collection(FirebaseConfig.jobsCollection)
          .where('acceptedByWorkerId', isEqualTo: workerId)
          .get();

      List<Map<String, dynamic>> jobs = acceptedJobs.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Calculer les statistiques
      int totalJobs = jobs.length;
      int completedJobs = jobs.where((job) => job['status'] == 'completed').length;
      int cancelledJobs = jobs.where((job) => job['status'] == 'cancelled').length;
      double totalEarnings = jobs
          .where((job) => job['finalPrice'] != null)
          .fold(0.0, (sum, job) => sum + (job['finalPrice'] ?? 0.0));

      double averageRating = worker.rating;
      double responseRate = totalJobs > 0 ? (completedJobs / totalJobs) * 100 : 0.0;

      // Calculer le temps de réponse moyen
      double averageResponseTime = 0.0;
      int jobsWithResponseTime = 0;

      for (Map<String, dynamic> job in jobs) {
        if (job['acceptedAt'] != null && job['createdAt'] != null) {
          Timestamp createdAt = job['createdAt'];
          Timestamp acceptedAt = job['acceptedAt'];
          double responseTime = acceptedAt.toDate().difference(createdAt.toDate()).inMinutes.toDouble();
          averageResponseTime += responseTime;
          jobsWithResponseTime++;
        }
      }

      if (jobsWithResponseTime > 0) {
        averageResponseTime /= jobsWithResponseTime;
      }

      return {
        'totalJobs': totalJobs,
        'completedJobs': completedJobs,
        'cancelledJobs': cancelledJobs,
        'totalEarnings': totalEarnings,
        'averageRating': averageRating,
        'responseRate': responseRate,
        'averageResponseTime': averageResponseTime,
        'experienceYears': worker.experienceYears,
        'servicesCount': worker.services.length,
        'certificationsCount': worker.certifications.length,
        'isOnline': worker.isOnline,
        'lastActive': worker.lastActive,
      };
    } catch (e) {
      throw WorkerException('Erreur lors de la récupération des statistiques: $e');
    }
  }

  // Obtenir les avis d'un travailleur
  Stream<List<WorkerReview>> getWorkerReviews(String workerId) {
    return _firestore
        .collection(FirebaseConfig.workersCollection)
        .doc(workerId)
        .snapshots()
        .map((workerDoc) {
      if (!workerDoc.exists) return [];

      Map<String, dynamic> workerData = workerDoc.data() as Map<String, dynamic>;
      List<dynamic> reviewsData = workerData['reviews'] ?? [];

      List<WorkerReview> reviews = reviewsData
          .map((reviewData) => WorkerReview.fromMap(reviewData))
          .toList();

      // Trier par date (plus récent en premier)
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    });
  }

  // Filtrer les travailleurs par critères avancés
  Stream<List<Worker>> filterWorkers({
    List<String>? services,
    double? minRating,
    double? maxRating,
    int? minExperience,
    int? maxExperience,
    double? minHourlyRate,
    double? maxHourlyRate,
    List<String>? certifications,
    bool? hasCertifications,
    String? language,
    double? latitude,
    double? longitude,
    double? maxDistance,
  }) {
    Query query = _firestore
        .collection(FirebaseConfig.workersCollection)
        .where('status', isEqualTo: 'verified')
        .where('isOnline', isEqualTo: true);

    // Appliquer les filtres Firestore
    if (services != null && services.isNotEmpty) {
      query = query.where('services', arrayContainsAny: services);
    }

    if (minRating != null) {
      query = query.where('rating', isGreaterThanOrEqualTo: minRating);
    }

    if (minExperience != null) {
      query = query.where('experienceYears', isGreaterThanOrEqualTo: minExperience);
    }

    if (minHourlyRate != null) {
      query = query.where('hourlyRate', isGreaterThanOrEqualTo: minHourlyRate);
    }

    if (language != null) {
      query = query.where('language', isEqualTo: language);
    }

    return query.snapshots().map((snapshot) {
      List<Worker> workers = snapshot.docs
          .map((doc) => Worker.fromFirestore(doc))
          .toList();

      // Appliquer les filtres côté client
      workers = workers.where((worker) {
        // Filtre par note maximale
        if (maxRating != null && worker.rating > maxRating) return false;

        // Filtre par expérience maximale
        if (maxExperience != null && worker.experienceYears > maxExperience) return false;

        // Filtre par tarif horaire maximal
        if (maxHourlyRate != null && worker.hourlyRate > maxHourlyRate) return false;

        // Filtre par certifications
        if (certifications != null && certifications.isNotEmpty) {
          bool hasRequiredCertifications = certifications
              .any((cert) => worker.certifications.contains(cert));
          if (!hasRequiredCertifications) return false;
        }

        // Filtre par présence de certifications
        if (hasCertifications == true && worker.certifications.isEmpty) return false;
        if (hasCertifications == false && worker.certifications.isNotEmpty) return false;

        return true;
      }).toList();

      // Filtre par distance
      if (latitude != null && longitude != null && maxDistance != null) {
        LatLng userLocation = LatLng(latitude, longitude);
        workers = workers.where((worker) {
          if (worker.currentLocation == null) return false;
          double? distance = worker.calculateDistance(userLocation);
          return distance != null && distance <= maxDistance;
        }).toList();
      }

      // Trier par note
      workers.sort((a, b) => b.rating.compareTo(a.rating));
      return workers;
    });
  }

  // Obtenir la position actuelle de l'utilisateur
  Future<Position?> getCurrentLocation() async {
    try {
      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Obtenir la position actuelle
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );
    } catch (e) {
      print('Erreur lors de la récupération de la position: $e');
      return null;
    }
  }

  // Calculer la distance entre deux points
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // Convertir en km
  }
}

// Exception personnalisée pour les travailleurs
class WorkerException implements Exception {
  final String message;
  WorkerException(this.message);

  @override
  String toString() => 'WorkerException: $message';
}