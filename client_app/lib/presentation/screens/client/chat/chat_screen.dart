import 'package:flutter/material.dart';

import '../../../../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
	final String chatId;
	final String myId;
	final String? peerId;
	final String? peerName;
	final String? peerAvatarUrl;
	final String? heroTag;
	const ChatScreen({super.key, required this.chatId, required this.myId, this.peerId, this.peerName, this.peerAvatarUrl, this.heroTag});

	@override
	State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
	final ChatService _service = ChatService();
	final TextEditingController _text = TextEditingController();

	@override
	void initState() {
		super.initState();
		WidgetsBinding.instance.addPostFrameCallback((_) => _service.markRead(widget.chatId, widget.myId));
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Row(children: [
					if (widget.heroTag != null)
						Hero(
							tag: widget.heroTag!,
							child: CircleAvatar(radius: 14, backgroundImage: widget.peerAvatarUrl != null ? NetworkImage(widget.peerAvatarUrl!) : null, child: widget.peerAvatarUrl == null ? const Icon(Icons.person, size: 16) : null),
						),
					if (widget.heroTag != null) const SizedBox(width: 8),
					Text(widget.peerName ?? 'Conversation'),
				]),
			),
			body: Column(
				children: [
					Expanded(
						child: StreamBuilder<List<ChatMessage>>(
							stream: _service.messages(widget.chatId),
							builder: (context, snapshot) {
								final messages = snapshot.data ?? const <ChatMessage>[];
								if (messages.isNotEmpty) WidgetsBinding.instance.addPostFrameCallback((_) => _service.markRead(widget.chatId, widget.myId));
								return ListView.builder(
									reverse: true,
									itemCount: messages.length,
									itemBuilder: (_, i) {
										final m = messages[i];
										final isMe = m.senderId == widget.myId;
										return Align(
											alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
											child: Container(
												margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
												padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
												decoration: BoxDecoration(color: isMe ? Colors.blue.shade100 : Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
												child: Text(m.text),
											),
										);
									},
								);
							},
						),
					),
					Padding(
						padding: const EdgeInsets.all(8),
						child: Row(children: [
							Expanded(child: TextField(controller: _text, decoration: const InputDecoration(hintText: 'Message...'))),
							IconButton(onPressed: () async { if (_text.text.trim().isEmpty) return; await _service.sendMessage(widget.chatId, widget.myId, _text.text.trim()); _text.clear(); }, icon: const Icon(Icons.send)),
						]),
					),
				],
			),
		);
	}
}