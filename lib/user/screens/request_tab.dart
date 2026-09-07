import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/app_request.dart';
import '../../models/user_profile.dart';
import '../../services/request_repository.dart';
import '../../theme/app_theme.dart';
import '../../theme/glass.dart';
import '../../widgets/status_chip.dart';
import 'submit_request_page.dart';

class RequestTab extends StatelessWidget {
  final UserProfile profile;
  final User user;
  final VoidCallback onSignOut;

  const RequestTab({
    super.key,
    required this.profile,
    required this.user,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final repo = RequestRepository();
    final bottomPad = MediaQuery.paddingOf(context).bottom + 96;

    return SafeArea(
      bottom: false,
      child: StreamBuilder<List<AppRequest>>(
        stream: repo.watchForContact(email: profile.email),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          AppRequest? active;
          for (final r in items) {
            if (r.isActive) {
              active = r;
              break;
            }
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MAP.DEV',
                              style: TextStyle(
                                color: MapDevTheme.cyan,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2.2,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Hi, ${profile.username}',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.95),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _ProfileMenu(
                        profile: profile,
                        photoUrl: user.photoURL ?? profile.photoUrl,
                        onSignOut: onSignOut,
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
                  child: active != null
                      ? _ActiveRequestBanner(request: active)
                      : GlassPanel(
                          padding: const EdgeInsets.all(18),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    SubmitRequestPage(profile: profile),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color:
                                      MapDevTheme.cyan.withValues(alpha: 0.2),
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: MapDevTheme.cyan,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Request an app',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Colors.white
                                            .withValues(alpha: 0.95),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Tell us what to build',
                                      style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.5),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 10),
                  child: Text(
                    'MY REQUESTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
              if (snapshot.hasError)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: MapDevTheme.red),
                    ),
                  ),
                )
              else if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (items.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
                    child: GlassPanel(
                      padding: const EdgeInsets.all(22),
                      child: Text(
                        'No requests yet. Tap “Request an app” to get started.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(22, 0, 22, bottomPad),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _RequestCard(request: items[i]),
                      ),
                      childCount: items.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ActiveRequestBanner extends StatelessWidget {
  final AppRequest request;

  const _ActiveRequestBanner({required this.request});

  @override
  Widget build(BuildContext context) {
    final label = AppRequest.statusLabel(request.status);
    final eta = request.etaDisplay;
    final showEta =
        request.stage == AppRequest.statusAccepted && eta != null;

    return GlassPanel(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: MapDevTheme.amber.withValues(alpha: 0.18),
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              color: MapDevTheme.amber,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You already have an app request in progress',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.95),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${request.appName.isEmpty ? 'Untitled app' : request.appName} · $label',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                if (showEta) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Estimated: $eta',
                    style: const TextStyle(
                      color: MapDevTheme.cyan,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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

class _ProfileMenu extends StatelessWidget {
  final UserProfile profile;
  final String? photoUrl;
  final VoidCallback onSignOut;

  const _ProfileMenu({
    required this.profile,
    required this.photoUrl,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'signout') onSignOut();
      },
      offset: const Offset(0, 48),
      color: MapDevTheme.bgPanel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.username,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                profile.email,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'signout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 18),
              SizedBox(width: 10),
              Text('Sign out'),
            ],
          ),
        ),
      ],
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white12,
        backgroundImage:
            photoUrl != null ? NetworkImage(photoUrl!) : null,
        child: photoUrl == null
            ? Text(
                profile.username.isNotEmpty
                    ? profile.username[0].toUpperCase()
                    : '?',
                style: const TextStyle(fontWeight: FontWeight.w700),
              )
            : null,
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final AppRequest request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RequestDetailPage(request: request),
          ),
        );
      },
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ],
          if (request.stage == AppRequest.statusAccepted &&
              request.hasEta) ...[
            const SizedBox(height: 8),
            Text(
              'Estimated: ${request.etaDisplay}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: MapDevTheme.cyan,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            request.appDescription,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              height: 1.35,
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class RequestDetailPage extends StatelessWidget {
  final AppRequest request;

  const RequestDetailPage({super.key, required this.request});

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
                        'Request detail',
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
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
                  children: [
                    GlassPanel(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  request.appName.isEmpty
                                      ? 'Untitled app'
                                      : request.appName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: MapDevTheme.cyan,
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
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.45),
                              ),
                            ),
                          ],
                          const SizedBox(height: 22),
                          _label('PROGRESS'),
                          const SizedBox(height: 12),
                          RequestProgressTracker(request: request),
                          if (request.stage == AppRequest.statusAccepted &&
                              request.hasEta) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: MapDevTheme.cyan.withValues(alpha: 0.12),
                                border: Border.all(
                                  color:
                                      MapDevTheme.cyan.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.schedule_rounded,
                                    size: 18,
                                    color: MapDevTheme.cyan,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Estimated: ${request.etaDisplay}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: MapDevTheme.cyan,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (request.stage == AppRequest.statusCompleted &&
                              request.hasEta) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Was estimated: ${request.etaDisplay}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.45),
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          _label('DESCRIPTION'),
                          const SizedBox(height: 6),
                          Text(
                            request.appDescription.isEmpty
                                ? 'No description'
                                : request.appDescription,
                            style: const TextStyle(height: 1.45, fontSize: 15),
                          ),
                          const SizedBox(height: 18),
                          _label('CONTACT'),
                          const SizedBox(height: 6),
                          Text(request.requesterName),
                          Text(
                            request.contact,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          Text(
                            request.phoneNumber,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: Colors.white.withValues(alpha: 0.4),
      ),
    );
  }
}

/// Visual 3-step progress: Pending → Accepted → Done.
class RequestProgressTracker extends StatelessWidget {
  final AppRequest request;

  const RequestProgressTracker({super.key, required this.request});

  static const _steps = [
    (AppRequest.statusPending, 'Pending'),
    (AppRequest.statusAccepted, 'Accepted'),
    (AppRequest.statusCompleted, 'Done'),
  ];

  @override
  Widget build(BuildContext context) {
    if (request.stage == AppRequest.statusDeclined) {
      return Text(
        'This request was declined.',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: MapDevTheme.red.withValues(alpha: 0.9),
        ),
      );
    }

    final current = request.step.clamp(0, 2);

    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < _steps.length; i++) ...[
              if (i > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: i <= current
                        ? MapDevTheme.cyan.withValues(alpha: 0.7)
                        : Colors.white.withValues(alpha: 0.12),
                  ),
                ),
              _StepDot(
                index: i,
                active: i <= current,
                current: i == current,
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < _steps.length; i++)
              Expanded(
                child: Text(
                  _steps[i].$2,
                  textAlign: i == 0
                      ? TextAlign.left
                      : i == 2
                          ? TextAlign.right
                          : TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        i == current ? FontWeight.w700 : FontWeight.w500,
                    color: i <= current
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.35),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final bool active;
  final bool current;

  const _StepDot({
    required this.index,
    required this.active,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? MapDevTheme.cyan : Colors.white.withValues(alpha: 0.2);
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? MapDevTheme.cyan.withValues(alpha: current ? 0.28 : 0.16)
            : Colors.white.withValues(alpha: 0.06),
        border: Border.all(
          color: color,
          width: current ? 2 : 1.2,
        ),
      ),
      alignment: Alignment.center,
      child: active && index < 2 && !current
          ? const Icon(Icons.check_rounded, size: 14, color: MapDevTheme.cyan)
          : Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: active
                    ? MapDevTheme.cyan
                    : Colors.white.withValues(alpha: 0.35),
              ),
            ),
    );
  }
}
