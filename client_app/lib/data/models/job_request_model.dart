import '../../core/constants/service_categories.dart';
import '../../domain/entities/job_request.dart';
import '../../domain/value_objects/location.dart';
import '../../domain/value_objects/time_slot.dart';

class JobRequestModel extends JobRequest {
	const JobRequestModel({
		required super.id,
		required super.title,
		required super.description,
		super.mediaUrls = const <String>[],
		required super.category,
		required super.preferredDate,
		required super.timeSlot,
		required super.workLocation,
		super.budgetMax,
		required super.clientId,
		required super.createdAt,
		super.status = 'open',
	});

	Map<String, dynamic> toMap() {
		return {
			'id': id,
			'title': title,
			'description': description,
			'mediaUrls': mediaUrls,
			'category': category.key,
			'preferredDate': preferredDate.millisecondsSinceEpoch,
			'timeSlot': timeSlot.toJson(),
			'workLocation': workLocation.toJson(),
			'budgetMax': budgetMax,
			'clientId': clientId,
			'createdAt': createdAt.millisecondsSinceEpoch,
			'status': status,
		};
	}

	factory JobRequestModel.fromMap(Map<String, dynamic> map) {
		return JobRequestModel(
			id: map['id'] as String,
			title: map['title'] as String,
			description: map['description'] as String,
			mediaUrls: _parseStringList(map['mediaUrls']),
			category: ServiceCategory.fromKey(map['category'] as String),
			preferredDate: _parseDate(map['preferredDate']),
			timeSlot: TimeSlot.fromJson(Map<String, dynamic>.from(map['timeSlot'] as Map)),
			workLocation: Location.fromJson(Map<String, dynamic>.from(map['workLocation'] as Map)),
			budgetMax: (map['budgetMax'] is num) ? (map['budgetMax'] as num).toDouble() : null,
			clientId: map['clientId'] as String,
			createdAt: _parseDate(map['createdAt']),
			status: map['status'] as String? ?? 'open',
		);
	}

	static List<String> _parseStringList(dynamic value) {
		if (value is List) {
			return value.map((e) => e.toString()).toList();
		}
		return const <String>[];
	}

	static DateTime _parseDate(dynamic value) {
		if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
		if (value is String) {
			final parsed = DateTime.tryParse(value);
			if (parsed != null) return parsed;
		}
		return DateTime.fromMillisecondsSinceEpoch(0);
	}
}