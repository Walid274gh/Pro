import '../value_objects/location.dart';

/// Domain entity representing a service provider (artisan).
/// Pure value object: immutable and framework-agnostic.
class Worker {
	final String id;
	final String phoneNumber;
	final String fullName;
	final String? avatarUrl;
	final bool isVerified;
	final bool isOnline;
	final Location? currentLocation;
	final List<String> serviceCategories; // category keys; mapped later to enum
	final double averageRating;
	final int completedJobs;
	final DateTime createdAt;
	final DateTime lastActiveAt;
	final DateTime? nextAvailable;

	const Worker({
		required this.id,
		required this.phoneNumber,
		required this.fullName,
		this.avatarUrl,
		this.isVerified = false,
		this.isOnline = false,
		this.currentLocation,
		this.serviceCategories = const <String>[],
		this.averageRating = 0.0,
		this.completedJobs = 0,
		required this.createdAt,
		required this.lastActiveAt,
		this.nextAvailable,
	});

	Worker copyWith({
		String? id,
		String? phoneNumber,
		String? fullName,
		String? avatarUrl,
		bool? isVerified,
		bool? isOnline,
		Location? currentLocation,
		List<String>? serviceCategories,
		double? averageRating,
		int? completedJobs,
		DateTime? createdAt,
		DateTime? lastActiveAt,
		DateTime? nextAvailable,
	}) {
		return Worker(
			id: id ?? this.id,
			phoneNumber: phoneNumber ?? this.phoneNumber,
			fullName: fullName ?? this.fullName,
			avatarUrl: avatarUrl ?? this.avatarUrl,
			isVerified: isVerified ?? this.isVerified,
			isOnline: isOnline ?? this.isOnline,
			currentLocation: currentLocation ?? this.currentLocation,
			serviceCategories: serviceCategories ?? this.serviceCategories,
			averageRating: averageRating ?? this.averageRating,
			completedJobs: completedJobs ?? this.completedJobs,
			createdAt: createdAt ?? this.createdAt,
			lastActiveAt: lastActiveAt ?? this.lastActiveAt,
			nextAvailable: nextAvailable ?? this.nextAvailable,
		);
	}

	@override
	int get hashCode => Object.hash(
		id,
		phoneNumber,
		fullName,
		avatarUrl,
		isVerified,
		isOnline,
		currentLocation,
		Object.hashAll(serviceCategories),
		averageRating,
		completedJobs,
		createdAt,
		lastActiveAt,
		nextAvailable,
	);

	@override
	bool operator ==(Object other) {
		return other is Worker &&
			other.id == id &&
			other.phoneNumber == phoneNumber &&
			other.fullName == fullName &&
			other.avatarUrl == avatarUrl &&
			other.isVerified == isVerified &&
			other.isOnline == isOnline &&
			other.currentLocation == currentLocation &&
			_otherListEquals(other.serviceCategories, serviceCategories) &&
			other.averageRating == averageRating &&
			other.completedJobs == completedJobs &&
			other.createdAt == createdAt &&
			other.lastActiveAt == lastActiveAt &&
			other.nextAvailable == nextAvailable;
	}

	static bool _otherListEquals(List<String> a, List<String> b) {
		if (identical(a, b)) return true;
		if (a.length != b.length) return false;
		for (var i = 0; i < a.length; i++) {
			if (a[i] != b[i]) return false;
		}
		return true;
	}

	@override
	String toString() => 'Worker('+id+' '+fullName+')';
}