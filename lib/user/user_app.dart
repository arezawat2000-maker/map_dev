import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/app_request.dart';
import '../services/request_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/status_chip.dart';

class MapDevUserApp extends StatelessWidget {
  const MapDevUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAP.DEV',
      debugShowCheckedModeBanner: false,
      theme: MapDevTheme.dark(),
      home: const UserHomePage(),
    );
  }
}

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MAP.DEV',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: MapDevTheme.cyan,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.4,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Request a custom app and track where it stands.',
                      style: TextStyle(
                        color: MapDevTheme.muted,
                        fontSize: 16,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SubmitRequestPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Request an app'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MyRequestsPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.inbox_outlined),
                        label: const Text('My requests'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 36)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HOW IT WORKS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: MapDevTheme.muted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _StepRow(
                      number: '1',
                      title: 'Tell us what to build',
                      body: 'Share the app name, brief, and how to reach you.',
                    ),
                    _StepRow(
                      number: '2',
                      title: 'We review your request',
                      body: 'The MAP.DEV team updates status as work progresses.',
                    ),
                    _StepRow(
                      number: '3',
                      title: 'Track by email',
                      body:
                          'Look up your requests anytime with the email you used.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String number;
  final String title;
  final String body;

  const _StepRow({
    required this.number,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: MapDevTheme.border),
              borderRadius: BorderRadius.circular(8),
              color: MapDevTheme.bgPanel,
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: MapDevTheme.cyan,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: MapDevTheme.muted,
                    height: 1.4,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SubmitRequestPage extends StatefulWidget {
  const SubmitRequestPage({super.key});

  @override
  State<SubmitRequestPage> createState() => _SubmitRequestPageState();
}

class _SubmitRequestPageState extends State<SubmitRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _repo = RequestRepository();

  final _appName = TextEditingController();
  final _description = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _appName.dispose();
    _description.dispose();
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
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
            'Thanks — we will review "${draft.appName}" and update its status. '
            'Use My requests with ${_email.text.trim()} to track it.',
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not submit: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('REQUEST AN APP')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _appName,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'App name',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'App name is required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _description,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'App description',
                alignLabelWithHint: true,
              ),
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return 'Description is required';
                if (value.length < 12) {
                  return 'Add a bit more detail (at least a short sentence)';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Your name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return 'Email is required';
                if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d+\-\s()]')),
              ],
              decoration: const InputDecoration(labelText: 'Phone number'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Phone number is required'
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send request'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyRequestsPage extends StatefulWidget {
  const MyRequestsPage({super.key});

  @override
  State<MyRequestsPage> createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  final _formKey = GlobalKey<FormState>();
  final _repo = RequestRepository();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  String? _lookupEmail;
  String? _lookupPhone;

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _lookup() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _lookupEmail = _email.text.trim();
      final phone = _phone.text.trim();
      _lookupPhone = phone.isEmpty ? null : phone;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MY REQUESTS')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Enter the email you used when submitting. Phone is optional and narrows the match.',
            style: TextStyle(color: MapDevTheme.muted, height: 1.4),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'Email is required';
                    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone (optional)',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _lookup,
                    child: const Text('Find my requests'),
                  ),
                ),
              ],
            ),
          ),
          if (_lookupEmail != null) ...[
            const SizedBox(height: 28),
            StreamBuilder<List<AppRequest>>(
              stream: _repo.watchForContact(
                email: _lookupEmail!,
                phone: _lookupPhone,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: MapDevTheme.red),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'No requests found for that contact.',
                      style: TextStyle(color: MapDevTheme.muted),
                    ),
                  );
                }

                return Column(
                  children: items
                      .map((r) => UserRequestTile(request: r))
                      .toList(),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class UserRequestTile extends StatelessWidget {
  final AppRequest request;

  const UserRequestTile({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => UserRequestDetailPage(request: request),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MapDevTheme.bgPanel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MapDevTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.appName.isEmpty ? 'Untitled app' : request.appName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: MapDevTheme.cyan,
                    ),
                  ),
                ),
                StatusChip(status: request.status),
              ],
            ),
            if (request.formattedDate.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                request.formattedDate,
                style: const TextStyle(fontSize: 12, color: MapDevTheme.muted),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              request.appDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(height: 1.35, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class UserRequestDetailPage extends StatelessWidget {
  final AppRequest request;

  const UserRequestDetailPage({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('REQUEST DETAIL')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.appName.isEmpty
                      ? 'Untitled app'
                      : request.appName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: MapDevTheme.cyan,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              StatusChip(status: request.status),
            ],
          ),
          if (request.formattedDate.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Submitted ${request.formattedDate}',
              style: const TextStyle(color: MapDevTheme.muted),
            ),
          ],
          const SizedBox(height: 24),
          const _DetailLabel('STATUS'),
          const SizedBox(height: 6),
          Text(
            AppRequest.statusLabel(request.status),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          const _DetailLabel('DESCRIPTION'),
          const SizedBox(height: 6),
          Text(
            request.appDescription.isEmpty
                ? 'No description'
                : request.appDescription,
            style: const TextStyle(height: 1.45, fontSize: 15),
          ),
          const SizedBox(height: 20),
          const _DetailLabel('YOUR CONTACT'),
          const SizedBox(height: 6),
          Text(request.requesterName),
          Text(request.contact, style: const TextStyle(color: MapDevTheme.muted)),
          Text(
            request.phoneNumber,
            style: const TextStyle(color: MapDevTheme.muted),
          ),
        ],
      ),
    );
  }
}

class _DetailLabel extends StatelessWidget {
  final String text;

  const _DetailLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: MapDevTheme.muted,
      ),
    );
  }
}
