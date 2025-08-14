import '../value_objects/location.dart';
import '../../core/constants/service_categories.dart';

class WorkerStatus {
	final bool isOnline;
	final Location? currentLocation;
	final List<ServiceCategory> availableServices;
	final String? unavailabilityReason;
	final DateTime? nextAvailable;

	const WorkerStatus({
		required this.isOnline,
		this.currentLocation,
		this.availableServices = const <ServiceCategory>[],
		this.unavailabilityReason,
		this.nextAvailable,
	});
}