/// Chat room metadata at Firestore:
/// `users/{emailId}/informations/chat`
class ChatMeta {
  final bool chatEnabled;

  const ChatMeta({this.chatEnabled = false});

  factory ChatMeta.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ChatMeta();
    final raw = map['chat_enabled'] ?? map['chatEnabled'] ?? map['messaging_open'];
    return ChatMeta(chatEnabled: raw == true);
  }

  Map<String, dynamic> toMap() => {'chat_enabled': chatEnabled};

  /// Whether the end user is allowed to send right now.
  static bool canUserSend({
    required bool chatEnabled,
    required bool messagesEmpty,
  }) {
    if (chatEnabled) return true;
    return messagesEmpty;
  }
}
