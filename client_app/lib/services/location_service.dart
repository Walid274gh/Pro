import '../domain/repositories/location_repository.dart';
import '../domain/entities/nearby_worker_view.dart';
import '../domain/value_objects/location.dart';
import '../core/constants/service_categories.dart';

abstract class LocationService {
	Stream<List<NearbyWorkerView>> watchNearbyWorkers({required Location center, required double radiusKm, List<ServiceCategory>? categories});
	double distanceKm(Location from, Location to);
}

class LocationServiceImpl implements LocationService {
	final LocationRepository _repository;
	LocationServiceImpl(this._repository);

	@override
	Stream<List<NearbyWorkerView>> watchNearbyWorkers({required Location center, required double radiusKm, List<ServiceCategory>? categories}) {
		return _repository.watchNearbyWorkers(around: center, radiusKm: radiusKm, categories: categories);
	}

	@override
	double distanceKm(Location from, Location to) => from.distanceKmTo(to);
}