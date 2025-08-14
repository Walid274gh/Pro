import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../services/chat_service.dart';
import '../../../providers/auth_provider.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
	const ChatListScreen({super.key});

	@override
	Widget build(BuildContext context) {
		final clientId = context.watch<AuthProvider>().currentUser!.id;
		final chatService = ChatService();
		return Scaffold(
			appBar: AppBar(title: const Text('Mes conversations')),
			body: StreamBuilder<List<ChatSummary>>(
				stream: chatService.streamChatsForClient(clientId),
				builder: (context, snapshot) {
					if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
					final chats = snapshot.data!;
					if (chats.isEmpty) return const Center(child: Text('Aucune conversation'));
					return ListView.separated(
						itemCount: chats.length,
						separatorBuilder: (_, __) => const Divider(height: 1),
						itemBuilder: (context, i) {
							final c = chats[i];
							return ListTile(
								title: Text('Artisan '+c.workerId.substring(0, 6)),
								subtitle: const Text('Appuyez pour ouvrir le chat'),
								trailing: StreamBuilder<int>(
									stream: chatService.unreadCount(c.chatId, clientId),
									builder: (_, s) {
										final count = s.data ?? 0;
										return count > 0 ? CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Text(count.toString(), style: const TextStyle(color: Colors.white, fontSize: 12))) : const SizedBox.shrink();
									},
								),
								onTap: () async {
									Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(chatId: c.chatId, myId: clientId)));
								},
							);
						},
					);
				},
			),
		);
	}
}