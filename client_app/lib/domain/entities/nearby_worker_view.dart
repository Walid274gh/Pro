import '../value_objects/location.dart';
import '../../core/constants/service_categories.dart';

class NearbyWorkerView {
	final String workerId;
	final String fullName;
	final String? avatarUrl;
	final double averageRating;
	final int completedJobs;
	final bool isOnline;
	final bool isVerified;
	final List<ServiceCategory> categories;
	final Location location;
	final double distanceKm;

	const NearbyWorkerView({
		required this.workerId,
		required this.fullName,
		this.avatarUrl,
		required this.averageRating,
		required this.completedJobs,
		required this.isOnline,
		required this.isVerified,
		required this.categories,
		required this.location,
		required this.distanceKm,
	});
}