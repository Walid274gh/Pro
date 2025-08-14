import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
	final String id;
	final String chatId;
	final String senderId;
	final String text;
	final DateTime sentAt;
	const ChatMessage({required this.id, required this.chatId, required this.senderId, required this.text, required this.sentAt});
}

class ChatService {
	final FirebaseFirestore _db = FirebaseFirestore.instance;

	Future<String> createOrGetChat(String clientId, String workerId) async {
		final q = await _db.collection('chats').where('clientId', isEqualTo: clientId).where('workerId', isEqualTo: workerId).limit(1).get();
		if (q.docs.isNotEmpty) return q.docs.first.id;
		final ref = _db.collection('chats').doc();
		await ref.set({'clientId': clientId, 'workerId': workerId, 'createdAt': FieldValue.serverTimestamp()});
		return ref.id;
	}

	Stream<List<ChatMessage>> messages(String chatId) {
		return _db.collection('chats').doc(chatId).collection('messages').orderBy('sentAt', descending: true).limit(100).snapshots().map((s) => s.docs.map((d) {
			final m = d.data();
			return ChatMessage(id: d.id, chatId: chatId, senderId: m['senderId'] as String, text: m['text'] as String, sentAt: (m['sentAt'] as Timestamp).toDate());
		}).toList());
	}

	Future<void> sendMessage(String chatId, String senderId, String text) async {
		final ref = _db.collection('chats').doc(chatId).collection('messages').doc();
		await ref.set({'senderId': senderId, 'text': text, 'sentAt': FieldValue.serverTimestamp()});
	}
}