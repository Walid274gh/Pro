import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../utils/firebase_config.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> createPaymentIntent({
    required String workerId,
    required double amount,
    required String method, // 'barid_mob' | 'carte_bancaire' | 'paiement_poste'
  }) async {
    final ref = await _firestore.collection(FirebaseConfig.paymentsCollection).add({
      'workerId': workerId,
      'amount': amount,
      'method': method,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> confirmOnlinePayment({required String paymentId, required String transactionId}) async {
    await _firestore.collection(FirebaseConfig.paymentsCollection).doc(paymentId).update({
      'status': 'confirmed',
      'transactionId': transactionId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> failPayment({required String paymentId, String? reason}) async {
    await _firestore.collection(FirebaseConfig.paymentsCollection).doc(paymentId).update({
      'status': 'failed',
      'failureReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> uploadPostReceipt({required String workerId, required String paymentId, required File receipt}) async {
    final path = 'payment_receipts/$workerId/$paymentId.jpg';
    final snap = await _storage.ref().child(path).putFile(receipt);
    final url = await snap.ref.getDownloadURL();

    await _firestore.collection(FirebaseConfig.paymentsCollection).doc(paymentId).update({
      'status': 'under_review',
      'receiptUrl': url,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return url;
  }

  Future<void> markReviewed({required String paymentId, required bool approved}) async {
    await _firestore.collection(FirebaseConfig.paymentsCollection).doc(paymentId).update({
      'status': approved ? 'confirmed' : 'rejected',
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }
}