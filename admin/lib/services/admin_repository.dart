import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/admin_profile.dart';

/// Thrown when Google sign-in succeeds but the account is not in `admin/{email}`.
class NotAnAdminException implements Exception {
  final String email;

  const NotAnAdminException(this.email);

  @override
  String toString() =>
      'Access denied. "$email" is not registered as a MAP.DEV admin.';
}

/// Firestore admin registry at `admin/{emailUid}`.
class AdminRepository {
  AdminRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _ref(String emailId) {
    return _db.collection('admin').doc(emailId.trim().toLowerCase());
  }

  Future<AdminProfile?> getAdmin(String emailId) async {
    final snap = await _ref(emailId).get();
    if (!snap.exists || snap.data() == null) return null;
    return AdminProfile.fromMap(emailId, snap.data()!);
  }

  Stream<AdminProfile?> watchAdmin(String emailId) {
    return _ref(emailId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return AdminProfile.fromMap(emailId, snap.data()!);
    });
  }

  /// Returns the profile if [emailId] is an admin, otherwise null.
  Future<AdminProfile?> requireAdmin(String emailId) => getAdmin(emailId);
}
