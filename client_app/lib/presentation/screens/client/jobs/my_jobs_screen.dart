import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../services/job_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../../domain/entities/job_request.dart';
import '../chat/chat_screen.dart';
import '../../../../services/chat_service.dart';
import '../../../widgets/common/empty_state.dart';

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
				if (jobs.isEmpty) return const EmptyState(animationAsset: 'assets/lottie/empty-box.json', title: 'Aucun travail');
				return ListView.separated(
					padding: const EdgeInsets.all(16),
					itemCount: jobs.length,
					separatorBuilder: (_, __) => const SizedBox(height: 12),
					itemBuilder: (context, index) {
						final j = jobs[index];
						return ListTile(
							title: Text(j.title),
							subtitle: Text('Statut: '+j.status),
							onTap: () {},
							trailing: Row(
								mainAxisSize: MainAxisSize.min,
								children: [
									if (j.acceptedWorkerId != null) IconButton(
										icon: const Icon(Icons.chat_bubble_outline),
										onPressed: () async {
											final chat = ChatService();
											final chatId = await chat.createOrGetChat(clientId, j.acceptedWorkerId!);
											if (context.mounted) Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(chatId: chatId, myId: clientId)));
										},
									),
									const Icon(Icons.chevron_right),
								],
							),
							shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
							tileColor: Colors.white,
						);
					},
				);
			},
		);
	}
}