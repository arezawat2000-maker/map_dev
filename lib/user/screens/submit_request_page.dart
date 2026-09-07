import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/app_request.dart';
import '../../models/user_profile.dart';
import '../../services/request_repository.dart';
import '../../theme/app_theme.dart';
import '../../theme/glass.dart';

class SubmitRequestPage extends StatefulWidget {
  final UserProfile profile;

  const SubmitRequestPage({super.key, required this.profile});

  @override
  State<SubmitRequestPage> createState() => _SubmitRequestPageState();
}

class _SubmitRequestPageState extends State<SubmitRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _repo = RequestRepository();

  final _appName = TextEditingController();
  final _description = TextEditingController();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;

  bool _submitting = false;
  bool _checkingActive = true;
  AppRequest? _activeRequest;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.username);
    _email = TextEditingController(text: widget.profile.email);
    _phone = TextEditingController(text: widget.profile.phone);
    _loadActiveRequest();
  }

  Future<void> _loadActiveRequest() async {
    try {
      final active =
          await _repo.findActiveForEmail(widget.profile.email);
      if (!mounted) return;
      setState(() {
        _activeRequest = active;
        _checkingActive = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _checkingActive = false);
    }
  }

  @override
  void dispose() {
    _appName.dispose();
    _description.dispose();
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  bool get _blocked => _activeRequest != null;

  Future<void> _submit() async {
    if (_blocked) {
      _showBlockedSnack();
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      final draft = AppRequest(
        id: '',
        appName: _appName.text.trim(),
        appDescription: _description.text.trim(),
        requesterName: _name.text.trim(),
        contact: _email.text.trim(),
        phoneNumber: _phone.text.trim(),
        status: AppRequest.statusPending,
      );
      await _repo.create(draft);

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: MapDevTheme.bgPanel,
          title: const Text('Request received'),
          content: Text(
            'Thanks — we will review "${draft.appName}" and update its status.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } on ActiveRequestException catch (e) {
      if (!mounted) return;
      setState(() => _activeRequest = e.active);
      _showBlockedSnack();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not submit: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showBlockedSnack() {
    final label = _activeRequest != null
        ? AppRequest.statusLabel(_activeRequest!.status)
        : 'in progress';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'You already have an app request in progress ($label).',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const Expanded(
                      child: Text(
                        'Request an app',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: _checkingActive
                    ? const Center(child: CircularProgressIndicator())
                    : Form(
                        key: _formKey,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
                          children: [
                            if (_blocked) ...[
                              _BlockedBanner(request: _activeRequest!),
                              const SizedBox(height: 14),
                            ],
                            GlassPanel(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _appName,
                                    enabled: !_blocked,
                                    textInputAction: TextInputAction.next,
                                    decoration: glassInputDecoration(
                                      label: 'App name',
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'App name is required'
                                            : null,
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _description,
                                    enabled: !_blocked,
                                    minLines: 4,
                                    maxLines: 8,
                                    decoration: glassInputDecoration(
                                      label: 'App description',
                                    ).copyWith(alignLabelWithHint: true),
                                    validator: (v) {
                                      final value = v?.trim() ?? '';
                                      if (value.isEmpty) {
                                        return 'Description is required';
                                      }
                                      if (value.length < 12) {
                                        return 'Add a bit more detail';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _name,
                                    enabled: !_blocked,
                                    textInputAction: TextInputAction.next,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: glassInputDecoration(
                                      label: 'Your name',
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Name is required'
                                            : null,
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _email,
                                    enabled: false,
                                    decoration: glassInputDecoration(
                                      label: 'Email',
                                      locked: true,
                                      suffixIcon: Icon(
                                        Icons.lock_outline,
                                        size: 18,
                                        color: Colors.white
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _phone,
                                    enabled: !_blocked,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[\d+\-\s()]'),
                                      ),
                                    ],
                                    decoration: glassInputDecoration(
                                      label: 'Phone number',
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Phone number is required'
                                            : null,
                                  ),
                                  const SizedBox(height: 24),
                                  GlassPrimaryButton(
                                    label: _blocked
                                        ? 'Request in progress'
                                        : 'Send request',
                                    loading: _submitting,
                                    onPressed: _blocked ? null : _submit,
                                  ),
                                ],
                              ),
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

class _BlockedBanner extends StatelessWidget {
  final AppRequest request;

  const _BlockedBanner({required this.request});

  @override
  Widget build(BuildContext context) {
    final label = AppRequest.statusLabel(request.status);
    final name =
        request.appName.isEmpty ? 'Untitled app' : request.appName;

    return GlassPanel(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: MapDevTheme.amber.withValues(alpha: 0.18),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: MapDevTheme.amber,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You already have an app request in progress',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.95),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$name · $label',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.55),
                    height: 1.35,
                  ),
                ),
                if (request.stage == AppRequest.statusAccepted &&
                    request.hasEta) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Estimated: ${request.etaDisplay}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: MapDevTheme.cyan,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
