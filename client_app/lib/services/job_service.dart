import '../domain/entities/job_request.dart';
import '../domain/entities/worker_proposal_view.dart';
import '../domain/repositories/job_repository.dart';
import '../domain/value_objects/location.dart';
import '../domain/entities/job_rating.dart';
import '../core/constants/service_categories.dart';

abstract class JobService {
	Future<String> createJob(JobRequest request);
	Stream<List<WorkerProposalView>> watchProposals(String jobId);
	Future<void> acceptProposal(String jobId, String workerId);
	Stream<List<JobRequest>> watchClientJobs(String clientId);
	Stream<List<RecommendedWorker>> watchRecommendedWorkers({
		required Location around,
		required double radiusKm,
		required ServiceCategory category,
	});
}

class JobServiceImpl implements JobService {
	final JobRepository _repository;
	JobServiceImpl(this._repository);

	@override
	Future<String> createJob(JobRequest request) => _repository.createJobRequest(request);

	@override
	Stream<List<WorkerProposalView>> watchProposals(String jobId) => _repository.watchProposals(jobId);

	@override
	Future<void> acceptProposal(String jobId, String workerId) => _repository.acceptProposal(jobId: jobId, workerId: workerId);

	@override
	Stream<List<JobRequest>> watchClientJobs(String clientId) => _repository.watchClientJobs(clientId);

	@override
	Stream<List<RecommendedWorker>> watchRecommendedWorkers({required Location around, required double radiusKm, required ServiceCategory category}) =>
			_repository.watchRecommendedWorkers(around: around, radiusKm: radiusKm, category: category);
}