import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_config.dart';

class FirebaseSyncService {
  static final FirebaseSyncService _instance = FirebaseSyncService._internal();
  factory FirebaseSyncService() => _instance;
  FirebaseSyncService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Streams de synchronisation en temps réel
  Stream<QuerySnapshot>? _workersStream;
  Stream<QuerySnapshot>? _jobsStream;
  Stream<QuerySnapshot>? _notificationsStream;

  // Écouteurs de changements
  List<StreamSubscription> _subscriptions = [];

  // Initialisation du service
  Future<void> initialize() async {
    await _setupFirebaseMessaging();
    await _setupRealTimeSync();
    await _setupSecurityRules();
  }

  // Configuration de Firebase Messaging
  Future<void> _setupFirebaseMessaging() async {
    // Demander les permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Notifications autorisées');
    }

    // Obtenir le token FCM
    String? token = await _messaging.getToken();
    if (token != null) {
      await _updateFcmToken(token);
    }

    // Écouter les changements de token
    _messaging.onTokenRefresh.listen((newToken) {
      _updateFcmToken(newToken);
    });

    // Configuration des messages en arrière-plan
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Configuration de la synchronisation en temps réel
  Future<void> _setupRealTimeSync() async {
    // Stream des travailleurs en ligne
    _workersStream = _firestore
        .collection(FirebaseConfig.workersCollection)
        .where('isOnline', isEqualTo: true)
        .where('status', isEqualTo: 'verified')
        .snapshots();

    // Stream des jobs actifs
    _jobsStream = _firestore
        .collection(FirebaseConfig.jobsCollection)
        .where('status', whereIn: ['pending', 'accepted'])
        .orderBy('createdAt', descending: true)
        .snapshots();

    // Stream des notifications
    if (_auth.currentUser != null) {
      _notificationsStream = _firestore
          .collection(FirebaseConfig.notificationsCollection)
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots();
    }
  }

  // Configuration des règles de sécurité
  Future<void> _setupSecurityRules() async {
    // Les règles sont configurées dans Firebase Console
    // Cette méthode peut être utilisée pour valider les règles côté client
  }

  // Mise à jour du token FCM
  Future<void> _updateFcmToken(String token) async {
    if (_auth.currentUser != null) {
      String userId = _auth.currentUser!.uid;
      
      // Mettre à jour dans la collection users
      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .update({'fcmToken': token});

      // Mettre à jour dans la collection workers si applicable
      DocumentSnapshot workerDoc = await _firestore
          .collection(FirebaseConfig.workersCollection)
          .doc(userId)
          .get();
      
      if (workerDoc.exists) {
        await _firestore
            .collection(FirebaseConfig.workersCollection)
            .doc(userId)
            .update({'fcmToken': token});
      }
    }
  }

