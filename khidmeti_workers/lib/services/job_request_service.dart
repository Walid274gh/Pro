import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:latlong2/latlong.dart';

import '../models/job_request.dart';
import '../utils/firebase_config.dart';

class JobRequestService {
  static final JobRequestService _instance = JobRequestService._internal();
  factory JobRequestService() => _instance;
  JobRequestService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Job requests proches et compatibles
  Stream<List<JobRequest>> getNearbyRequests({
    required List<String> workerServices,
    required LatLng workerLocation,
    double radiusKm = 20.0,
  }) {
    // On filtre d'abord par service et status, puis on filtre par distance côté client
    Query query = _firestore
        .collection(FirebaseConfig.jobRequestsCollection)
        .where('status', isEqualTo: 'pending')
        .where('category', whereIn: workerServices.isEmpty ? ['__none__'] : workerServices);

    return query.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      final requests = snapshot.docs.map((d) => JobRequest.fromFirestore(d)).toList();
      return requests.where((r) => r.isNearLocation(workerLocation, radiusKm)).toList();
    });
  }

  // Demandes acceptées par ce travailleur
  Stream<List<JobRequest>> getMyAcceptedRequests(String workerId) {
    return _firestore
        .collection(FirebaseConfig.jobRequestsCollection)
        .where('acceptedByWorkerId', isEqualTo: workerId)
        .orderBy('acceptedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => JobRequest.fromFirestore(d)).toList());
  }

  // Poser sa candidature (appliedWorkers +1)
  Future<void> applyToRequest(String jobRequestId, String workerId, {Map<String, dynamic>? offer}) async {
    final ref = _firestore.collection(FirebaseConfig.jobRequestsCollection).doc(jobRequestId);
    final snap = await ref.get();
    if (!snap.exists) return;
    final data = snap.data()!;
    final List<dynamic> applied = data['appliedWorkers'] ?? [];
    if (!applied.contains(workerId)) {
      applied.add(workerId);
    }
    final Map<String, dynamic> workerOffers = Map<String, dynamic>.from(data['workerOffers'] ?? {});
    if (offer != null) workerOffers[workerId] = offer;

    await ref.update({
      'appliedWorkers': applied,
      'workerOffers': workerOffers,
      'applicationCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Accepter un job (met à jour job + job_request)
  Future<void> acceptJob({required String jobId, required String workerId, required String workerName, String? workerImageUrl}) async {
    // Mettre à jour le job
    await _firestore.collection(FirebaseConfig.jobsCollection).doc(jobId).update({
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
      'acceptedByWorkerId': workerId,
      'acceptedByWorkerName': workerName,
      'acceptedByWorkerImageUrl': workerImageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Mettre à jour la request correspondante
    final reqs = await _firestore
        .collection(FirebaseConfig.jobRequestsCollection)
        .where('jobId', isEqualTo: jobId)
        .limit(1)
        .get();
    if (reqs.docs.isNotEmpty) {
      await reqs.docs.first.reference.update({
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
        'acceptedByWorkerId': workerId,
        'acceptedByWorkerName': workerName,
        'acceptedByWorkerImageUrl': workerImageUrl,
      });
    }

    // Créer une notification pour l'utilisateur (enregistrée côté Firestore; FCM géré ailleurs)
    final jobSnap = await _firestore.collection(FirebaseConfig.jobsCollection).doc(jobId).get();
    if (jobSnap.exists) {
      final userId = (jobSnap.data() ?? {})['userId'];
      if (userId != null) {
        await _firestore.collection(FirebaseConfig.notificationsCollection).add({
          'userId': userId,
          'type': 'jobAccepted',
          'title': 'Votre demande a été acceptée',
          'body': '$workerName a accepté votre demande',
          'data': {'jobId': jobId, 'workerId': workerId},
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
          'priority': 'high',
        });
      }
    }
  }

  Future<void> startJob(String jobId) async {
    await _firestore.collection(FirebaseConfig.jobsCollection).doc(jobId).update({
      'status': 'inProgress',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final reqs = await _firestore
        .collection(FirebaseConfig.jobRequestsCollection)
        .where('jobId', isEqualTo: jobId)
        .limit(1)
        .get();
    if (reqs.docs.isNotEmpty) {
      await reqs.docs.first.reference.update({'status': 'inProgress'});
    }
  }

  Future<void> completeJob(String jobId, {double? finalPrice, List<File> proofImages = const []}) async {
    // Uploader preuves si fournies
    final List<String> imageUrls = [];
    for (int i = 0; i < proofImages.length; i++) {
      final path = 'job_media/$jobId/proofs/$i.jpg';
      final snap = await _storage.ref().child(path).putFile(proofImages[i]);
      imageUrls.add(await snap.ref.getDownloadURL());
    }

    await _firestore.collection(FirebaseConfig.jobsCollection).doc(jobId).update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
      'finalPrice': finalPrice,
      'proofImages': imageUrls,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final reqs = await _firestore
        .collection(FirebaseConfig.jobRequestsCollection)
        .where('jobId', isEqualTo: jobId)
        .limit(1)
        .get();
    if (reqs.docs.isNotEmpty) {
      await reqs.docs.first.reference.update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'finalPrice': finalPrice,
      });
    }
  }

  Future<void> cancelJobByWorker(String jobId, {String? reason}) async {
    await _firestore.collection(FirebaseConfig.jobsCollection).doc(jobId).update({
      'status': 'cancelled',
      'workerCancelReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final reqs = await _firestore
        .collection(FirebaseConfig.jobRequestsCollection)
        .where('jobId', isEqualTo: jobId)
        .limit(1)
        .get();
    if (reqs.docs.isNotEmpty) {
      await reqs.docs.first.reference.update({'status': 'cancelled'});
    }
  }
}