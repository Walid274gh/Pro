import 'dart:async';

import '../../domain/entities/worker_proposal.dart';
import '../../domain/repositories/job_repository.dart';
import '../../domain/value_objects/location.dart';
import '../../core/constants/service_categories.dart';

class JobRepositoryImpl implements JobRepository {
	@override
	Stream<List<OpenJobCard>> watchOpenJobs({
		required Location around,
		required double radiusKm,
		required List<ServiceCategory> categories,
	}) {
		// TODO: connect to Firestore geoqueries
		return const Stream.empty();
	}

	@override
	Future<void> submitProposal(WorkerProposal proposal) async {
		// TODO: write to Firestore collection
		return;
	}

	@override
	Stream<List<WorkerProposal>> watchMyProposals(String workerId) {
		// TODO: stream proposals by workerId
		return const Stream.empty();
	}
}