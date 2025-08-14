import '../value_objects/time_slot.dart';

class WorkerProposalView {
	final String workerId;
	final String workerName;
	final String? workerAvatarUrl;
	final double workerRating;
	final int workerCompletedJobs;
	final double proposedPrice;
	final String estimatedDuration;
	final String personalMessage;
	final DateTime availableDate;
	final TimeSlot? timeSlot;

	const WorkerProposalView({
		required this.workerId,
		required this.workerName,
		this.workerAvatarUrl,
		required this.workerRating,
		required this.workerCompletedJobs,
		required this.proposedPrice,
		required this.estimatedDuration,
		required this.personalMessage,
		required this.availableDate,
		this.timeSlot,
	});
}