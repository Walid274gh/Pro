import 'package:flutter_test/flutter_test.dart';
import 'package:client_app/domain/value_objects/location.dart';

void main() {
	group('Location.distanceKmTo', () {
		test('returns ~1.5 km between two close points in Algiers', () {
			const a = Location(latitude: 36.7525, longitude: 3.04197);
			const b = Location(latitude: 36.7630, longitude: 3.0540);
			final d = a.distanceKmTo(b);
			expect(d, greaterThan(1.0));
			expect(d, lessThan(2.5));
		});

		test('zero distance to itself', () {
			const a = Location(latitude: 36.7525, longitude: 3.04197);
			expect(a.distanceKmTo(a), closeTo(0.0, 1e-9));
		});
	});
}