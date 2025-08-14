import '../domain/value_objects/location.dart';

abstract class LocationService {
	Future<void> updateWorkerLocation(String workerId, Location location);
	double distanceKm(Location from, Location to);
}

class LocationServiceImpl implements LocationService {
	@override
	Future<void> updateWorkerLocation(String workerId, Location location) async {
		// TODO: write to Firestore workers/{id}
		return;
	}

	@override
	double distanceKm(Location from, Location to) => from.distanceKmTo(to);
}