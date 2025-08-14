import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../domain/value_objects/location.dart';
import '../../../../domain/entities/nearby_worker_view.dart';
import '../../../../core/constants/service_categories.dart';
import '../../../../services/location_service.dart';
import '../jobs/job_creation_screen.dart';

class ClientHomeScreen extends StatefulWidget {
	const ClientHomeScreen({super.key});

	@override
	State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
	final Location _mockLocation = const Location(latitude: 36.7525, longitude: 3.04197); // Alger centre

	@override
	Widget build(BuildContext context) {
		final locationService = Provider.of<LocationService>(context, listen: false);
		return Scaffold(
			backgroundColor: AppColors.gray50,
			body: SafeArea(
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						Container(
							height: 140,
							padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
							decoration: const BoxDecoration(gradient: AppGradients.secondary, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))),
							child: const Align(
								alignment: Alignment.centerLeft,
								child: Text('Trouver un Artisan', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
							),
						),
						const SizedBox(height: 12),
						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 16),
							child: Row(
								children: [
									Expanded(
										child: Container(
											padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
											decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))]),
											child: const Text('Rechercher un service...', style: TextStyle(color: AppColors.gray600)),
										),
									),
									const SizedBox(width: 12),
									ElevatedButton(
										onPressed: () {
											Navigator.of(context).push(MaterialPageRoute(builder: (_) => const JobCreationScreen()));
										},
										child: const Text('Créer un job'),
									),
								],
							),
						),
						const SizedBox(height: 16),
						Expanded(
							child: StreamBuilder<List<NearbyWorkerView>>(
								stream: locationService.watchNearbyWorkers(center: _mockLocation, radiusKm: 10, categories: const [ServiceCategory.cleaning]),
								builder: (context, snapshot) {
									if (!snapshot.hasData) {
										return const Center(child: CircularProgressIndicator());
									}
									final workers = snapshot.data!;
									return ListView.separated(
										padding: const EdgeInsets.all(16),
										itemCount: workers.length,
										separatorBuilder: (_, __) => const SizedBox(height: 12),
										itemBuilder: (context, index) {
											final w = workers[index];
											return Container(
												decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))]),
												padding: const EdgeInsets.all(16),
												child: Row(
													children: [
														CircleAvatar(radius: 24, backgroundImage: w.avatarUrl != null ? NetworkImage(w.avatarUrl!) : null, child: w.avatarUrl == null ? const Icon(Icons.person) : null),
														const SizedBox(width: 12),
														Expanded(
															child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
																Text(w.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
																Text(w.distanceKm.toStringAsFixed(1)+' km • '+w.averageRating.toStringAsFixed(1)+'★'),
															]),
														),
														ElevatedButton(onPressed: () {}, child: const Text('Réserver')),
													],
												),
											);
										},
									);
								},
							),
						),
					],
				),
			),
		);
	}
}