import '../value_objects/location.dart';

/// Domain entity representing an authenticated client user.
/// Pure value object: no framework dependencies, immutable and comparable.
class ClientUser {
	final String id;
	final String phoneNumber;
	final String username;
	final String? profileImageUrl;
	final Location? currentLocation;
	final bool isPhoneVerified;
	final bool isBlocked;
	final DateTime createdAt;
	final DateTime lastActiveAt;

	const ClientUser({
		required this.id,
		required this.phoneNumber,
		required this.username,
		this.profileImageUrl,
		this.currentLocation,
		this.isPhoneVerified = false,
		this.isBlocked = false,
		required this.createdAt,
		required this.lastActiveAt,
	});

	ClientUser copyWith({
		String? id,
		String? phoneNumber,
		String? username,
		String? profileImageUrl,
		Location? currentLocation,
		bool? isPhoneVerified,
		bool? isBlocked,
		DateTime? createdAt,
		DateTime? lastActiveAt,
	}) {
		return ClientUser(
			id: id ?? this.id,
			phoneNumber: phoneNumber ?? this.phoneNumber,
			username: username ?? this.username,
			profileImageUrl: profileImageUrl ?? this.profileImageUrl,
			currentLocation: currentLocation ?? this.currentLocation,
			isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
			isBlocked: isBlocked ?? this.isBlocked,
			createdAt: createdAt ?? this.createdAt,
			lastActiveAt: lastActiveAt ?? this.lastActiveAt,
		);
	}

	@override
	int get hashCode => Object.hash(
		id,
		phoneNumber,
		username,
		profileImageUrl,
		currentLocation,
		isPhoneVerified,
		isBlocked,
		createdAt,
		lastActiveAt,
	);

	@override
	bool operator ==(Object other) {
		return other is ClientUser &&
			other.id == id &&
			other.phoneNumber == phoneNumber &&
			other.username == username &&
			other.profileImageUrl == profileImageUrl &&
			other.currentLocation == currentLocation &&
			other.isPhoneVerified == isPhoneVerified &&
			other.isBlocked == isBlocked &&
			other.createdAt == createdAt &&
			other.lastActiveAt == lastActiveAt;
	}

	@override
	String toString() =>
		'ClientUser(id: '+id+', phone: '+phoneNumber+', username: '+username+')';
}