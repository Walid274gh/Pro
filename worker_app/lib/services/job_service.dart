import '../domain/repositories/job_repository.dart';
import '../domain/entities/worker_proposal.dart';
import '../domain/value_objects/location.dart';
import '../core/constants/service_categories.dart';

abstract class JobService {
	Stream<List<OpenJobCard>> watchOpenJobs({required Location around, required double radiusKm, required List<ServiceCategory> categories});
	Future<void> submitProposal(WorkerProposal proposal);
	Stream<List<WorkerProposal>> watchMyProposals(String workerId);
}

class JobServiceImpl implements JobService {
	final JobRepository _repository;
	JobServiceImpl(this._repository);

	@override
	Stream<List<OpenJobCard>> watchOpenJobs({required Location around, required double radiusKm, required List<ServiceCategory> categories}) =>
			_repository.watchOpenJobs(around: around, radiusKm: radiusKm, categories: categories);

	@override
	Future<void> submitProposal(WorkerProposal proposal) => _repository.submitProposal(proposal);

	@override
	Stream<List<WorkerProposal>> watchMyProposals(String workerId) => _repository.watchMyProposals(workerId);
}