import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Google Sign-In + Firebase Auth for the user app.
class AuthService {
  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _google = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _google;
  bool _googleReady = false;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> ensureGoogleInitialized() async {
    if (_googleReady) return;
    // clientId / serverClientId come from GoogleService-Info.plist /
    // google-services.json once Google Sign-In is enabled in Firebase Console.
    await _google.initialize();
    _googleReady = true;
  }

  /// Interactive Google sign-in, then Firebase Auth credential exchange.
  Future<UserCredential> signInWithGoogle() async {
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
    return _auth.signInWithCredential(credential);
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
