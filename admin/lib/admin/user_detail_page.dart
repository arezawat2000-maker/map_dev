import 'package:flutter/material.dart';

import '../models/admin_profile.dart';
import '../models/app_request.dart';
import '../models/chat_message.dart';
import '../models/chat_meta.dart';
import '../models/user_profile.dart';
import '../services/chat_repository.dart';
import '../services/request_repository.dart';
import '../services/user_profile_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_request_card.dart';
import '../widgets/glass.dart';

class UserDetailPage extends StatefulWidget {
  final UserProfile profile;
  final AdminProfile admin;

  const UserDetailPage({
    super.key,
    required this.profile,
    required this.admin,
  });

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _profiles = UserProfileRepository();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _confirmBan(UserProfile profile) async {
    if (profile.banned) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MapDevTheme.bgPanel,
        title: const Text('Ban user?'),
        content: Text(
          'Ban ${profile.username.isEmpty ? profile.email : profile.username}?\n\n'
          'They will only see a ban screen with a Log out button.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: MapDevTheme.red),
            child: const Text('Ban'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _profiles.banUser(
        emailId: profile.email,
        bannedBy: widget.admin.email,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Banned ${profile.email}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not ban: $e')),
      );
    }
  }

  Future<void> _confirmUnban(UserProfile profile) async {
    if (!profile.banned) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MapDevTheme.bgPanel,
        title: const Text('Unban user?'),
        content: Text('Restore access for ${profile.email}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Unban'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _profiles.unbanUser(profile.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User unbanned')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not unban: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfile?>(
      stream: _profiles.watchProfile(widget.profile.email),
      builder: (context, snap) {
        final profile = snap.data ?? widget.profile;
        final title =
            profile.username.isEmpty ? profile.email : profile.username;

        return Scaffold(
          body: GlassBackdrop(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                profile.email,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.45),
                                ),
                              ),
                              if (profile.banned)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text(
                                    'BANNED',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                      color: MapDevTheme.red,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: profile.banned ? 'Unban' : 'Ban user',
                          onPressed: () => profile.banned
                              ? _confirmUnban(profile)
                              : _confirmBan(profile),
                          icon: Icon(
                            profile.banned
                                ? Icons.lock_open_rounded
                                : Icons.block_rounded,
                            color: profile.banned
                                ? MapDevTheme.green
                                : MapDevTheme.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabs,
                    indicatorColor: MapDevTheme.cyan,
                    labelColor: MapDevTheme.cyan,
                    unselectedLabelColor: MapDevTheme.muted,
                    tabs: const [
                      Tab(text: 'Requests'),
                      Tab(text: 'Chat'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabs,
                      children: [
                        _UserRequestsTab(email: profile.email),
                        _UserChatTab(
                          emailId: profile.email,
                          admin: widget.admin,
                          userLabel: profile.username.isEmpty
                              ? profile.email
                              : profile.username,
                          banned: profile.banned,
                          onBan: () => _confirmBan(profile),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UserRequestsTab extends StatelessWidget {
  final String email;

  const _UserRequestsTab({required this.email});

  @override
  Widget build(BuildContext context) {
    final repo = RequestRepository();

    return StreamBuilder<List<AppRequest>>(
      stream: repo.watchForContact(email: email),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Could not load requests:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: MapDevTheme.red, height: 1.4),
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No requests for $email yet.\n'
                'Requests appear when contact email matches this user.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: MapDevTheme.muted, height: 1.4),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return AdminRequestCard(
              key: ValueKey(request.id),
              request: request,
              onStatusChanged: (status, {estimatedDuration}) =>
                  repo.updateStatus(
                request.id,
                status,
                estimatedDuration: estimatedDuration,
              ),
              onEtaChanged: (eta) =>
                  repo.updateEstimatedDuration(request.id, eta),
            );
          },
        );
      },
    );
  }
}

class _UserChatTab extends StatefulWidget {
  final String emailId;
  final AdminProfile admin;
  final String userLabel;
  final bool banned;
  final VoidCallback onBan;

  const _UserChatTab({
    required this.emailId,
    required this.admin,
    required this.userLabel,
    required this.banned,
    required this.onBan,
  });

  @override
  State<_UserChatTab> createState() => _UserChatTabState();
}

class _UserChatTabState extends State<_UserChatTab> {
  final _repo = ChatRepository();
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;
  int _lastCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _maybeScrollToEnd(int count) {
    if (count <= _lastCount) {
      _lastCount = count;
      return;
    }
    _lastCount = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    _controller.clear();
    try {
      await _repo.sendAdminMessage(
        emailId: widget.emailId,
        text: text,
        senderName: widget.admin.displayName,
        senderEmail: widget.admin.email,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not send: $e')),
      );
      _controller.text = text;
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _toggleChat(bool enabled) async {
    try {
      await _repo.setChatEnabled(widget.emailId, enabled);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update chat: $e')),
      );
    }
  }

  void _openSettings(ChatMeta meta) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: MapDevTheme.bgPanel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chat settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Control whether ${widget.userLabel} can send messages freely.',
                  style: const TextStyle(
                    color: MapDevTheme.muted,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Chat enabled'),
                  subtitle: Text(
                    meta.chatEnabled
                        ? 'User can send freely'
                        : 'User blocked after first message',
                  ),
                  value: meta.chatEnabled,
                  activeThumbColor: MapDevTheme.cyan,
                  onChanged: (v) {
                    Navigator.pop(ctx);
                    _toggleChat(v);
                  },
                ),
                if (!widget.banned) ...[
                  const Divider(height: 28),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.block_rounded,
                      color: MapDevTheme.red,
                    ),
                    title: const Text('Ban user'),
                    subtitle: const Text(
                      'Hard-lock their app to a ban screen',
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      widget.onBan();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ChatMeta>(
      stream: _repo.watchMeta(widget.emailId),
      builder: (context, metaSnap) {
        final meta = metaSnap.data ?? const ChatMeta();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.banned
                          ? 'This user is banned'
                          : meta.chatEnabled
                              ? 'Chat is ON for this user'
                              : 'Chat is OFF — user can send only the first message',
                      style: TextStyle(
                        fontSize: 13,
                        color: widget.banned
                            ? MapDevTheme.red.withValues(alpha: 0.85)
                            : Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                  if (!widget.banned)
                    IconButton(
                      tooltip: 'Ban user',
                      onPressed: widget.onBan,
                      icon: const Icon(Icons.block_rounded),
                      color: MapDevTheme.red,
                    ),
                  IconButton(
                    tooltip: 'Chat settings',
                    onPressed: () => _openSettings(meta),
                    icon: const Icon(Icons.settings_rounded),
                    color: MapDevTheme.cyan,
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: _repo.watchMessages(widget.emailId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Chat unavailable:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: MapDevTheme.red,
                            height: 1.4,
                          ),
                        ),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data ?? [];
                  if (messages.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'No messages yet for ${widget.emailId}.\n'
                          'You can always send; the user may send one first message until you enable chat.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            height: 1.4,
                          ),
                        ),
                      ),
                    );
                  }

                  _maybeScrollToEnd(messages.length);

                  return ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final message = messages[i];
                      return _AdminBubble(
                        message: message,
                        onLongPressUser: !widget.banned && message.isFromUser
                            ? widget.onBan
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: GlassPanel(
                padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                borderRadius: BorderRadius.circular(24),
                opacity: 0.16,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Reply as ${widget.admin.displayName}…',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    IconButton.filled(
                      onPressed: _sending ? null : _send,
                      style: IconButton.styleFrom(
                        backgroundColor: MapDevTheme.cyan,
                        foregroundColor: Colors.white,
                      ),
                      icon: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.arrow_upward_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AdminBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onLongPressUser;

  const _AdminBubble({
    required this.message,
    this.onLongPressUser,
  });

  @override
  Widget build(BuildContext context) {
    final mine = message.isFromAdmin;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPressUser,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(mine ? 18 : 4),
              bottomRight: Radius.circular(mine ? 4 : 18),
            ),
            color: mine
                ? MapDevTheme.cyan.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.12),
            border: Border.all(
              color: mine
                  ? MapDevTheme.cyan.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.14),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.displayNameForAdmin(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ),
              Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  height: 1.35,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
