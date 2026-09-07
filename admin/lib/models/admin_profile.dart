/// Registered admin at Firestore: `admin/{emailUid}`
///
/// Doc id = Google account email, lowercased.
/// Expected fields include `username` (display name in admin chat).
class AdminProfile {
  final String email;
  final String username;

  const AdminProfile({
    required this.email,
    required this.username,
  });

  bool get hasUsername => username.trim().isNotEmpty;

  String get displayName => hasUsername ? username.trim() : email;

  factory AdminProfile.fromMap(String emailId, Map<String, dynamic> map) {
    final rawName = (map['username'] ?? map['name'] ?? '').toString().trim();
    return AdminProfile(
      email: emailId.trim().toLowerCase(),
      username: rawName,
    );
  }
}
