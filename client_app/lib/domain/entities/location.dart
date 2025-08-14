import 'dart:math' as math;

/// Represents a geographic coordinate with optional address metadata.
class Location {
	final double latitude;
	final double longitude;
	final String? addressLine;
	final String? city;
	final String? countryCode;

	const Location({
		required this.latitude,
		required this.longitude,
		this.addressLine,
		this.city,
		this.countryCode,
	});

	Location copyWith({
		double? latitude,
		double? longitude,
		String? addressLine,
		String? city,
		String? countryCode,
	}) {
		return Location(
			latitude: latitude ?? this.latitude,
			longitude: longitude ?? this.longitude,
			addressLine: addressLine ?? this.addressLine,
			city: city ?? this.city,
			countryCode: countryCode ?? this.countryCode,
		);
	}

	Map<String, dynamic> toJson() => {
		'lat': latitude,
		'lng': longitude,
		'addressLine': addressLine,
		'city': city,
		'countryCode': countryCode,
	};

	factory Location.fromJson(Map<String, dynamic> json) {
		return Location(
			latitude: (json['lat'] as num).toDouble(),
			longitude: (json['lng'] as num).toDouble(),
			addressLine: json['addressLine'] as String?,
			city: json['city'] as String?,
			countryCode: json['countryCode'] as String?,
		);
	}

	@override
	bool operator ==(Object other) {
		return other is Location &&
			other.latitude == latitude &&
			other.longitude == longitude &&
			other.addressLine == addressLine &&
			other.city == city &&
			other.countryCode == countryCode;
	}

	@override
	int get hashCode => Object.hash(latitude, longitude, addressLine, city, countryCode);

	/// Haversine distance in meters between this location and [other].
	double distanceTo(Location other) {
		const double earthRadiusMeters = 6371000;
		final double dLat = _toRad(other.latitude - latitude);
		final double dLng = _toRad(other.longitude - longitude);
		final double a =
			math.sin(dLat / 2) * math.sin(dLat / 2) +
			math.cos(_toRad(latitude)) * math.cos(_toRad(other.latitude)) *
			math.sin(dLng / 2) * math.sin(dLng / 2);
		final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
		return earthRadiusMeters * c;
	}

	static double _toRad(double deg) => deg * math.pi / 180.0;

	@override
	String toString() => 'Location(lat: '+latitude.toString()+', lng: '+longitude.toString()+', city: '+(city ?? '-')+', country: '+(countryCode ?? '-')+')';
}