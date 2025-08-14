import '../models/worker_proposal_model.dart';
import '../../domain/repositories/job_repository.dart';
import '../../core/constants/firestore_paths.dart';

class FirebaseJobDatasource {
	Stream<List<OpenJobCard>> watchOpenJobs() {
		// TODO: Firestore geo queries
		return const Stream.empty();
	}

	Future<void> submitProposal(WorkerProposalModel model) async {
		// TODO: Firestore write
		return;
	}

	Stream<List<WorkerProposalModel>> watchMyProposals(String workerId) {
		// TODO: Firestore stream
		return const Stream.empty();
	}
}