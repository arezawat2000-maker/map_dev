import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/post.dart';

/// Firestore posts at `posts/{id}` with likes/comments subcollections.
class PostRepository {
  PostRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _posts =>
      _db.collection('posts');

  DocumentReference<Map<String, dynamic>> _postRef(String postId) =>
      _posts.doc(postId);

  DocumentReference<Map<String, dynamic>> _likeRef(
    String postId,
    String userEmail,
  ) {
    return _postRef(postId)
        .collection('likes')
        .doc(userEmail.trim().toLowerCase());
  }

  DocumentReference<Map<String, dynamic>> _commentRef(
    String postId,
    String userEmail,
  ) {
    return _postRef(postId)
        .collection('comments')
        .doc(userEmail.trim().toLowerCase());
  }

  Stream<List<Post>> watchAll() {
    return _posts
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((doc) => Post.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Stream<bool> watchHasLiked({
    required String postId,
    required String userEmail,
  }) {
    return _likeRef(postId, userEmail).snapshots().map((snap) => snap.exists);
  }

  Stream<PostComment?> watchMyComment({
    required String postId,
    required String userEmail,
  }) {
    return _commentRef(postId, userEmail).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return PostComment.fromMap(snap.id, snap.data()!);
    });
  }

  Stream<List<PostComment>> watchComments(String postId) {
    return _postRef(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((doc) => PostComment.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// Like once per user. No-ops (returns false) if already liked.
  Future<bool> likePost({
    required String postId,
    required String userEmail,
    String? username,
  }) async {
    final email = userEmail.trim().toLowerCase();
    if (email.isEmpty) {
      throw ArgumentError('userEmail is required');
    }

    return _db.runTransaction((tx) async {
      final likeRef = _likeRef(postId, email);
      final postRef = _postRef(postId);
      final likeSnap = await tx.get(likeRef);
      if (likeSnap.exists) return false;

      final postSnap = await tx.get(postRef);
      if (!postSnap.exists) {
        throw StateError('Post not found');
      }

      tx.set(likeRef, {
        'userEmail': email,
        if (username != null && username.trim().isNotEmpty)
          'username': username.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      tx.update(postRef, {
        'likeCount': FieldValue.increment(1),
      });
      return true;
    });
  }

  /// Add the user's only comment. Throws [AlreadyCommentedException] if one exists.
  Future<void> addComment({
    required String postId,
    required String userEmail,
    required String username,
    required String text,
  }) async {
    final email = userEmail.trim().toLowerCase();
    final trimmed = text.trim();
    if (email.isEmpty) {
      throw ArgumentError('userEmail is required');
    }
    if (trimmed.isEmpty) {
      throw ArgumentError('Comment text is required');
    }

    await _db.runTransaction((tx) async {
      final commentRef = _commentRef(postId, email);
      final postRef = _postRef(postId);
      final commentSnap = await tx.get(commentRef);
      if (commentSnap.exists) {
        throw AlreadyCommentedException(postId, email);
      }

      final postSnap = await tx.get(postRef);
      if (!postSnap.exists) {
        throw StateError('Post not found');
      }

      tx.set(commentRef, {
        'userEmail': email,
        'username': username.trim(),
        'text': trimmed,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.update(postRef, {
        'commentCount': FieldValue.increment(1),
      });
    });
  }

  Future<String> create({
    required String title,
    required String body,
  }) async {
    final post = Post(id: '', title: title, body: body);
    final ref = await _posts.add(post.toCreateMap());
    return ref.id;
  }

  Future<void> update({
    required String id,
    required String title,
    required String body,
  }) async {
    final post = Post(id: id, title: title, body: body);
    await _posts.doc(id).update(post.toUpdateMap());
  }

  Future<void> delete(String id) async {
    await _posts.doc(id).delete();
  }
}

class AlreadyCommentedException implements Exception {
  final String postId;
  final String userEmail;

  AlreadyCommentedException(this.postId, this.userEmail);

  @override
  String toString() =>
      'You already commented on this post. Only one comment per user is allowed.';
}
