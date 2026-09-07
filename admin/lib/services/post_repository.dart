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
