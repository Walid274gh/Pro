import '../entities/job_request.dart';
import '../entities/worker_proposal_view.dart';
import '../value_objects/location.dart';
import '../../core/constants/service_categories.dart';

/// Repository contract for job-related operations used by the client app.
/// Implementations will rely on Firebase (Firestore/Functions) but remain hidden
/// behind this abstraction for testability and SOLID compliance.
abstract class JobRepository {
	/// Create a job request and return the generated job id.
	Future<String> createJobRequest(JobRequest request);

	/// Watch proposals for a given job in realtime.
	Stream<List<WorkerProposalView>> watchProposals(String jobId);

	/// Accept a proposal. Implementation should handle transactional updates
	/// (lock the job, notify the worker, etc.).
	Future<void> acceptProposal({required String jobId, required String workerId});

	/// Fetch the user's own jobs as a realtime stream (for history and status updates).
	Stream<List<JobRequest>> watchClientJobs(String clientId);

	/// Optional: discover recommended workers around a location based on category.
	Stream<List<RecommendedWorker>> watchRecommendedWorkers({
		required Location around,
		required double radiusKm,
		required ServiceCategory category,
	});
}

/// Lightweight view for recommended workers in client context.
class RecommendedWorker {
	final String workerId;
	final String fullName;
	final String? avatarUrl;
	final double averageRating;
	final int completedJobs;
	final double distanceKm;

	const RecommendedWorker({
		required this.workerId,
		required this.fullName,
		this.avatarUrl,
		required this.averageRating,
		required this.completedJobs,
		required this.distanceKm,
	});
}