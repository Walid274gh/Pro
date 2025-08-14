import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../domain/value_objects/location.dart' as vo;
import '../../../../services/location_service.dart';
import '../../../../domain/entities/nearby_worker_view.dart';
import '../../../../core/constants/service_categories.dart';
import '../../../../core/themes/app_colors.dart';

class ClientMapScreen extends StatefulWidget {
	const ClientMapScreen({super.key});

	@override
	State<ClientMapScreen> createState() => _ClientMapScreenState();
}

class _ClientMapScreenState extends State<ClientMapScreen> {
	final vo.Location _center = const vo.Location(latitude: 36.7525, longitude: 3.04197);

	@override
	Widget build(BuildContext context) {
		final locationService = Provider.of<LocationService>(context, listen: false);
		return Scaffold(
			appBar: AppBar(title: const Text('Artisans à proximité')),
			body: StreamBuilder<List<NearbyWorkerView>>(
				stream: locationService.watchNearbyWorkers(center: _center, radiusKm: 10, categories: const [ServiceCategory.cleaning, ServiceCategory.plumbing, ServiceCategory.electricity]),
				builder: (context, snapshot) {
					final workers = snapshot.data ?? const <NearbyWorkerView>[];
					final markers = workers.map((w) => Marker(
						point: LatLng(w.location.latitude, w.location.longitude),
						width: 44,
						height: 44,
						builder: (ctx) => _WorkerMarker(worker: w),
					)).toList();
					return FlutterMap(
						options: MapOptions(
							initialCenter: LatLng(_center.latitude, _center.longitude),
							initialZoom: 12,
						),
						children: [
							TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.khidmeti.client'),
							MarkerClusterLayerWidget(
								options: MarkerClusterLayerOptions(
									maxClusterRadius: 45,
									spiderfyCircleRadius: 60,
									fitBoundsOptions: const FitBoundsOptions(padding: EdgeInsets.all(32)),
									markers: markers,
									builder: (context, cluster) => Container(
										decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppGradients.accent),
										padding: const EdgeInsets.all(10),
										child: Text(cluster.count.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
									),
								),
							),
						],
					);
				},
			),
		);
	}
}

class _WorkerMarker extends StatelessWidget {
	final NearbyWorkerView worker;
	const _WorkerMarker({required this.worker});
	@override
	Widget build(BuildContext context) {
		return Tooltip(
			message: worker.fullName+' • '+worker.averageRating.toStringAsFixed(1)+'★',
			child: Container(
				decoration: BoxDecoration(
					shape: BoxShape.circle,
					gradient: AppGradients.primary,
					boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
				),
				child: const Icon(Icons.handyman, color: Colors.white, size: 22),
			),
		);
	}
}