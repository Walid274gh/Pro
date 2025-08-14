import '../domain/value_objects/location.dart';
import 'geohash.dart';
import 'firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_paths.dart';

abstract class LocationService {
	Future<void> updateWorkerLocation(String workerId, Location location);
	double distanceKm(Location from, Location to);
}

class LocationServiceImpl implements LocationService {
	@override
	Future<void> updateWorkerLocation(String workerId, Location location) async {
		final hash = GeoHashUtil.encode(location.latitude, location.longitude, precision: 9);
		await FirebaseService.db.collection(FirestorePaths.workers).doc(workerId).update({
			'location': location.toJson(),
			'geohash': hash,
			'lastSeen': FieldValue.serverTimestamp(),
		});
	}

	@override
	double distanceKm(Location from, Location to) => from.distanceKmTo(to);
}