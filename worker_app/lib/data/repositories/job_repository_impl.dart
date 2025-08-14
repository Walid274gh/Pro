import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../domain/entities/worker_proposal.dart';
import '../../domain/repositories/job_repository.dart';
import '../../domain/value_objects/location.dart';
import '../../core/constants/service_categories.dart';
import '../../services/firebase_service.dart';
import '../models/worker_proposal_model.dart';

class JobRepositoryImpl implements JobRepository {
	FirebaseFirestore get _db => FirebaseService.db;

	@override
	Stream<List<OpenJobCard>> watchOpenJobs({
		required Location around,
		required double radiusKm,
		required List<ServiceCategory> categories,
	}) {
		// Placeholder: filter by category only; geo filtering would need geohashes or a function.
		final ref = _db.collection(FirestorePaths.jobs)
			.where('status', isEqualTo: 'open')
			.where('category', whereIn: categories.map((e) => e.key).toList())
			.orderBy('createdAt', descending: true)
			.limit(50);
		return ref.snapshots().map((snapshot) => snapshot.docs.map((doc) {
			final data = doc.data();
			final loc = data['workLocation'] as Map<String, dynamic>?;
			final jobLoc = loc != null
				? Location.fromJson(Map<String, dynamic>.from(loc))
				: Location(latitude: 0, longitude: 0);
			final distance = around.distanceKmTo(jobLoc);
			return OpenJobCard(
				jobId: doc.id,
				title: data['title'] as String? ?? 'Travail',
				descriptionPreview: (data['description'] as String? ?? '').substring(0, ((data['description'] as String? ?? '').length).clamp(0, 80)),
				category: ServiceCategory.fromKey(data['category'] as String),
				distanceKm: distance,
				preferredDate: _parseDate(data['preferredDate']),
			);
		}).toList());
	}

	@override
	Future<void> submitProposal(WorkerProposal proposal) async {
		final model = WorkerProposalModel(
			id: proposal.id,
			workerId: proposal.workerId,
			jobId: proposal.jobId,
			proposedPrice: proposal.proposedPrice,
			estimatedDuration: proposal.estimatedDuration,
			personalMessage: proposal.personalMessage,
			availableDate: proposal.availableDate,
			timeSlot: proposal.timeSlot,
			createdAt: DateTime.now(),
		);
		final ref = _db.collection(FirestorePaths.proposals).doc();
		await ref.set({
			...model.toMap(),
			'id': ref.id,
			'createdAt': FieldValue.serverTimestamp(),
		});
	}

	@override
	Stream<List<WorkerProposal>> watchMyProposals(String workerId) {
		final ref = _db.collection(FirestorePaths.proposals)
			.where('workerId', isEqualTo: workerId)
			.orderBy('createdAt', descending: true);
		return ref.snapshots().map((snapshot) => snapshot.docs.map((doc) {
			final data = doc.data();
			return WorkerProposalModel.fromMap(data);
		}).toList());
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