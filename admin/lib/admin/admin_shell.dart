import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/admin_profile.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass.dart';
import 'posts_tab.dart';
import 'users_tab.dart';

class AdminShell extends StatefulWidget {
  final AdminProfile admin;
  final AuthService authService;

  const AdminShell({
    super.key,
    required this.admin,
    required this.authService,
  });

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackdrop(
        child: Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(
                index: _index,
                children: [
                  UsersTab(
                    admin: widget.admin,
                    onSignOut: _confirmSignOut,
                  ),
                  PostsTab(admin: widget.admin),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: MediaQuery.paddingOf(context).bottom + 12,
              child: _GlassBottomNav(
                index: _index,
                onChanged: (i) => setState(() => _index = i),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSignOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MapDevTheme.bgPanel,
        title: const Text('Sign out?'),
        content: const Text('You will need Google again to manage the console.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await widget.authService.signOut();
    }
  }
}

class _GlassBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _GlassBottomNav({
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withValues(alpha: 0.12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  selected: index == 0,
                  icon: Icons.people_alt_rounded,
                  label: 'Users',
                  onTap: () => onChanged(0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  selected: index == 1,
                  icon: Icons.campaign_rounded,
                  label: 'Posts',
                  onTap: () => onChanged(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? MapDevTheme.cyan : Colors.white.withValues(alpha: 0.45);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
