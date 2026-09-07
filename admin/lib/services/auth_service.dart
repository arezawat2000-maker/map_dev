import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/admin_profile.dart';
import 'admin_repository.dart';

/// Google Sign-In + Firebase Auth for the admin app.
///
/// After Google auth, the email must exist at Firestore `admin/{email}`.
class AuthService {
  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    AdminRepository? admins,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _google = googleSignIn ?? GoogleSignIn.instance,
        _admins = admins ?? AdminRepository();

  final FirebaseAuth _auth;
  final GoogleSignIn _google;
  final AdminRepository _admins;
  bool _googleReady = false;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> ensureGoogleInitialized() async {
    if (_googleReady) return;
    await _google.initialize();
    _googleReady = true;
  }

  /// Interactive Google sign-in, then admin registry check.
  ///
  /// Signs out and throws [NotAnAdminException] when the email is not in
  /// `admin/{email}`.
  Future<AdminProfile> signInWithGoogle() async {
    await ensureGoogleInitialized();

    final GoogleSignInAccount googleUser = await _google.authenticate();
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError(
        'Google Sign-In returned no ID token. '
        'Enable the Google provider in Firebase Console and re-download '
        'GoogleService-Info.plist / google-services.json (OAuth client IDs).',
      );
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final result = await _auth.signInWithCredential(credential);
    final emailId = emailIdFor(result.user);
    if (emailId == null) {
      await signOut();
      throw StateError(
        'Your Google account has no email. Try another account.',
      );
    }

    final admin = await _admins.getAdmin(emailId);
    if (admin == null) {
      await signOut();
      throw NotAnAdminException(emailId);
    }
    return admin;
  }

  Future<void> signOut() async {
    await ensureGoogleInitialized();
    await Future.wait([
      _auth.signOut(),
      _google.signOut(),
    ]);
  }

  /// Email used as Firestore document id (lowercased).
  static String? emailIdFor(User? user) {
    final email = user?.email?.trim().toLowerCase();
    if (email == null || email.isEmpty) return null;
    return email;
  }
}
