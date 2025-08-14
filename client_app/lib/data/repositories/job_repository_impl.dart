import 'dart:async';

import '../../domain/entities/job_request.dart';
import '../../domain/entities/worker_proposal_view.dart';
import '../../domain/repositories/job_repository.dart';
import '../../domain/value_objects/location.dart';
import '../../core/constants/service_categories.dart';

/// Placeholder implementation to be wired with Firebase later.
class JobRepositoryImpl implements JobRepository {
	@override
	Future<String> createJobRequest(JobRequest request) async {
		// TODO: integrate with Firestore
		return Future.value('job_temp_id');
	}

	@override
	Stream<List<WorkerProposalView>> watchProposals(String jobId) {
		// TODO: stream from Firestore
		return const Stream.empty();
	}

	@override
	Future<void> acceptProposal({required String jobId, required String workerId}) async {
		// TODO: transaction in Firestore/Functions
		return;
	}

	@override
	Stream<List<JobRequest>> watchClientJobs(String clientId) {
		// TODO: stream from Firestore
		return const Stream.empty();
	}

	@override
	Stream<List<RecommendedWorker>> watchRecommendedWorkers({
		required Location around,
		required double radiusKm,
		required ServiceCategory category,
	}) {
		// TODO: geoqueries + ranking
		return const Stream.empty();
	}
}