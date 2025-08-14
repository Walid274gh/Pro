import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/worker_proposal.dart';
import '../../../../services/job_service.dart';

class ProposalFormScreen extends StatefulWidget {
	final String jobId;
	final String workerId;
	const ProposalFormScreen({super.key, required this.jobId, required this.workerId});

	@override
	State<ProposalFormScreen> createState() => _ProposalFormScreenState();
}

class _ProposalFormScreenState extends State<ProposalFormScreen> {
	final TextEditingController _price = TextEditingController();
	final TextEditingController _duration = TextEditingController(text: '2h');
	final TextEditingController _message = TextEditingController();

	@override
	Widget build(BuildContext context) {
		final jobService = Provider.of<JobService>(context, listen: false);
		return Scaffold(
			appBar: AppBar(title: const Text('Envoyer une proposition')),
			body: Padding(
				padding: const EdgeInsets.all(16),
				child: Column(children: [
					TextField(controller: _price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prix proposé (DA)')),
					const SizedBox(height: 12),
					TextField(controller: _duration, decoration: const InputDecoration(labelText: 'Durée estimée')),
					const SizedBox(height: 12),
					TextField(controller: _message, decoration: const InputDecoration(labelText: 'Message')), 
					const SizedBox(height: 20),
					ElevatedButton(
						onPressed: () async {
							final p = WorkerProposal(
								id: 'local',
								workerId: widget.workerId,
								jobId: widget.jobId,
								proposedPrice: double.tryParse(_price.text.trim()) ?? 0,
								estimatedDuration: _duration.text.trim(),
								personalMessage: _message.text.trim(),
								availableDate: DateTime.now().add(const Duration(days: 1)),
								timeSlot: null,
								createdAt: DateTime.now(),
							);
							await jobService.submitProposal(p);
							if (context.mounted) Navigator.of(context).pop();
						},
						child: const Text('Envoyer'),
					),
				]),
			),
		);
	}
}