import 'package:flutter_test/flutter_test.dart';
import 'package:worker_app/data/models/worker_model.dart';

void main() {
	test('WorkerModel toMap/fromMap round-trip', () {
		final model = WorkerModel(
			id: 'wid',
			phoneNumber: '+213555000111',
			fullName: 'Artisan Test',
			avatarUrl: 'http://example.com/a.jpg',
			isVerified: true,
			isOnline: true,
			serviceCategories: const ['cleaning', 'plumbing'],
			averageRating: 4.6,
			completedJobs: 42,
			createdAt: DateTime(2025, 1, 1),
			lastActiveAt: DateTime(2025, 1, 2),
			nextAvailable: DateTime(2025, 1, 3),
		);

		final map = model.toMap();
		final parsed = WorkerModel.fromMap(map);
		expect(parsed.id, 'wid');
		expect(parsed.fullName, 'Artisan Test');
		expect(parsed.isVerified, true);
		expect(parsed.serviceCategories.length, 2);
		expect(parsed.averageRating, greaterThan(4.0));
	});
}