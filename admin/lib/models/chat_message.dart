import 'package:cloud_firestore/cloud_firestore.dart';

/// Chat message at Firestore: `users/{emailId}/chats/{messageId}`
class ChatMessage {
  static const String userFacingAdminName = 'Map.dev';

  final String id;
  final String text;
  final String sender; // 'user' | 'admin'
  final String? senderName;
  final String? senderEmail;
  final DateTime? createdAt;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    this.senderName,
    this.senderEmail,
    this.createdAt,
  });

  bool get isFromUser => sender == 'user';
  bool get isFromAdmin => sender == 'admin';

  String displayNameForUser() {
    if (isFromAdmin) return userFacingAdminName;
    if (senderName != null && senderName!.trim().isNotEmpty) {
      return senderName!.trim();
    }
    return 'You';
  }

  String displayNameForAdmin() {
    if (isFromAdmin) {
      if (senderName != null && senderName!.trim().isNotEmpty) {
        return senderName!.trim();
      }
      if (senderEmail != null && senderEmail!.trim().isNotEmpty) {
        return senderEmail!.trim();
      }
      return 'Admin';
    }
    if (senderName != null && senderName!.trim().isNotEmpty) {
      return senderName!.trim();
    }
    return 'User';
  }

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    return ChatMessage(
      id: id,
      text: (map['text'] ?? '').toString(),
      sender: (map['sender'] ?? 'user').toString(),
      senderName: map['senderName']?.toString(),
      senderEmail: (map['senderEmail'] ?? map['senderId'])?.toString(),
      createdAt: _readTimestamp(map['createdAt']),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'text': text.trim(),
      'sender': sender,
      if (senderName != null) 'senderName': senderName,
      if (senderEmail != null) 'senderEmail': senderEmail,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _readTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }
}
