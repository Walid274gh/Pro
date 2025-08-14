import '../../domain/entities/client_user.dart';
import '../../domain/value_objects/location.dart';

/// Data model used by the data layer to map ClientUser to/from persistence.
class ClientUserModel extends ClientUser {
	const ClientUserModel({
		required super.id,
		required super.phoneNumber,
		required super.username,
		super.profileImageUrl,
		super.currentLocation,
		super.isPhoneVerified = false,
		super.isBlocked = false,
		required super.createdAt,
		required super.lastActiveAt,
	});

	Map<String, dynamic> toMap() {
		return {
			'id': id,
			'phone': phoneNumber,
			'username': username,
			'avatarUrl': profileImageUrl,
			'location': currentLocation?.toJson(),
			'isPhoneVerified': isPhoneVerified,
			'isBlocked': isBlocked,
			'createdAt': createdAt.millisecondsSinceEpoch,
			'lastActiveAt': lastActiveAt.millisecondsSinceEpoch,
		};
	}

	factory ClientUserModel.fromMap(Map<String, dynamic> map) {
		return ClientUserModel(
			id: map['id'] as String,
			phoneNumber: map['phone'] as String,
			username: map['username'] as String,
			profileImageUrl: map['avatarUrl'] as String?,
			currentLocation: _parseLocation(map['location']),
			isPhoneVerified: (map['isPhoneVerified'] as bool?) ?? false,
			isBlocked: (map['isBlocked'] as bool?) ?? false,
			createdAt: _parseDate(map['createdAt']),
			lastActiveAt: _parseDate(map['lastActiveAt']),
		);
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
}