import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/constants/service_categories.dart';
import '../../domain/entities/nearby_worker_view.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/value_objects/location.dart';
import '../../services/firebase_service.dart';
import '../..//services/geohash.dart';

class LocationRepositoryImpl implements LocationRepository {
	FirebaseFirestore get _db => FirebaseService.db;

	@override
	Stream<List<NearbyWorkerView>> watchNearbyWorkers({required Location around, required double radiusKm, List<ServiceCategory>? categories}) {
		final hash = GeoHashUtil.encode(around.latitude, around.longitude, precision: 5);
		Query<Map<String, dynamic>> q = _db
			.collection(FirestorePaths.workers)
			.where('isOnline', isEqualTo: true)
			.where('geohash', isGreaterThanOrEqualTo: hash)
			.where('geohash', isLessThan: hash+'~') // simple prefix range
			.limit(100);
		if (categories != null && categories.isNotEmpty) {
			q = q.where('serviceCategories', arrayContainsAny: categories.map((e) => e.key).toList());
		}
		return q.snapshots().map((snapshot) => snapshot.docs.map((doc) {
			final data = doc.data();
			final loc = data['location'] as Map<String, dynamic>?;
			final workerLoc = loc != null
				? Location.fromJson(Map<String, dynamic>.from(loc))
				: Location(latitude: 0, longitude: 0);
			return NearbyWorkerView(
				workerId: doc.id,
				fullName: data['fullName'] as String? ?? 'Artisan',
				avatarUrl: data['avatarUrl'] as String?,
				averageRating: (data['averageRating'] is num) ? (data['averageRating'] as num).toDouble() : 0.0,
				completedJobs: (data['completedJobs'] as int?) ?? 0,
				isOnline: (data['isOnline'] as bool?) ?? false,
				categories: ((data['serviceCategories'] as List?) ?? const <dynamic>[]).map((e) => ServiceCategory.fromKey(e.toString())).toList(),
				location: workerLoc,
				distanceKm: around.distanceKmTo(workerLoc),
			);
		}).toList());
	}
}