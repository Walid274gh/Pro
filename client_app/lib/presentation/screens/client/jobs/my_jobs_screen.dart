import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../services/job_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../../domain/entities/job_request.dart';
import 'proposals_screen.dart';

class MyJobsScreen extends StatelessWidget {
	const MyJobsScreen({super.key});
	@override
	Widget build(BuildContext context) {
		final auth = context.watch<AuthProvider>();
		final jobService = Provider.of<JobService>(context, listen: false);
		final clientId = auth.currentUser!.id;
		return StreamBuilder<List<JobRequest>>(
			stream: jobService.watchClientJobs(clientId),
			builder: (context, snapshot) {
				if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
				final jobs = snapshot.data!;
				if (jobs.isEmpty) return const Center(child: Text('Aucun travail pour le moment'));
				return ListView.separated(
					padding: const EdgeInsets.all(16),
					itemCount: jobs.length,
					separatorBuilder: (_, __) => const SizedBox(height: 12),
					itemBuilder: (context, index) {
						final j = jobs[index];
						return ListTile(
							title: Text(j.title),
							subtitle: Text('Statut: '+j.status),
							onTap: () {
								Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProposalsScreen(jobId: j.id, jobTitle: j.title)));
							},
							trailing: const Icon(Icons.chevron_right),
							shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
							tileColor: Colors.white,
						);
					},
				);
			},
		);
	}
}