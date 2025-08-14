import '../../domain/entities/worker_proposal.dart';
import '../../domain/value_objects/time_slot.dart';

class WorkerProposalModel extends WorkerProposal {
	const WorkerProposalModel({
		required super.id,
		required super.workerId,
		required super.jobId,
		required super.proposedPrice,
		required super.estimatedDuration,
		required super.personalMessage,
		required super.availableDate,
		super.timeSlot,
		required super.createdAt,
	});

	Map<String, dynamic> toMap() {
		return {
			'id': id,
			'workerId': workerId,
			'jobId': jobId,
			'proposedPrice': proposedPrice,
			'estimatedDuration': estimatedDuration,
			'personalMessage': personalMessage,
			'availableDate': availableDate.millisecondsSinceEpoch,
			'timeSlot': timeSlot?.toJson(),
			'createdAt': createdAt.millisecondsSinceEpoch,
		};
	}

	factory WorkerProposalModel.fromMap(Map<String, dynamic> map) {
		return WorkerProposalModel(
			id: map['id'] as String,
			workerId: map['workerId'] as String,
			jobId: map['jobId'] as String,
			proposedPrice: (map['proposedPrice'] as num).toDouble(),
			estimatedDuration: map['estimatedDuration'] as String,
			personalMessage: map['personalMessage'] as String,
			availableDate: _parseDate(map['availableDate']),
			timeSlot: _parseTimeSlot(map['timeSlot']),
			createdAt: _parseDate(map['createdAt']),
		);
	}

	static DateTime _parseDate(dynamic value) {
		if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
		if (value is String) {
			final parsed = DateTime.tryParse(value);
			if (parsed != null) return parsed;
		}
		return DateTime.fromMillisecondsSinceEpoch(0);
	}

	static TimeSlot? _parseTimeSlot(dynamic value) {
		if (value is Map) {
			return TimeSlot.fromJson(Map<String, dynamic>.from(value as Map));
		}
		return null;
	}
}