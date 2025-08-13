import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification.dart';
import 'firebase_config.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Configuration des notifications locales
  static const AndroidNotificationDetails _androidChannelDetails = AndroidNotificationDetails(
    'khidmeti_channel',
    'KHIDMETI Notifications',
    channelDescription: 'Notifications de l\'application KHIDMETI',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
    enableVibration: true,
    enableLights: true,
    color: Color(0xFFE02F75),
  );

  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: _androidChannelDetails,
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  // Initialisation du service
  Future<void> initialize() async {
    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();
    await _requestPermissions();
  }

  // Initialisation des notifications locales
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Créer le canal Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannelDetails);
  }

  // Initialisation de Firebase Messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Écouter les messages en premier plan
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Écouter les messages en arrière-plan
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Écouter les notifications tapées
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTapped);

    // Écouter les notifications ouvertes depuis l'état terminé
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTapped(initialMessage);
    }
  }

  // Demander les permissions
  Future<void> _requestPermissions() async {
    // Permissions Firebase
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Notifications Firebase autorisées');
    }

    // Permissions locales
    await _localNotifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // Gérer les messages en premier plan
  void _handleForegroundMessage(RemoteMessage message) {
    print('Message reçu en premier plan: ${message.messageId}');
    
    // Afficher une notification locale
    _showLocalNotification(
      id: message.hashCode,
      title: message.notification?.title ?? 'Nouvelle notification',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );

    // Sauvegarder la notification dans Firestore
    _saveNotificationToFirestore(message);
  }

  // Gérer les notifications tapées
  void _handleNotificationTapped(RemoteMessage message) {
    print('Notification tapée: ${message.messageId}');
    
    // Traiter les données de la notification
    Map<String, dynamic> data = message.data;
    String type = data['type'] ?? '';
    
    switch (type) {
      case 'newJob':
        // Naviguer vers la liste des jobs
        _navigateToJobs();
        break;
      case 'jobAccepted':
        // Naviguer vers le job accepté
        String? jobId = data['jobId'];
        if (jobId != null) {
          _navigateToJob(jobId);
        }
        break;
      case 'workerNearby':
        // Naviguer vers la carte des travailleurs
        _navigateToWorkersMap();
        break;
      case 'newMessage':
        // Naviguer vers la conversation
        String? chatId = data['chatId'];
        if (chatId != null) {
          _navigateToChat(chatId);
        }
        break;
      default:
        print('Type de notification non reconnu: $type');
    }
  }

  // Gérer les notifications locales tapées
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification locale tapée: ${response.payload}');
    
    // Traiter le payload de la notification
    if (response.payload != null) {
      // Parser le payload et naviguer en conséquence
      _processNotificationPayload(response.payload!);
    }
  }

  // Afficher une notification locale
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotifications.show(
      id,
      title,
      body,
      _notificationDetails,
      payload: payload,
    );
  }

  // Sauvegarder la notification dans Firestore
  Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    try {
      String? userId = message.data['userId'];
      if (userId == null) return;

      await _firestore
          .collection(FirebaseConfig.notificationsCollection)
          .add({
        'userId': userId,
        'type': message.data['type'] ?? 'system',
        'title': message.notification?.title ?? '',
        'titleEn': message.notification?.title ?? '',
        'titleAr': message.notification?.title ?? '',
        'body': message.notification?.body ?? '',
        'bodyEn': message.notification?.body ?? '',
        'bodyAr': message.notification?.body ?? '',
        'data': message.data,
        'isRead': false,
        'isActioned': false,
        'createdAt': FieldValue.serverTimestamp(),
        'priority': 'normal',
        'metadata': FirebaseConfig.defaultMetadata,
      });
    } catch (e) {
      print('Erreur lors de la sauvegarde de la notification: $e');
    }
  }

  // Obtenir toutes les notifications d'un utilisateur
  Stream<List<AppNotification>> getUserNotifications(String userId) {
    return _firestore
        .collection(FirebaseConfig.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromFirestore(doc))
            .toList());
  }

  // Obtenir le nombre de notifications non lues
  Stream<int> getUnreadNotificationCount(String userId) {
    return _firestore
        .collection(FirebaseConfig.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Marquer une notification comme lue
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(FirebaseConfig.notificationsCollection)
          .doc(notificationId)
          .update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw NotificationException('Erreur lors du marquage de la notification: $e');
    }
  }

  // Marquer toutes les notifications comme lues
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      QuerySnapshot unreadNotifications = await _firestore
          .collection(FirebaseConfig.notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot doc in unreadNotifications.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      throw NotificationException('Erreur lors du marquage des notifications: $e');
    }
  }

  // Marquer une notification comme actionnée
  Future<void> markNotificationAsActioned(String notificationId) async {
    try {
      await _firestore
          .collection(FirebaseConfig.notificationsCollection)
          .doc(notificationId)
          .update({
        'isActioned': true,
        'actionedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw NotificationException('Erreur lors du marquage de l\'action: $e');
    }
  }

  // Supprimer une notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection(FirebaseConfig.notificationsCollection)
          .doc(notificationId)
          .delete();
    } catch (e) {
      throw NotificationException('Erreur lors de la suppression de la notification: $e');
    }
  }

  // Supprimer toutes les notifications anciennes
  Future<void> cleanupOldNotifications(String userId) async {
    try {
      DateTime cutoffDate = DateTime.now().subtract(Duration(days: 30));
      
      QuerySnapshot oldNotifications = await _firestore
          .collection(FirebaseConfig.notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('createdAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot doc in oldNotifications.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Erreur lors du nettoyage des anciennes notifications: $e');
    }
  }

  // Créer une notification personnalisée
  Future<void> createCustomNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    try {
      // Créer dans Firestore
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
        'priority': priority.toString().split('.').last,
        'metadata': FirebaseConfig.defaultMetadata,
      });

      // Afficher localement si l'utilisateur est connecté
      if (await _isUserActive(userId)) {
        _showLocalNotification(
          id: DateTime.now().millisecondsSinceEpoch,
          title: title,
          body: body,
          payload: data?.toString(),
        );
      }
    } catch (e) {
      throw NotificationException('Erreur lors de la création de la notification: $e');
    }
  }

  // Vérifier si l'utilisateur est actif
  Future<bool> _isUserActive(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        DateTime? lastActive = userData['lastActive']?.toDate();
        
        if (lastActive != null) {
          Duration timeSinceLastActive = DateTime.now().difference(lastActive);
          return timeSinceLastActive.inMinutes < 5; // Considéré actif si moins de 5 min
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Obtenir le token FCM de l'utilisateur
  Future<String?> getFcmToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Erreur lors de la récupération du token FCM: $e');
      return null;
    }
  }

  // Mettre à jour le token FCM
  Future<void> updateFcmToken(String userId, String? token) async {
    try {
      if (token != null) {
        await _firestore
            .collection(FirebaseConfig.usersCollection)
            .doc(userId)
            .update({'fcmToken': token});
      } else {
        await _firestore
            .collection(FirebaseConfig.usersCollection)
            .doc(userId)
            .update({'fcmToken': FieldValue.delete()});
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du token FCM: $e');
    }
  }

  // Configurer les préférences de notification
  Future<void> configureNotificationPreferences({
    required String userId,
    bool? jobNotifications,
    bool? workerNotifications,
    bool? messageNotifications,
    bool? systemNotifications,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) async {
    try {
      Map<String, dynamic> preferences = {};
      
      if (jobNotifications != null) preferences['jobNotifications'] = jobNotifications;
      if (workerNotifications != null) preferences['workerNotifications'] = workerNotifications;
      if (messageNotifications != null) preferences['messageNotifications'] = messageNotifications;
      if (systemNotifications != null) preferences['systemNotifications'] = systemNotifications;
      if (soundEnabled != null) preferences['soundEnabled'] = soundEnabled;
      if (vibrationEnabled != null) preferences['vibrationEnabled'] = vibrationEnabled;

      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .update({
        'notificationPreferences': preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Sauvegarder localement
      await _saveNotificationPreferencesLocally(preferences);
    } catch (e) {
      throw NotificationException('Erreur lors de la configuration des préférences: $e');
    }
  }

  // Sauvegarder les préférences localement
  Future<void> _saveNotificationPreferencesLocally(Map<String, dynamic> preferences) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (String key in preferences.keys) {
      await prefs.setBool('notification_$key', preferences[key] as bool);
    }
  }

  // Navigation (à implémenter selon l'architecture de navigation)
  void _navigateToJobs() {
    // TODO: Implémenter la navigation vers la liste des jobs
    print('Navigation vers la liste des jobs');
  }

  void _navigateToJob(String jobId) {
    // TODO: Implémenter la navigation vers un job spécifique
    print('Navigation vers le job: $jobId');
  }

  void _navigateToWorkersMap() {
    // TODO: Implémenter la navigation vers la carte des travailleurs
    print('Navigation vers la carte des travailleurs');
  }

  void _navigateToChat(String chatId) {
    // TODO: Implémenter la navigation vers une conversation
    print('Navigation vers la conversation: $chatId');
  }

  void _processNotificationPayload(String payload) {
    // TODO: Implémenter le traitement du payload
    print('Traitement du payload: $payload');
  }

  // Arrêter le service
  void dispose() {
    // Nettoyer les ressources si nécessaire
  }
}

// Gestionnaire de messages en arrière-plan
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Message reçu en arrière-plan: ${message.messageId}');
  
  // Traiter le message selon le type
  Map<String, dynamic> data = message.data;
  String type = data['type'] ?? '';
  
  switch (type) {
    case 'newJob':
      // Logique pour les nouveaux jobs
      break;
    case 'jobAccepted':
      // Logique pour les jobs acceptés
      break;
    case 'workerNearby':
      // Logique pour les travailleurs à proximité
      break;
    case 'newMessage':
      // Logique pour les nouveaux messages
      break;
    default:
      print('Type de message non reconnu: $type');
  }
}

// Exception personnalisée pour les notifications
class NotificationException implements Exception {
  final String message;
  NotificationException(this.message);

  @override
  String toString() => 'NotificationException: $message';
}