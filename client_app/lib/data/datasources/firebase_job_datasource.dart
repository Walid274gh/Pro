import '../models/job_request_model.dart';
import '../../domain/entities/job_request.dart';
import '../../domain/entities/worker_proposal_view.dart';
import '../../core/constants/firestore_paths.dart';

class FirebaseJobDatasource {
	Future<String> createJob(JobRequestModel model) async {
		// TODO: Firestore write
		return 'job_temp_id';
	}

	Stream<List<WorkerProposalView>> watchProposals(String jobId) {
		// TODO: Firestore collection stream
		return const Stream.empty();
	}

	Stream<List<JobRequest>> watchClientJobs(String clientId) {
		// TODO: Firestore stream
		return const Stream.empty();
	}
}