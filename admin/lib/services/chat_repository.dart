import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_message.dart';
import '../models/chat_meta.dart';

/// User ↔ admin chat (same paths as the user app).
///
/// Messages: `users/{emailId}/chats/{messageId}`
/// Meta: `users/{emailId}/informations/chat` (`chat_enabled`)
class ChatRepository {
  ChatRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static String _emailKey(String emailId) => emailId.trim().toLowerCase();

  CollectionReference<Map<String, dynamic>> _chats(String emailId) {
    return _db.collection('users').doc(_emailKey(emailId)).collection('chats');
  }

  DocumentReference<Map<String, dynamic>> _metaRef(String emailId) {
    return _db
        .collection('users')
        .doc(_emailKey(emailId))
        .collection('informations')
        .doc('chat');
  }

  Stream<List<ChatMessage>> watchMessages(String emailId) {
    return _chats(emailId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((doc) => ChatMessage.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Stream<ChatMeta> watchMeta(String emailId) {
    return _metaRef(emailId).snapshots().map((snap) {
      return ChatMeta.fromMap(snap.data());
    });
  }

  Future<void> setChatEnabled(String emailId, bool enabled) async {
    await _metaRef(emailId).set(
      {'chat_enabled': enabled},
      SetOptions(merge: true),
    );
  }

  Future<void> sendAdminMessage({
    required String emailId,
    required String text,
    required String senderName,
    String? senderEmail,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final message = ChatMessage(
      id: '',
      text: trimmed,
      sender: 'admin',
      senderName: senderName,
      senderEmail: senderEmail?.trim().toLowerCase(),
    );

    await _chats(emailId).add(message.toCreateMap());
  }
}
