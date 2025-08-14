import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../services/chat_service.dart';
import '../../../providers/auth_provider.dart';
import 'chat_screen.dart';
import '../../../widgets/common/empty_state.dart';

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
					if (chats.isEmpty) return const EmptyState(animationAsset: 'assets/lottie/empty-chat.json', title: 'Aucune conversation');
					return ListView.separated(
						itemCount: chats.length,
						separatorBuilder: (_, __) => const Divider(height: 1),
						itemBuilder: (context, i) {
							final c = chats[i];
							final heroTag = 'chat-avatar-'+c.chatId;
							return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
								stream: FirebaseFirestore.instance.collection('workers').doc(c.workerId).snapshots(),
								builder: (_, s) {
									final worker = s.data?.data();
									final name = (worker?['fullName'] as String?) ?? 'Artisan '+c.workerId.substring(0, 6);
									final avatar = worker?['avatarUrl'] as String?;
									final isVerified = (worker?['isVerified'] as bool?) ?? false;
									return ListTile(
										leading: Hero(tag: heroTag, child: CircleAvatar(backgroundImage: avatar != null ? NetworkImage(avatar) : null, child: avatar == null ? const Icon(Icons.person) : null)),
										title: Row(children: [Text(name), if (isVerified) const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.verified, color: Colors.lightBlue, size: 18))]),
										subtitle: const Text('Appuyez pour ouvrir le chat'),
										trailing: StreamBuilder<int>(
											stream: chatService.unreadCount(c.chatId, clientId),
											builder: (_, u) {
												final count = u.data ?? 0;
												return count > 0 ? CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Text(count.toString(), style: const TextStyle(color: Colors.white, fontSize: 12))) : const SizedBox.shrink();
											},
										),
										onTap: () async {
											Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(chatId: c.chatId, myId: clientId, peerId: c.workerId, peerName: name, peerAvatarUrl: avatar, heroTag: heroTag)));
										},
									);
								},
							);
						},
					);
				},
			),
		);
	}
}