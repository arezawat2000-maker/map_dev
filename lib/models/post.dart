import 'package:cloud_firestore/cloud_firestore.dart';

/// Admin post at Firestore: `posts/{id}`
///
/// Engagement:
/// - `posts/{id}/likes/{userEmail}`
/// - `posts/{id}/comments/{userEmail}` (at most one comment per user)
class Post {
  static const String defaultAuthorName = 'MAP.DEV';

  final String id;
  final String title;
  final String body;
  final String authorName;
  final int likeCount;
  final int commentCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Post({
    required this.id,
    required this.title,
    required this.body,
    this.authorName = defaultAuthorName,
    this.likeCount = 0,
    this.commentCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory Post.fromMap(String id, Map<String, dynamic> map) {
    return Post(
      id: id,
      title: (map['title'] ?? '').toString(),
      body: (map['body'] ?? '').toString(),
      authorName: (map['authorName'] ?? defaultAuthorName).toString(),
      likeCount: _readInt(map['likeCount']),
      commentCount: _readInt(map['commentCount']),
      createdAt: _readTimestamp(map['createdAt']),
      updatedAt: _readTimestamp(map['updatedAt']),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'title': title.trim(),
      'body': body.trim(),
      'authorName': authorName.trim().isEmpty ? defaultAuthorName : authorName.trim(),
      'likeCount': 0,
      'commentCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'title': title.trim(),
      'body': body.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  String get formattedDate {
    final date = createdAt;
    if (date == null) return '';
    final local = date.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
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

/// Like at `posts/{postId}/likes/{userEmail}`
class PostLike {
  final String userEmail;
  final String? username;
  final DateTime? createdAt;

  const PostLike({
    required this.userEmail,
    this.username,
    this.createdAt,
  });

  factory PostLike.fromMap(String id, Map<String, dynamic> map) {
    return PostLike(
      userEmail: (map['userEmail'] ?? id).toString().trim().toLowerCase(),
      username: map['username']?.toString(),
      createdAt: Post._readTimestamp(map['createdAt']),
    );
  }
}

/// Comment at `posts/{postId}/comments/{userEmail}` — one per user.
class PostComment {
  final String userEmail;
  final String username;
  final String text;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PostComment({
    required this.userEmail,
    required this.username,
    required this.text,
    this.createdAt,
    this.updatedAt,
  });

  factory PostComment.fromMap(String id, Map<String, dynamic> map) {
    return PostComment(
      userEmail: (map['userEmail'] ?? id).toString().trim().toLowerCase(),
      username: (map['username'] ?? '').toString(),
      text: (map['text'] ?? '').toString(),
      createdAt: Post._readTimestamp(map['createdAt']),
      updatedAt: Post._readTimestamp(map['updatedAt']),
    );
  }

  String get displayName {
    final name = username.trim();
    if (name.isNotEmpty) return name;
    return userEmail;
  }

  String get formattedDate {
    final date = createdAt ?? updatedAt;
    if (date == null) return '';
    final local = date.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }
}
