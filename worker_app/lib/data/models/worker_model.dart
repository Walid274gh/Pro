import '../../domain/entities/worker.dart';
import '../../domain/value_objects/location.dart';

/// Data model used by the data layer to map Worker to/from persistence.
class WorkerModel extends Worker {
	const WorkerModel({
		required super.id,
		required super.phoneNumber,
		required super.fullName,
		super.avatarUrl,
		super.isVerified = false,
		super.isOnline = false,
		super.currentLocation,
		super.serviceCategories = const <String>[],
		super.averageRating = 0.0,
		super.completedJobs = 0,
		required super.createdAt,
		required super.lastActiveAt,
		super.nextAvailable,
	});

	Map<String, dynamic> toMap() {
		return {
			'id': id,
			'phone': phoneNumber,
			'fullName': fullName,
			'avatarUrl': avatarUrl,
			'isVerified': isVerified,
			'isOnline': isOnline,
			'location': currentLocation?.toJson(),
			'serviceCategories': serviceCategories,
			'averageRating': averageRating,
			'completedJobs': completedJobs,
			'createdAt': createdAt.millisecondsSinceEpoch,
			'lastActiveAt': lastActiveAt.millisecondsSinceEpoch,
			'nextAvailable': nextAvailable?.millisecondsSinceEpoch,
		};
	}

	factory WorkerModel.fromMap(Map<String, dynamic> map) {
		return WorkerModel(
			id: map['id'] as String,
			phoneNumber: map['phone'] as String,
			fullName: map['fullName'] as String,
			avatarUrl: map['avatarUrl'] as String?,
			isVerified: (map['isVerified'] as bool?) ?? false,
			isOnline: (map['isOnline'] as bool?) ?? false,
			currentLocation: _parseLocation(map['location']),
			serviceCategories: _parseStringList(map['serviceCategories']),
			averageRating: (map['averageRating'] is num) ? (map['averageRating'] as num).toDouble() : 0.0,
			completedJobs: (map['completedJobs'] as int?) ?? 0,
			createdAt: _parseDate(map['createdAt']),
			lastActiveAt: _parseDate(map['lastActiveAt']),
			nextAvailable: _parseNullableDate(map['nextAvailable']),
		);
	}

	static List<String> _parseStringList(dynamic value) {
		if (value is List) {
			return value.map((e) => e.toString()).toList();
		}
		return const <String>[];
	}

	static Location? _parseLocation(dynamic value) {
		if (value is Map<String, dynamic>) {
			return Location.fromJson(value);
		}
		return null;
	}

	static DateTime _parseDate(dynamic value) {
		if (value is int) {
			return DateTime.fromMillisecondsSinceEpoch(value);
		}
		if (value is String) {
			final parsed = DateTime.tryParse(value);
			if (parsed != null) return parsed;
		}
		return DateTime.fromMillisecondsSinceEpoch(0);
	}

	static DateTime? _parseNullableDate(dynamic value) {
		if (value == null) return null;
		return _parseDate(value);
	}
}