import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';

/// Firestore profiles at `users/{emailId}/informations/profile`.
///
/// Also maintains a listable parent doc at `users/{emailId}` so
/// `collection('users')` queries see accounts. Subcollection-only writes
/// leave "phantom" parents that never appear in collection snapshots.
class UserProfileRepository {
  UserProfileRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static String normalizeEmailId(String emailId) =>
      emailId.trim().toLowerCase();

  DocumentReference<Map<String, dynamic>> _userRef(String emailId) {
    return _db.collection('users').doc(normalizeEmailId(emailId));
  }

  DocumentReference<Map<String, dynamic>> _profileRef(String emailId) {
    return _userRef(emailId).collection('informations').doc('profile');
  }

  /// Ensures `users/{email}` exists so this account appears in listings.
  Future<void> ensureUserListed(
    String emailId, {
    UserProfile? profile,
  }) async {
    final email = normalizeEmailId(emailId);
    if (email.isEmpty) return;

    final data = <String, dynamic>{
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (profile != null) {
      final username = profile.username.trim();
      final phone = profile.phone.trim();
      if (username.isNotEmpty) data['username'] = username;
      if (phone.isNotEmpty) data['phone'] = phone;
      if (profile.photoUrl != null) data['photoUrl'] = profile.photoUrl;
      if (profile.displayName != null) {
        data['displayName'] = profile.displayName;
      }
    }

    await _userRef(email).set(data, SetOptions(merge: true));
  }

  Future<UserProfile?> getProfile(String emailId) async {
    final snap = await _profileRef(emailId).get();
    if (!snap.exists || snap.data() == null) return null;
    final profile = UserProfile.fromMap(snap.data()!);
    final email = normalizeEmailId(
      profile.email.isNotEmpty ? profile.email : emailId,
    );
    return profile.email == email ? profile : profile.copyWith(email: email);
  }

  Stream<UserProfile?> watchProfile(String emailId) {
    final fallbackEmail = normalizeEmailId(emailId);
    return _profileRef(emailId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      final profile = UserProfile.fromMap(snap.data()!);
      final email = normalizeEmailId(
        profile.email.isNotEmpty ? profile.email : fallbackEmail,
      );
      return profile.email == email ? profile : profile.copyWith(email: email);
    });
  }

  /// Sets ban flags on `users/{emailId}/informations/profile`.
  Future<void> banUser({
    required String emailId,
    required String bannedBy,
  }) async {
    final email = normalizeEmailId(emailId);
    if (email.isEmpty) {
      throw ArgumentError('emailId is required');
    }
    await _profileRef(email).set(
      {
        'email': email,
        'banned': true,
        'bannedAt': FieldValue.serverTimestamp(),
        'bannedBy': bannedBy.trim().toLowerCase(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    try {
      await ensureUserListed(email);
    } catch (_) {}
  }

  Future<void> unbanUser(String emailId) async {
    final email = normalizeEmailId(emailId);
    await _profileRef(email).set(
      {
        'banned': false,
        'bannedAt': FieldValue.delete(),
        'bannedBy': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    try {
      await ensureUserListed(email);
    } catch (_) {}
  }

  /// Lists users that have a profile under `users/{email}/informations/profile`.
  ///
  /// Uses a collection-group query so accounts still appear when only the
  /// nested profile doc exists (no parent `users/{email}` document).
  Stream<List<UserProfile>> watchAllProfiles() {
    return _db.collectionGroup('informations').snapshots().map((snap) {
      final profiles = <UserProfile>[];
      final seen = <String>{};

      for (final doc in snap.docs) {
        if (doc.id != 'profile') continue;

        final userDoc = doc.reference.parent.parent;
        if (userDoc == null) continue;
        // Expect path: users/{email}/informations/profile
        if (userDoc.parent.id != 'users') continue;

        final emailFromPath = normalizeEmailId(userDoc.id);
        if (emailFromPath.isEmpty || !seen.add(emailFromPath)) continue;

        final profile = UserProfile.fromMap(doc.data());
        final email = normalizeEmailId(
          profile.email.isNotEmpty ? profile.email : emailFromPath,
        );
        profiles.add(
          profile.email == email ? profile : profile.copyWith(email: email),
        );
      }

      profiles.sort((a, b) {
        final nameA = a.username.toLowerCase();
        final nameB = b.username.toLowerCase();
        final cmp = nameA.compareTo(nameB);
        if (cmp != 0) return cmp;
        return a.email.toLowerCase().compareTo(b.email.toLowerCase());
      });
      return profiles;
    });
  }
}
