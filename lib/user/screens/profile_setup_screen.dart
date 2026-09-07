import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/user_profile.dart';
import '../../services/user_profile_repository.dart';
import '../../theme/app_theme.dart';
import '../../theme/glass.dart';

class ProfileSetupScreen extends StatefulWidget {
  final User user;
  final String emailId;
  final UserProfile? existing;
  final UserProfileRepository profiles;

  const ProfileSetupScreen({
    super.key,
    required this.user,
    required this.emailId,
    required this.profiles,
    this.existing,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _username;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final googleName = widget.user.displayName?.trim() ?? '';
    _username = TextEditingController(
      text: existing?.username.isNotEmpty == true
          ? existing!.username
          : googleName,
    );
    _phone = TextEditingController(text: existing?.phone ?? '');
    _email = TextEditingController(text: widget.emailId);
  }

  @override
  void dispose() {
    _username.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final profile = UserProfile(
        email: widget.emailId,
        username: _username.text.trim(),
        phone: _phone.text.trim(),
        photoUrl: widget.user.photoURL,
        displayName: widget.user.displayName,
        createdAt: widget.existing?.createdAt,
      );
      await widget.profiles.saveProfile(profile);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
            children: [
              Text(
                'MAP.DEV',
                style: TextStyle(
                  color: MapDevTheme.cyan,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.4,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Set up your profile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a username and phone so we can reach you about your requests.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              GlassPanel(
                padding: const EdgeInsets.all(22),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (widget.user.photoURL != null) ...[
                        CircleAvatar(
                          radius: 36,
                          backgroundImage: NetworkImage(widget.user.photoURL!),
                          backgroundColor: Colors.white12,
                        ),
                        const SizedBox(height: 20),
                      ],
                      TextFormField(
                        controller: _username,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        decoration: glassInputDecoration(
                          label: 'Username',
                          hint: 'How should we call you?',
                        ),
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.isEmpty) return 'Username is required';
                          if (value.length < 2) return 'At least 2 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[\d+\-\s()]'),
                          ),
                        ],
                        decoration: glassInputDecoration(
                          label: 'Phone',
                          hint: '+1 555 000 0000',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Phone is required'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _email,
                        enabled: false,
                        decoration: glassInputDecoration(
                          label: 'Email (from Google)',
                          locked: true,
                          suffixIcon: Icon(
                            Icons.lock_outline,
                            size: 18,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      GlassPrimaryButton(
                        label: 'Continue',
                        loading: _saving,
                        onPressed: _save,
                        icon: Icons.arrow_forward_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
