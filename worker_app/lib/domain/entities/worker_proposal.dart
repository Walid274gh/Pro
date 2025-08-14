import '../value_objects/time_slot.dart';

class WorkerProposal {
	final String id;
	final String workerId;
	final String jobId;
	final double proposedPrice;
	final String estimatedDuration;
	final String personalMessage;
	final DateTime availableDate;
	final TimeSlot? timeSlot;
	final DateTime createdAt;

	const WorkerProposal({
		required this.id,
		required this.workerId,
		required this.jobId,
		required this.proposedPrice,
		required this.estimatedDuration,
		required this.personalMessage,
		required this.availableDate,
		this.timeSlot,
		required this.createdAt,
	});

	WorkerProposal copyWith({
		String? id,
		String? workerId,
		String? jobId,
		double? proposedPrice,
		String? estimatedDuration,
		String? personalMessage,
		DateTime? availableDate,
		TimeSlot? timeSlot,
		DateTime? createdAt,
	}) {
		return WorkerProposal(
			id: id ?? this.id,
			workerId: workerId ?? this.workerId,
			jobId: jobId ?? this.jobId,
			proposedPrice: proposedPrice ?? this.proposedPrice,
			estimatedDuration: estimatedDuration ?? this.estimatedDuration,
			personalMessage: personalMessage ?? this.personalMessage,
			availableDate: availableDate ?? this.availableDate,
			timeSlot: timeSlot ?? this.timeSlot,
			createdAt: createdAt ?? this.createdAt,
		);
	}

	@override
	int get hashCode => Object.hash(
		id,
		workerId,
		jobId,
		proposedPrice,
		estimatedDuration,
		personalMessage,
		availableDate,
		timeSlot,
		createdAt,
	);

	@override
	bool operator ==(Object other) {
		return other is WorkerProposal &&
			other.id == id &&
			other.workerId == workerId &&
			other.jobId == jobId &&
			other.proposedPrice == proposedPrice &&
			other.estimatedDuration == estimatedDuration &&
			other.personalMessage == personalMessage &&
			other.availableDate == availableDate &&
			other.timeSlot == timeSlot &&
			other.createdAt == createdAt;
	}
}