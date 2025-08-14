import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firebase_service.dart';
import '../core/constants/firestore_paths.dart';

class NotificationService {
	final FirebaseMessaging _messaging = FirebaseMessaging.instance;

	Future<void> initializeForWorker(String workerId) async {
		await _messaging.requestPermission(alert: true, badge: true, sound: true);
		await _messaging.setAutoInitEnabled(true);
		final token = await _messaging.getToken();
		if (token != null) {
			final ref = FirebaseService.db.collection(FirestorePaths.workers).doc(workerId).collection('tokens').doc(token);
			await ref.set({'token': token, 'createdAt': FieldValue.serverTimestamp(), 'platform': 'flutter'});
		}
	}
}