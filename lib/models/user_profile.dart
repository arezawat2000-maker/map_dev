import 'package:cloud_firestore/cloud_firestore.dart';

/// User profile stored at Firestore:
/// `users/{emailId}/informations/profile`
class UserProfile {
  final String email;
  final String username;
  final String phone;
  final String? photoUrl;
  final String? displayName;
  final bool banned;
  final DateTime? bannedAt;
  final String? bannedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.email,
    required this.username,
    required this.phone,
    this.photoUrl,
    this.displayName,
    this.banned = false,
    this.bannedAt,
    this.bannedBy,
    this.createdAt,
    this.updatedAt,
  });

  bool get hasUsername => username.trim().isNotEmpty;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      email: (map['email'] ?? '').toString(),
      username: (map['username'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      photoUrl: map['photoUrl']?.toString(),
      displayName: map['displayName']?.toString(),
      banned: map['banned'] == true,
      bannedAt: _readTimestamp(map['bannedAt']),
      bannedBy: map['bannedBy']?.toString(),
      createdAt: _readTimestamp(map['createdAt']),
      updatedAt: _readTimestamp(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap({bool includeCreatedAt = true}) {
    return {
      'email': email.trim().toLowerCase(),
      'username': username.trim(),
      'phone': phone.trim(),
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (displayName != null) 'displayName': displayName,
      'banned': banned,
      if (bannedBy != null) 'bannedBy': bannedBy,
      if (bannedAt != null) 'bannedAt': Timestamp.fromDate(bannedAt!),
      if (includeCreatedAt) 'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserProfile copyWith({
    String? email,
    String? username,
    String? phone,
    String? photoUrl,
    String? displayName,
    bool? banned,
    DateTime? bannedAt,
    String? bannedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      email: email ?? this.email,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      displayName: displayName ?? this.displayName,
      banned: banned ?? this.banned,
      bannedAt: bannedAt ?? this.bannedAt,
      bannedBy: bannedBy ?? this.bannedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
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
