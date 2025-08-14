import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
	final String id;
	final String chatId;
	final String senderId;
	final String text;
	final DateTime sentAt;
	const ChatMessage({required this.id, required this.chatId, required this.senderId, required this.text, required this.sentAt});
}

class ChatSummary {
	final String chatId;
	final String clientId;
	final String workerId;
	final DateTime createdAt;
	const ChatSummary({required this.chatId, required this.clientId, required this.workerId, required this.createdAt});
}

class ChatService {
	final FirebaseFirestore _db = FirebaseFirestore.instance;

	Future<String> createOrGetChat(String clientId, String workerId) async {
		final q = await _db.collection('chats').where('clientId', isEqualTo: clientId).where('workerId', isEqualTo: workerId).limit(1).get();
		if (q.docs.isNotEmpty) return q.docs.first.id;
		final ref = _db.collection('chats').doc();
		await ref.set({'clientId': clientId, 'workerId': workerId, 'createdAt': FieldValue.serverTimestamp()});
		// create members sub docs
		await ref.collection('members').doc(clientId).set({'lastRead': FieldValue.serverTimestamp()});
		await ref.collection('members').doc(workerId).set({'lastRead': FieldValue.serverTimestamp()});
		return ref.id;
	}

	Future<String?> findChat(String clientId, String workerId) async {
		final q = await _db.collection('chats').where('clientId', isEqualTo: clientId).where('workerId', isEqualTo: workerId).limit(1).get();
		if (q.docs.isEmpty) return null;
		return q.docs.first.id;
	}

	Stream<List<ChatSummary>> streamChatsForClient(String clientId) {
		return _db
			.collection('chats')
			.where('clientId', isEqualTo: clientId)
			.orderBy('createdAt', descending: true)
			.snapshots()
			.map((s) => s.docs.map((d) {
				final data = d.data();
				return ChatSummary(
					chatId: d.id,
					clientId: data['clientId'] as String,
					workerId: data['workerId'] as String,
					createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
				);
			}).toList());
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

	Stream<int> unreadCount(String chatId, String userId) {
		final memberRef = _db.collection('chats').doc(chatId).collection('members').doc(userId);
		final messagesRef = _db.collection('chats').doc(chatId).collection('messages');
		return memberRef.snapshots().switchMap((memberSnap) {
			final lastRead = (memberSnap.data()?['lastRead'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
			return messagesRef.where('sentAt', isGreaterThan: Timestamp.fromDate(lastRead)).snapshots().map((s) => s.docs.length);
		});
	}

	Future<void> markRead(String chatId, String userId) {
		final memberRef = _db.collection('chats').doc(chatId).collection('members').doc(userId);
		return memberRef.set({'lastRead': FieldValue.serverTimestamp()}, SetOptions(merge: true));
	}
}