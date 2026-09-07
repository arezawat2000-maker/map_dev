import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/glass.dart';

/// Full-screen ban lockout. Only action: log out.
class BannedScreen extends StatelessWidget {
  final AuthService authService;
  final String? bannedBy;

  const BannedScreen({
    super.key,
    required this.authService,
    this.bannedBy,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: GlassBackdrop(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  GlassPanel(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                    borderRadius: BorderRadius.circular(22),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: MapDevTheme.red.withValues(alpha: 0.18),
                            border: Border.all(
                              color: MapDevTheme.red.withValues(alpha: 0.45),
                            ),
                          ),
                          child: const Icon(
                            Icons.block_rounded,
                            color: MapDevTheme.red,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Account banned',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your MAP.DEV account has been banned. '
                          'You can no longer use the app.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            height: 1.45,
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        if (bannedBy != null && bannedBy!.trim().isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Banned by ${bannedBy!.trim()}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Spacer(flex: 3),
                  GlassPrimaryButton(
                    label: 'Log out',
                    icon: Icons.logout_rounded,
                    onPressed: () => authService.signOut(),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
