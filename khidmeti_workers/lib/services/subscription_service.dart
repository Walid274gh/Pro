import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../utils/firebase_config.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> ensureFreeTrial(String workerId) async {
    final doc = await _firestore.collection(FirebaseConfig.workersCollection).doc(workerId).get();
    if (!doc.exists) return;
    final data = doc.data()!;
    final status = data['subscriptionStatus'];
    if (status == 'free' || status == 'active') return;

    final now = DateTime.now();
    final freeEnd = DateTime(now.year, now.month + FirebaseConfig.freeTrialMonths, now.day);

    await _firestore.collection(FirebaseConfig.workersCollection).doc(workerId).update({
      'subscriptionStatus': 'free',
      'subscriptionStartDate': Timestamp.fromDate(now),
      'subscriptionEndDate': Timestamp.fromDate(freeEnd),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setPaidPlan({
    required String workerId,
    required String plan, // 'monthly' | 'yearly'
    required double amount,
  }) async {
    final now = DateTime.now();
    final end = plan == 'monthly'
        ? DateTime(now.year, now.month + 1, now.day)
        : DateTime(now.year + 1, now.month, now.day);

    await _firestore.collection(FirebaseConfig.workersCollection).doc(workerId).update({
      'subscriptionStatus': 'active',
      'subscriptionPlan': plan,
      'subscriptionAmount': amount,
      'subscriptionStartDate': Timestamp.fromDate(now),
      'subscriptionEndDate': Timestamp.fromDate(end),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> uploadPaymentReceipt(String workerId, File receiptImage) async {
    final path = 'payment_receipts/$workerId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final snap = await _storage.ref().child(path).putFile(receiptImage);
    final url = await snap.ref.getDownloadURL();

    await _firestore.collection(FirebaseConfig.workersCollection).doc(workerId).update({
      'lastPaymentReceiptUrl': url,
      'lastPaymentDate': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return url;
  }

  Future<bool> isSubscriptionActive(String workerId) async {
    final doc = await _firestore.collection(FirebaseConfig.workersCollection).doc(workerId).get();
    if (!doc.exists) return false;
    final data = doc.data()!;
    final status = data['subscriptionStatus'];
    final Timestamp? endTs = data['subscriptionEndDate'];
    if (status == 'active') {
      if (endTs == null) return false;
      return endTs.toDate().isAfter(DateTime.now());
    }
    if (status == 'free') {
      if (endTs == null) return false;
      return endTs.toDate().isAfter(DateTime.now());
    }
    return false;
  }
}