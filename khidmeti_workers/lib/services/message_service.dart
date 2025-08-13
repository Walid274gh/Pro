import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../utils/firebase_config.dart';

class WorkerMessageService {
  static final WorkerMessageService _instance = WorkerMessageService._internal();
  factory WorkerMessageService() => _instance;
  WorkerMessageService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> createOrGetChat({
    required String workerId,
    required String workerName,
    String? workerImageUrl,
    required String userId,
    required String userName,
    String? userImageUrl,
  }) async {
    final existing = await _firestore
        .collection(FirebaseConfig.chatsCollection)
        .where('participants', arrayContains: workerId)
        .get();

    for (final doc in existing.docs) {
      final data = doc.data();
      final parts = List<String>.from(data['participants'] ?? []);
      if (parts.contains(userId)) return doc.id;
    }

    final ref = await _firestore.collection(FirebaseConfig.chatsCollection).add({
      'participants': [workerId, userId],
      'participantNames': {workerId: workerName, userId: userName},
      'participantImages': {workerId: workerImageUrl, userId: userImageUrl},
      'participantTypes': {workerId: 'worker', userId: 'user'},
      'lastMessage': null,
      'lastMessageTime': null,
      'unreadCount': {workerId: 0, userId: 0},
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> sendText({
    required String chatId,
    required String workerId,
    required String workerName,
    String? workerImageUrl,
    required String userId,
    required String userName,
    String? userImageUrl,
    required String text,
  }) async {
    final msgRef = await _firestore.collection(FirebaseConfig.messagesCollection).add({
      'chatId': chatId,
      'senderId': workerId,
      'senderName': workerName,
      'senderImageUrl': workerImageUrl,
      'senderType': 'worker',
      'receiverId': userId,
      'receiverName': userName,
      'receiverImageUrl': userImageUrl,
      'receiverType': 'user',
      'type': 'text',
      'content': text,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'sent',
      'isEdited': false,
      'isDeleted': false,
    });

    await _firestore.collection(FirebaseConfig.chatsCollection).doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'unreadCount.$userId': FieldValue.increment(1),
    });
  }

  Future<void> sendImage({
    required String chatId,
    required String workerId,
    required String workerName,
    String? workerImageUrl,
    required String userId,
    required String userName,
    String? userImageUrl,
    required File image,
    String? caption,
  }) async {
    final path = 'chat_images/$workerId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final snap = await _storage.ref().child(path).putFile(image);
    final url = await snap.ref.getDownloadURL();

    await _firestore.collection(FirebaseConfig.messagesCollection).add({
      'chatId': chatId,
      'senderId': workerId,
      'senderName': workerName,
      'senderImageUrl': workerImageUrl,
      'senderType': 'worker',
      'receiverId': userId,
      'receiverName': userName,
      'receiverImageUrl': userImageUrl,
      'receiverType': 'user',
      'type': 'image',
      'content': caption ?? '',
      'mediaUrl': url,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'sent',
      'isEdited': false,
      'isDeleted': false,
    });

    await _firestore.collection(FirebaseConfig.chatsCollection).doc(chatId).update({
      'lastMessage': '[image]',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'unreadCount.$userId': FieldValue.increment(1),
    });
  }

  Stream<List<Map<String, dynamic>>> getChatList(String workerId) {
    return _firestore
        .collection(FirebaseConfig.chatsCollection)
        .where('participants', arrayContains: workerId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  Stream<List<Map<String, dynamic>>> getMessages(String chatId, {int limit = 50}) {
    return _firestore
        .collection(FirebaseConfig.messagesCollection)
        .where('chatId', isEqualTo: chatId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList().reversed.toList());
  }

  Future<void> markAllRead(String chatId, String workerId) async {
    final unread = await _firestore
        .collection(FirebaseConfig.messagesCollection)
        .where('chatId', isEqualTo: chatId)
        .where('receiverId', isEqualTo: workerId)
        .where('status', isEqualTo: 'sent')
        .get();

    final batch = _firestore.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'status': 'read', 'readAt': FieldValue.serverTimestamp()});
    }
    await batch.commit();

    // Remettre le compteur à 0 côté chat
    await _firestore.collection(FirebaseConfig.chatsCollection).doc(chatId).update({'unreadCount.$workerId': 0});
  }
}