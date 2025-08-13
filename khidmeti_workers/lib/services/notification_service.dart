import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../utils/firebase_config.dart';

class WorkerNotificationService {
  static final WorkerNotificationService _instance = WorkerNotificationService._internal();
  factory WorkerNotificationService() => _instance;
  WorkerNotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationDetails _androidDetails = AndroidNotificationDetails(
    'khidmeti_workers_channel',
    'KHIDMETI Workers',
    channelDescription: 'Notifications KHIDMETI Workers',
    importance: Importance.high,
    priority: Priority.high,
  );
  static const NotificationDetails _details = NotificationDetails(android: _androidDetails);

  Future<void> initialize(String workerId) async {
    // Local notifications
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _local.initialize(initializationSettings, onDidReceiveNotificationResponse: (resp) {});

    // FCM permissions
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // Save token
    final token = await _messaging.getToken();
    if (token != null) {
      await _firestore.collection(FirebaseConfig.workersCollection).doc(workerId).update({'fcmToken': token});
    }

    _messaging.onTokenRefresh.listen((t) async {
      await _firestore.collection(FirebaseConfig.workersCollection).doc(workerId).update({'fcmToken': t});
    });

    FirebaseMessaging.onMessage.listen((message) async {
      await _local.show(
        message.hashCode,
        message.notification?.title ?? 'Notification',
        message.notification?.body ?? '',
        _details,
      );
    });
  }
}