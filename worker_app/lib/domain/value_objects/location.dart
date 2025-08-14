import 'dart:math' as math;

/// Immutable geographic location value object used across the worker app.
/// Provides Firestore conversion helpers and distance calculation.
class Location {
	final double latitude;
	final double longitude;
	final String? addressLine;
	final String? city;
	final String? country;
	final String? placeId;
	final DateTime? timestamp;

	const Location({
		required this.latitude,
		required this.longitude,
		this.addressLine,
		this.city,
		this.country,
		this.placeId,
		this.timestamp,
	});

	bool get isValid =>
		latitude >= -90.0 && latitude <= 90.0 && longitude >= -180.0 && longitude <= 180.0;

	Location copyWith({
		double? latitude,
		double? longitude,
		String? addressLine,
		String? city,
		String? country,
		String? placeId,
		DateTime? timestamp,
	}) {
		return Location(
			latitude: latitude ?? this.latitude,
			longitude: longitude ?? this.longitude,
			addressLine: addressLine ?? this.addressLine,
			city: city ?? this.city,
			country: country ?? this.country,
			placeId: placeId ?? this.placeId,
			timestamp: timestamp ?? this.timestamp,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'lat': latitude,
			'lng': longitude,
			'addressLine': addressLine,
			'city': city,
			'country': country,
			'placeId': placeId,
			'timestamp': timestamp?.toIso8601String(),
		};
	}

	factory Location.fromJson(Map<String, dynamic> json) {
		return Location(
			latitude: (json['lat'] as num).toDouble(),
			longitude: (json['lng'] as num).toDouble(),
			addressLine: json['addressLine'] as String?,
			city: json['city'] as String?,
			country: json['country'] as String?,
			placeId: json['placeId'] as String?,
			timestamp: json['timestamp'] != null
				? DateTime.tryParse(json['timestamp'] as String)
				: null,
		);
	}

	double distanceKmTo(Location other) {
		const double earthRadiusKm = 6371.0;
		final double dLat = _deg2rad(other.latitude - latitude);
		final double dLon = _deg2rad(other.longitude - longitude);
		final double a =
			math.sin(dLat / 2) * math.sin(dLat / 2) +
				math.cos(_deg2rad(latitude)) *
					math.cos(_deg2rad(other.latitude)) *
						math.sin(dLon / 2) * math.sin(dLon / 2);
		final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
		return earthRadiusKm * c;
	}

	static double _deg2rad(double deg) => deg * (math.pi / 180.0);

	@override
	int get hashCode => Object.hash(
		latitude,
		longitude,
		addressLine,
		city,
		country,
		placeId,
		timestamp,
	);

	@override
	bool operator ==(Object other) {
		return other is Location &&
			other.latitude == latitude &&
			other.longitude == longitude &&
			other.addressLine == addressLine &&
			other.city == city &&
			other.country == country &&
			other.placeId == placeId &&
			other.timestamp == timestamp;
	}

	@override
	String toString() =>
		'Location(lat: '+latitude.toString()+', lng: '+longitude.toString()+', city: '+(city ?? '-')+', country: '+(country ?? '-')+')';
}