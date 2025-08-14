import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../domain/entities/job_request.dart';
import '../../domain/entities/worker_proposal_view.dart';
import '../../domain/repositories/job_repository.dart';
import '../../domain/value_objects/location.dart';
import '../../core/constants/service_categories.dart';
import '../../services/firebase_service.dart';
import '../models/job_request_model.dart';

class JobRepositoryImpl implements JobRepository {
	FirebaseFirestore get _db => FirebaseService.db;

	@override
	Future<String> createJobRequest(JobRequest request) async {
		final model = JobRequestModel(
			id: request.id,
			title: request.title,
			description: request.description,
			mediaUrls: request.mediaUrls,
			category: request.category,
			preferredDate: request.preferredDate,
			timeSlot: request.timeSlot,
			workLocation: request.workLocation,
			budgetMax: request.budgetMax,
			clientId: request.clientId,
			createdAt: DateTime.now(),
			status: request.status,
		);
		final ref = _db.collection(FirestorePaths.jobs).doc();
		await ref.set({
			...model.toMap(),
			'id': ref.id,
			'createdAt': FieldValue.serverTimestamp(),
		});
		return ref.id;
	}

	@override
	Stream<List<WorkerProposalView>> watchProposals(String jobId) {
		final ref = _db.collection(FirestorePaths.proposals)
			.where('jobId', isEqualTo: jobId)
			.orderBy('createdAt', descending: true);
		return ref.snapshots().map((snapshot) {
			return snapshot.docs.map((doc) {
				final data = doc.data();
				return WorkerProposalView(
					workerId: data['workerId'] as String,
					workerName: data['workerName'] as String? ?? 'Artisan',
					workerAvatarUrl: data['workerAvatarUrl'] as String?,
					workerRating: (data['workerRating'] is num) ? (data['workerRating'] as num).toDouble() : 0.0,
					workerCompletedJobs: (data['workerCompletedJobs'] as int?) ?? 0,
					proposedPrice: (data['proposedPrice'] as num).toDouble(),
					estimatedDuration: data['estimatedDuration'] as String,
					personalMessage: data['personalMessage'] as String,
					availableDate: _parseDate(data['availableDate']),
					timeSlot: null,
				);
			}).toList();
		});
	}

	@override
	Future<void> acceptProposal({required String jobId, required String workerId}) async {
		final jobRef = _db.collection(FirestorePaths.jobs).doc(jobId);
		await _db.runTransaction((txn) async {
			final jobSnap = await txn.get(jobRef);
			if (!jobSnap.exists) {
				throw StateError('Job not found');
			}
			final status = jobSnap.get('status') as String? ?? 'open';
			if (status != 'open') {
				throw StateError('Job is not open');
			}
			txn.update(jobRef, {
				'status': 'accepted',
				'acceptedWorkerId': workerId,
				'acceptedAt': FieldValue.serverTimestamp(),
			});
		});
	}

	@override
	Stream<List<JobRequest>> watchClientJobs(String clientId) {
		final ref = _db.collection(FirestorePaths.jobs)
			.where('clientId', isEqualTo: clientId)
			.orderBy('createdAt', descending: true);
		return ref.snapshots().map((snapshot) => snapshot.docs.map((doc) {
			final data = doc.data();
			data['id'] = doc.id;
			return JobRequestModel.fromMap(data);
		}).toList());
	}

	@override
	Stream<List<RecommendedWorker>> watchRecommendedWorkers({
		required Location around,
		required double radiusKm,
		required ServiceCategory category,
	}) {
		// Simple placeholder: query online workers filtered by category
		final ref = _db.collection(FirestorePaths.workers)
			.where('isOnline', isEqualTo: true)
			.where('serviceCategories', arrayContains: category.key)
			.limit(50);
		return ref.snapshots().map((snapshot) {
			return snapshot.docs.map((doc) {
				final data = doc.data();
				final loc = data['location'] as Map<String, dynamic>?;
				final workerLoc = loc != null
					? Location.fromJson(Map<String, dynamic>.from(loc))
					: Location(latitude: 0, longitude: 0);
				final distance = around.distanceKmTo(workerLoc);
				return RecommendedWorker(
					workerId: doc.id,
					fullName: data['fullName'] as String? ?? 'Artisan',
					avatarUrl: data['avatarUrl'] as String?,
					averageRating: (data['averageRating'] is num) ? (data['averageRating'] as num).toDouble() : 0.0,
					completedJobs: (data['completedJobs'] as int?) ?? 0,
					distanceKm: distance,
				);
			}).toList();
		});
	}

	static DateTime _parseDate(dynamic v) {
		if (v is Timestamp) return v.toDate();
		if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
		if (v is String) {
			final d = DateTime.tryParse(v);
			if (d != null) return d;
		}
		return DateTime.now();
	}
}