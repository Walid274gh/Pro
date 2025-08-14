import '../entities/worker_proposal.dart';
import '../entities/worker.dart';
import '../value_objects/location.dart';
import '../../core/constants/service_categories.dart';

abstract class JobRepository {
	/// Stream of open jobs around the worker for a category within a radius.
	Stream<List<OpenJobCard>> watchOpenJobs({
		required Location around,
		required double radiusKm,
		required List<ServiceCategory> categories,
	});

	/// Submit or update a proposal for a job.
	Future<void> submitProposal(WorkerProposal proposal);

	/// Stream the worker's own proposals for status updates.
	Stream<List<WorkerProposal>> watchMyProposals(String workerId);
}

/// Lightweight view for open job cards in worker app.
class OpenJobCard {
	final String jobId;
	final String title;
	final String descriptionPreview;
	final ServiceCategory category;
	final double distanceKm;
	final DateTime preferredDate;

	const OpenJobCard({
		required this.jobId,
		required this.title,
		required this.descriptionPreview,
		required this.category,
		required this.distanceKm,
		required this.preferredDate,
	});
}