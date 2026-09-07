import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_message.dart';
import '../models/chat_meta.dart';

/// User ↔ admin chat.
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

  Future<ChatMeta> getMeta(String emailId) async {
    final snap = await _metaRef(emailId).get();
    return ChatMeta.fromMap(snap.data());
  }

  Future<void> setChatEnabled(String emailId, bool enabled) async {
    await _metaRef(emailId).set(
      {'chat_enabled': enabled},
      SetOptions(merge: true),
    );
  }

  /// User send — enforces first-message / chat_enabled gate.
  Future<void> sendUserMessage({
    required String emailId,
    required String text,
    String? senderName,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final meta = await getMeta(emailId);
    final existing = await _chats(emailId).limit(1).get();
    final empty = existing.docs.isEmpty;

    if (!ChatMeta.canUserSend(
      chatEnabled: meta.chatEnabled,
      messagesEmpty: empty,
    )) {
      throw StateError(
        'Messaging is closed. Wait for admin to open the chat.',
      );
    }

    final message = ChatMessage(
      id: '',
      text: trimmed,
      sender: 'user',
      senderName: senderName,
    );

    await _chats(emailId).add(message.toCreateMap());
  }

  /// Admin can always send. [senderName] should be the admin username from
  /// `admin/{email}`; users still see [ChatMessage.userFacingAdminName].
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
