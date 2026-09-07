import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/admin_profile.dart';
import '../services/admin_repository.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass.dart';
import 'admin_shell.dart';
import 'login_screen.dart';

/// Routes: splash → login | admin shell (after registry check).
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _auth = AuthService();
  final _admins = AdminRepository();
  String? _denyMessage;

  @override
  void initState() {
    super.initState();
    _auth.ensureGoogleInitialized();
  }

  Future<void> _denyAndSignOut(String message) async {
    await _auth.signOut();
    if (!mounted) return;
    setState(() => _denyMessage = message);
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
          return LoginScreen(
            authService: _auth,
            errorHint: _denyMessage,
          );
        }

        final emailId = AuthService.emailIdFor(user);
        if (emailId == null) {
          return LoginScreen(
            authService: _auth,
            errorHint:
                'Your Google account has no email. Try another account.',
          );
        }

        return StreamBuilder<AdminProfile?>(
          stream: _admins.watchAdmin(emailId),
          builder: (context, adminSnap) {
            if (adminSnap.connectionState == ConnectionState.waiting &&
                !adminSnap.hasData) {
              return const _SplashShell();
            }

            final admin = adminSnap.data;
            if (admin == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _denyAndSignOut(
                  'Access denied. "$emailId" is not registered as a MAP.DEV admin.',
                );
              });
              return const _SplashShell();
            }

            return AdminShell(
              admin: admin,
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
                  color: MapDevTheme.cyan,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'ADMIN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                  color: MapDevTheme.muted,
                ),
              ),
              SizedBox(height: 28),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: MapDevTheme.cyan,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
