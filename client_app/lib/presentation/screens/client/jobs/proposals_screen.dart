import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../services/job_service.dart';
import '../../../../domain/entities/worker_proposal_view.dart';

class ProposalsScreen extends StatelessWidget {
	final String jobId;
	final String jobTitle;
	const ProposalsScreen({super.key, required this.jobId, required this.jobTitle});

	@override
	Widget build(BuildContext context) {
		final jobService = Provider.of<JobService>(context, listen: false);
		return Scaffold(
			appBar: AppBar(title: Text('Propositions • '+jobTitle)),
			body: StreamBuilder<List<WorkerProposalView>>(
				stream: jobService.watchProposals(jobId),
				builder: (context, snapshot) {
					if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
					final proposals = snapshot.data!;
					if (proposals.isEmpty) return const Center(child: Text('Aucune proposition reçue pour le moment'));
					return ListView.separated(
						padding: const EdgeInsets.all(16),
						itemCount: proposals.length,
						separatorBuilder: (_, __) => const SizedBox(height: 12),
						itemBuilder: (context, index) {
							final p = proposals[index];
							return ListTile(
								leading: CircleAvatar(backgroundImage: p.workerAvatarUrl != null ? NetworkImage(p.workerAvatarUrl!) : null, child: p.workerAvatarUrl == null ? const Icon(Icons.person) : null),
								title: Text(p.workerName),
								subtitle: Text(p.proposedPrice.toStringAsFixed(0)+' DA • '+p.workerRating.toStringAsFixed(1)+'★'),
								trailing: ElevatedButton(
									onPressed: () async {
										await jobService.acceptProposal(jobId, p.workerId);
										if (context.mounted) Navigator.of(context).pop();
									},
									child: const Text('Accepter'),
								),
								shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
								tileColor: Colors.white,
							);
						},
					);
				},
			),
		);
	}
}