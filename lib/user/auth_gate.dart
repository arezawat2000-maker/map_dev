import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/user_profile_repository.dart';
import '../theme/glass.dart';
import 'screens/banned_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_setup_screen.dart';

/// Routes: splash → login | banned | profile setup | dashboard.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _auth = AuthService();
  final _profiles = UserProfileRepository();
  String? _listedEmailId;

  @override
  void initState() {
    super.initState();
    _auth.ensureGoogleInitialized();
  }

  void _ensureListed(String emailId, UserProfile profile) {
    if (_listedEmailId == emailId) return;
    _listedEmailId = emailId;
    _profiles.ensureUserListed(emailId, profile: profile).ignore();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges,
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const _SplashShell();
        }

        final user = authSnap.data;
        if (user == null) {
          _listedEmailId = null;
          return LoginScreen(authService: _auth);
        }

        final emailId = AuthService.emailIdFor(user);
        if (emailId == null) {
          return LoginScreen(
            authService: _auth,
            errorHint:
                'Your Google account has no email. Try another account.',
          );
        }

        return StreamBuilder<UserProfile?>(
          stream: _profiles.watchProfile(emailId),
          builder: (context, profileSnap) {
            if (profileSnap.hasError) {
              return _ErrorShell(message: '${profileSnap.error}');
            }

            if (profileSnap.connectionState == ConnectionState.waiting &&
                !profileSnap.hasData) {
              return const _SplashShell();
            }

            final profile = profileSnap.data;

            // Hard ban: no tabs, no back — logout only.
            if (profile != null && profile.banned) {
              return BannedScreen(
                authService: _auth,
                bannedBy: profile.bannedBy,
              );
            }

            if (profile == null || !profile.hasUsername) {
              return ProfileSetupScreen(
                user: user,
                emailId: emailId,
                existing: profile,
                profiles: _profiles,
              );
            }

            // Keep parent `users/{email}` listable for the admin app.
            _ensureListed(emailId, profile);

            return DashboardScreen(
              user: user,
              profile: profile,
              authService: _auth,
            );
          },
        );
      },
    );
  }
}

class _SplashShell extends StatelessWidget {
  const _SplashShell();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: GlassBackdrop(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'MAP.DEV',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                  color: Color(0xFF58A6FF),
                ),
              ),
              SizedBox(height: 28),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Color(0xFF58A6FF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorShell extends StatelessWidget {
  final String message;

  const _ErrorShell({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackdrop(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load profile:\n$message',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFF7B72),
                height: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
