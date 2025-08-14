import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../domain/value_objects/location.dart';
import '../../../../core/constants/service_categories.dart';
import '../../../../domain/repositories/job_repository.dart';
import '../../../../services/job_service.dart';
import '../proposal/proposal_form_screen.dart';
import '../../../providers/auth_provider.dart';

class WorkerDashboardScreen extends StatefulWidget {
	const WorkerDashboardScreen({super.key});

	@override
	State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
	final Location _mockLocation = const Location(latitude: 36.7525, longitude: 3.04197);
	final String _mockWorkerId = 'me';

	@override
	Widget build(BuildContext context) {
		final jobService = Provider.of<JobService>(context, listen: false);
		final worker = context.watch<AuthProvider>().currentWorker;
		return Scaffold(
			backgroundColor: AppColors.gray50,
			appBar: AppBar(
				title: Row(children: [
					const Text('Demandes à proximité'),
					const SizedBox(width: 8),
					if ((worker?.isVerified ?? false)) const Icon(Icons.verified, color: Colors.lightBlue, size: 18),
				]),
			),
			body: StreamBuilder<List<OpenJobCard>>(
				stream: jobService.watchOpenJobs(around: _mockLocation, radiusKm: 10, categories: const [ServiceCategory.cleaning, ServiceCategory.plumbing]),
				builder: (context, snapshot) {
					if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
					final jobs = snapshot.data!;
					return ListView.separated(
						padding: const EdgeInsets.all(16),
						itemCount: jobs.length,
						separatorBuilder: (_, __) => const SizedBox(height: 12),
						itemBuilder: (context, index) {
							final j = jobs[index];
							return Container(
								padding: const EdgeInsets.all(16),
								decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))]),
								child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
									Text(j.title, style: const TextStyle(fontWeight: FontWeight.w600)),
									Text(j.category.name+' • '+j.distanceKm.toStringAsFixed(1)+' km'),
									const SizedBox(height: 8),
									Row(children: [
										ElevatedButton(
											onPressed: () {
											Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProposalFormScreen(jobId: j.jobId, workerId: _mockWorkerId)));
										},
											child: const Text('Proposer'),
										),
									]),
								]),
							);
						},
					);
				},
			),
		);
	}
}