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
import '../../widgets/common/animated_rating.dart';
import '../jobs/job_creation_screen.dart';

class ClientMapScreen extends StatefulWidget {
	const ClientMapScreen({super.key});

	@override
	State<ClientMapScreen> createState() => _ClientMapScreenState();
}

class _ClientMapScreenState extends State<ClientMapScreen> {
	final vo.Location _center = const vo.Location(latitude: 36.7525, longitude: 3.04197);

	void _showWorkerSheet(NearbyWorkerView w) {
		showModalBottomSheet(
			context: context,
			shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
			builder: (_) {
				return Padding(
					padding: const EdgeInsets.all(16),
					child: Column(
						mainAxisSize: MainAxisSize.min,
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Row(children: [
								CircleAvatar(radius: 26, backgroundImage: w.avatarUrl != null ? NetworkImage(w.avatarUrl!) : null, child: w.avatarUrl == null ? const Icon(Icons.person) : null),
								const SizedBox(width: 12),
								Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
									Text(w.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
									Row(children: [AnimatedRating(rating: w.averageRating), const SizedBox(width: 8), Text(w.distanceKm.toStringAsFixed(1)+' km')]),
								])),
							]),
						const SizedBox(height: 12),
						Row(children: [
							Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline), label: const Text('Contacter'))),
							const SizedBox(width: 8),
							Expanded(child: ElevatedButton.icon(onPressed: () { Navigator.of(context).push(MaterialPageRoute(builder: (_) => const JobCreationScreen())); }, icon: const Icon(Icons.event_available), label: const Text('Réserver'))),
						]),
						const SizedBox(height: 8),
					],
				);
			},
		);
	}

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
						builder: (ctx) => GestureDetector(onTap: () => _showWorkerSheet(w), child: _WorkerMarker(worker: w)),
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