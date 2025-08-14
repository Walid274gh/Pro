import 'package:flutter_test/flutter_test.dart';
import 'package:client_app/data/models/job_request_model.dart';
import 'package:client_app/core/constants/service_categories.dart';
import 'package:client_app/domain/value_objects/time_slot.dart';
import 'package:client_app/domain/value_objects/location.dart';

void main() {
	test('JobRequestModel toMap/fromMap round trip', () {
		final model = JobRequestModel(
			id: 'jid',
			title: 'Peinture salon',
			description: 'Peindre 20m²',
			mediaUrls: const ['u1', 'u2'],
			category: ServiceCategory.painting,
			preferredDate: DateTime(2025, 1, 1),
			timeSlot: const TimeSlot(startMinutes: 9*60, endMinutes: 11*60),
			workLocation: const Location(latitude: 36.75, longitude: 3.04),
			budgetMax: 5000,
			clientId: 'cid',
			createdAt: DateTime(2025, 1, 1),
			status: 'open',
			acceptedWorkerId: 'wid',
		);
		final map = model.toMap();
		final parsed = JobRequestModel.fromMap(map);
		expect(parsed.id, 'jid');
		expect(parsed.category, ServiceCategory.painting);
		expect(parsed.mediaUrls.length, 2);
		expect(parsed.acceptedWorkerId, 'wid');
	});
}