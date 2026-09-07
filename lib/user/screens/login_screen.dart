import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/glass.dart';
import '../widgets/code_typing_animation.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;
  final String? errorHint;

  const LoginScreen({
    super.key,
    required this.authService,
    this.errorHint,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  String? _error;
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _error = widget.errorHint;
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.authService.signInWithGoogle();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // User dismissed — stay quiet.
      } else {
        setState(() => _error = e.description ?? e.toString());
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: GlassBackdrop(
        child: Column(
          children: [
            Expanded(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _enter,
                      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.04),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _enter,
                          curve: const Interval(
                            0.0,
                            0.65,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                      ),
                      child: const CodeTypingAnimation(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _enter,
                curve: const Interval(0.28, 1.0, curve: Curves.easeOut),
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.14),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _enter,
                    curve: const Interval(
                      0.28,
                      1.0,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                ),
                child: _WelcomeDock(
                  loading: _loading,
                  error: _error,
                  onSignIn: _loading ? null : _signIn,
                  bottomPadding: bottomInset + 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeDock extends StatelessWidget {
  final bool loading;
  final String? error;
  final VoidCallback? onSignIn;
  final double bottomPadding;

  const _WelcomeDock({
    required this.loading,
    required this.error,
    required this.onSignIn,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPadding),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      opacity: 0.15,
      blur: 36,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'MAP.DEV',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.8,
                  color: MapDevTheme.cyan,
                  shadows: [
                    Shadow(
                      color: MapDevTheme.cyan.withValues(alpha: 0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        MapDevTheme.cyan.withValues(alpha: 0.35),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Welcome',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: Colors.white.withValues(alpha: 0.96),
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in with Google to request apps and chat with the team.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.52),
              height: 1.45,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 22),
          _GoogleSignInButton(
            loading: loading,
            onPressed: onSignIn,
          ),
          if (error != null) ...[
            const SizedBox(height: 14),
            Text(
              error!,
              style: const TextStyle(
                color: MapDevTheme.red,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            'Only Google accounts are accepted',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.32),
              fontSize: 11.5,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;

  const _GoogleSignInButton({
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.16),
              Colors.white.withValues(alpha: 0.08),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
          ),
          boxShadow: [
            BoxShadow(
              color: MapDevTheme.cyan.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'G',
                            style: TextStyle(
                              color: Color(0xFF4285F4),
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Continue with Google',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
