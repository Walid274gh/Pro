import '../../core/constants/service_categories.dart';
import '../value_objects/location.dart';
import '../value_objects/time_slot.dart';

class JobRequest {
	final String id;
	final String title;
	final String description;
	final List<String> mediaUrls;
	final ServiceCategory category;
	final DateTime preferredDate;
	final TimeSlot timeSlot;
	final Location workLocation;
	final double? budgetMax;
	final String clientId;
	final DateTime createdAt;
	final String status; // draft, open, accepted, completed, canceled

	const JobRequest({
		required this.id,
		required this.title,
		required this.description,
		this.mediaUrls = const <String>[],
		required this.category,
		required this.preferredDate,
		required this.timeSlot,
		required this.workLocation,
		this.budgetMax,
		required this.clientId,
		required this.createdAt,
		this.status = 'open',
	});

	JobRequest copyWith({
		String? id,
		String? title,
		String? description,
		List<String>? mediaUrls,
		ServiceCategory? category,
		DateTime? preferredDate,
		TimeSlot? timeSlot,
		Location? workLocation,
		double? budgetMax,
		String? clientId,
		DateTime? createdAt,
		String? status,
	}) {
		return JobRequest(
			id: id ?? this.id,
			title: title ?? this.title,
			description: description ?? this.description,
			mediaUrls: mediaUrls ?? this.mediaUrls,
			category: category ?? this.category,
			preferredDate: preferredDate ?? this.preferredDate,
			timeSlot: timeSlot ?? this.timeSlot,
			workLocation: workLocation ?? this.workLocation,
			budgetMax: budgetMax ?? this.budgetMax,
			clientId: clientId ?? this.clientId,
			createdAt: createdAt ?? this.createdAt,
			status: status ?? this.status,
		);
	}

	@override
	int get hashCode => Object.hash(
		id,
		title,
		description,
		Object.hashAll(mediaUrls),
		category,
		preferredDate,
		timeSlot,
		workLocation,
		budgetMax,
		clientId,
		createdAt,
		status,
	);

	@override
	bool operator ==(Object other) {
		return other is JobRequest &&
			other.id == id &&
			other.title == title &&
			other.description == description &&
			_listEquals(other.mediaUrls, mediaUrls) &&
			other.category == category &&
			other.preferredDate == preferredDate &&
			other.timeSlot == timeSlot &&
			other.workLocation == workLocation &&
			other.budgetMax == budgetMax &&
			other.clientId == clientId &&
			other.createdAt == createdAt &&
			other.status == status;
	}

	static bool _listEquals(List<String> a, List<String> b) {
		if (identical(a, b)) return true;
		if (a.length != b.length) return false;
		for (var i = 0; i < a.length; i++) {
			if (a[i] != b[i]) return false;
		}
		return true;
	}
}