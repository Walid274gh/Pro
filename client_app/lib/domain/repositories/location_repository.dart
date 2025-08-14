import '../value_objects/location.dart';
import '../entities/nearby_worker_view.dart';
import '../../core/constants/service_categories.dart';

abstract class LocationRepository {
	Stream<List<NearbyWorkerView>> watchNearbyWorkers({
		required Location around,
		required double radiusKm,
		List<ServiceCategory>? categories,
	});
}