  // SYNCHRONISATION DES TRAVAILLEURS
  // Mettre à jour le statut en ligne d'un travailleur
  Future<void> updateWorkerOnlineStatus(String workerId, bool isOnline) async {
    try {
      await _firestore
          .collection(FirebaseConfig.workersCollection)
          .doc(workerId)
          .update({
        'isOnline': isOnline,
        'lastActive': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Déclencher une notification pour les utilisateurs à proximité
      if (isOnline) {
        await _notifyNearbyUsers(workerId);
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du statut en ligne: $e');
      rethrow;
    }
  }

  // Mettre à jour la localisation d'un travailleur
  Future<void> updateWorkerLocation(String workerId, double latitude, double longitude, String address) async {
    try {
      await _firestore
          .collection(FirebaseConfig.workersCollection)
          .doc(workerId)
          .update({
        'currentLocation': GeoPoint(latitude, longitude),
        'currentAddress': address,
        'lastActive': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur lors de la mise à jour de la localisation: $e');
      rethrow;
    }
  }

  // Notifier les utilisateurs à proximité
  Future<void> _notifyNearbyUsers(String workerId) async {
    try {
      // Récupérer les informations du travailleur
      DocumentSnapshot workerDoc = await _firestore
          .collection(FirebaseConfig.workersCollection)
          .doc(workerId)
          .get();
      
      if (!workerDoc.exists) return;

      Map<String, dynamic> workerData = workerDoc.data() as Map<String, dynamic>;
      GeoPoint? workerLocation = workerData['currentLocation'];
      List<String> services = List<String>.from(workerData['services'] ?? []);

      if (workerLocation == null || services.isEmpty) return;

      // Rechercher les utilisateurs à proximité avec des jobs correspondants
      QuerySnapshot nearbyJobs = await _firestore
          .collection(FirebaseConfig.jobsCollection)
          .where('status', isEqualTo: 'pending')
          .where('category', whereIn: services)
          .get();

      for (QueryDocumentSnapshot jobDoc in nearbyJobs.docs) {
        Map<String, dynamic> jobData = jobDoc.data() as Map<String, dynamic>;
        GeoPoint jobLocation = jobData['location'];
        
        // Calculer la distance
        double distance = _calculateDistance(
          workerLocation.latitude, workerLocation.longitude,
          jobLocation.latitude, jobLocation.longitude
        );

        // Si le job est à proximité, notifier l'utilisateur
        if (distance <= FirebaseConfig.nearbyWorkerDistance) {
          await _createNotification(
            userId: jobData['userId'],
            type: 'workerNearby',
            title: 'Travailleur à proximité',
            body: 'Un travailleur qualifié est disponible près de chez vous',
            data: {
              'workerId': workerId,
              'jobId': jobDoc.id,
              'distance': distance.toStringAsFixed(1),
            },
          );
        }
      }
    } catch (e) {
      print('Erreur lors de la notification des utilisateurs: $e');
    }
  }

  // SYNCHRONISATION DES JOBS
  // Créer un nouveau job
  Future<String> createJob(Map<String, dynamic> jobData) async {
    try {
      DocumentReference jobRef = await _firestore
          .collection(FirebaseConfig.jobsCollection)
          .add({
        ...jobData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'viewCount': 0,
        'applicationCount': 0,
        'metadata': FirebaseConfig.defaultMetadata,
      });

      // Créer une entrée dans job_requests pour les travailleurs
      await _firestore
          .collection(FirebaseConfig.jobRequestsCollection)
          .add({
        'jobId': jobRef.id,
        'userId': jobData['userId'],
        'userFirstName': jobData['userFirstName'],
        'userLastName': jobData['userLastName'],
        'userImageUrl': jobData['userImageUrl'],
        'userPhoneNumber': jobData['userPhoneNumber'],
        'title': jobData['title'],
        'description': jobData['description'],
        'category': jobData['category'],
        'images': jobData['images'] ?? [],
        'videos': jobData['videos'] ?? [],
        'location': jobData['location'],
        'address': jobData['address'],
        'status': 'pending',
        'priority': jobData['priority'] ?? 'medium',
        'budget': jobData['budget'],
        'currency': jobData['currency'] ?? 'DZD',
        'deadline': jobData['deadline'],
        'createdAt': FieldValue.serverTimestamp(),
        'requirements': jobData['requirements'] ?? {},
        'isUrgent': jobData['isUrgent'] ?? false,
        'language': jobData['language'] ?? 'fr',
        'tags': jobData['tags'] ?? [],
        'viewCount': 0,
        'applicationCount': 0,
        'appliedWorkers': [],
        'workerOffers': {},
        'metadata': FirebaseConfig.defaultMetadata,
      });

      // Notifier les travailleurs qualifiés
      await _notifyQualifiedWorkers(jobData);

      return jobRef.id;
    } catch (e) {
      print('Erreur lors de la création du job: $e');
      rethrow;
    }
  }

  // Notifier les travailleurs qualifiés
  Future<void> _notifyQualifiedWorkers(Map<String, dynamic> jobData) async {
    try {
      String category = jobData['category'];
      GeoPoint jobLocation = jobData['location'];

      // Rechercher les travailleurs qualifiés
      QuerySnapshot qualifiedWorkers = await _firestore
          .collection(FirebaseConfig.workersCollection)
          .where('services', arrayContains: category)
          .where('status', isEqualTo: 'verified')
          .where('isOnline', isEqualTo: true)
          .get();

      for (QueryDocumentSnapshot workerDoc in qualifiedWorkers.docs) {
        Map<String, dynamic> workerData = workerDoc.data() as Map<String, dynamic>;
        GeoPoint? workerLocation = workerData['currentLocation'];

        if (workerLocation != null) {
          double distance = _calculateDistance(
            workerLocation.latitude, workerLocation.longitude,
            jobLocation.latitude, jobLocation.longitude
          );

          // Notifier si le travailleur est dans la zone de travail
          if (distance <= (workerData['maxDistance'] ?? FirebaseConfig.defaultMaxDistance)) {
            await _createNotification(
              userId: workerDoc.id,
              type: 'newJob',
              title: 'Nouvelle demande de travail',
              body: 'Une nouvelle demande correspond à vos compétences',
              data: {
                'jobId': jobData['jobId'] ?? '',
                'category': category,
                'budget': jobData['budget'].toString(),
                'distance': distance.toStringAsFixed(1),
              },
            );
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la notification des travailleurs: $e');
    }
  }

  // Accepter un job
  Future<void> acceptJob(String jobId, String workerId, String workerName, String? workerImageUrl) async {
    try {
      // Mettre à jour le job
      await _firestore
          .collection(FirebaseConfig.jobsCollection)
          .doc(jobId)
          .update({
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
        'acceptedByWorkerId': workerId,
        'acceptedByWorkerName': workerName,
        'acceptedByWorkerImageUrl': workerImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Mettre à jour la demande de travail
      await _firestore
          .collection(FirebaseConfig.jobRequestsCollection)
          .where('jobId', isEqualTo: jobId)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          snapshot.docs.first.reference.update({
            'status': 'accepted',
            'acceptedAt': FieldValue.serverTimestamp(),
            'acceptedByWorkerId': workerId,
            'acceptedByWorkerName': workerName,
            'acceptedByWorkerImageUrl': workerImageUrl,
          });
        }
      });

      // Notifier l'utilisateur
      DocumentSnapshot jobDoc = await _firestore
          .collection(FirebaseConfig.jobsCollection)
          .doc(jobId)
          .get();
      
      if (jobDoc.exists) {
        Map<String, dynamic> jobData = jobDoc.data() as Map<String, dynamic>;
        await _createNotification(
          userId: jobData['userId'],
          type: 'jobAccepted',
          title: 'Travail accepté',
          body: 'Un travailleur a accepté votre demande',
          data: {
            'jobId': jobId,
            'workerId': workerId,
            'workerName': workerName,
          },
        );
      }
    } catch (e) {
      print('Erreur lors de l\'acceptation du job: $e');
      rethrow;
    }
  }

  // NOTIFICATIONS
  // Créer une notification
  Future<void> _createNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConfig.notificationsCollection)
          .add({
        'userId': userId,
        'type': type,
        'title': title,
        'titleEn': title, // À traduire selon la langue
        'titleAr': title, // À traduire selon la langue
        'body': body,
        'bodyEn': body, // À traduire selon la langue
        'bodyAr': body, // À traduire selon la langue
        'data': data ?? {},
        'isRead': false,
        'isActioned': false,
        'createdAt': FieldValue.serverTimestamp(),
        'priority': 'normal',
        'metadata': FirebaseConfig.defaultMetadata,
      });
    } catch (e) {
      print('Erreur lors de la création de la notification: $e');
    }
  }

  // UTILITAIRES
  // Calculer la distance entre deux points
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    double dLat = (lat2 - lat1) * (pi / 180);
    double dLon = (lon2 - lon1) * (pi / 180);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) * cos(lat2 * (pi / 180)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  // Nettoyer les anciennes notifications
  Future<void> cleanupOldNotifications() async {
    try {
      DateTime cutoffDate = DateTime.now().subtract(Duration(days: FirebaseConfig.maxNotificationAge));
      
      QuerySnapshot oldNotifications = await _firestore
          .collection(FirebaseConfig.notificationsCollection)
          .where('createdAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot doc in oldNotifications.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Erreur lors du nettoyage des notifications: $e');
    }
  }

  // Obtenir les streams de synchronisation
  Stream<QuerySnapshot>? get workersStream => _workersStream;
  Stream<QuerySnapshot>? get jobsStream => _jobsStream;
  Stream<QuerySnapshot>? get notificationsStream => _notificationsStream;

  // Arrêter la synchronisation
  void dispose() {
    for (StreamSubscription subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}

// Gestionnaire de messages en arrière-plan
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Message reçu en arrière-plan: ${message.messageId}');
  
  // Traiter le message selon le type
  switch (message.data['type']) {
    case 'newJob':
      // Logique pour les nouveaux jobs
      break;
    case 'jobAccepted':
      // Logique pour les jobs acceptés
      break;
    case 'workerNearby':
      // Logique pour les travailleurs à proximité
      break;
    default:
      print('Type de message non reconnu: ${message.data['type']}');
  }
}