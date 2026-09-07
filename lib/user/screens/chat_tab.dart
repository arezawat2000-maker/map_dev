import 'package:flutter/material.dart';

import '../../models/chat_message.dart';
import '../../models/chat_meta.dart';
import '../../models/user_profile.dart';
import '../../services/chat_repository.dart';
import '../../theme/app_theme.dart';
import '../../theme/glass.dart';

class ChatTab extends StatefulWidget {
  final UserProfile profile;
  final String emailId;

  const ChatTab({
    super.key,
    required this.profile,
    required this.emailId,
  });

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
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

  Future<void> _send({
    required bool canSend,
  }) async {
    if (!canSend) return;
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    _controller.clear();
    try {
      await _repo.sendUserMessage(
        emailId: widget.emailId,
        text: text,
        senderName: widget.profile.username,
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

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom + 88;

    return SafeArea(
      bottom: false,
      child: StreamBuilder<ChatMeta>(
        stream: _repo.watchMeta(widget.emailId),
        builder: (context, metaSnap) {
          final meta = metaSnap.data ?? const ChatMeta();

          return StreamBuilder<List<ChatMessage>>(
            stream: _repo.watchMessages(widget.emailId),
            builder: (context, msgSnap) {
              final messages = msgSnap.data ?? [];
              final empty = messages.isEmpty;
              final canSend = ChatMeta.canUserSend(
                chatEnabled: meta.chatEnabled,
                messagesEmpty: empty,
              );
              final waitingForAdmin = !empty && !meta.chatEnabled;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chat with admin',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.95),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                meta.chatEnabled
                                    ? 'Chat is open — send freely'
                                    : waitingForAdmin
                                        ? 'Waiting for admin to open chat'
                                        : 'You can send one message first',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: meta.chatEnabled
                                ? MapDevTheme.green
                                : waitingForAdmin
                                    ? MapDevTheme.amber
                                    : MapDevTheme.cyan,
                            boxShadow: [
                              BoxShadow(
                                color: (meta.chatEnabled
                                        ? MapDevTheme.green
                                        : waitingForAdmin
                                            ? MapDevTheme.amber
                                            : MapDevTheme.cyan)
                                    .withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (empty || waitingForAdmin)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: _ChatGateBanner(
                        empty: empty,
                        waitingForAdmin: waitingForAdmin,
                      ),
                    ),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (msgSnap.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'Chat unavailable: ${msgSnap.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: MapDevTheme.red),
                              ),
                            ),
                          );
                        }

                        if (empty) {
                          return const SizedBox.shrink();
                        }

                        _maybeScrollToEnd(messages.length);

                        return ListView.builder(
                          controller: _scroll,
                          padding:
                              EdgeInsets.fromLTRB(16, 8, 16, bottomPad - 60),
                          itemCount: messages.length,
                          itemBuilder: (context, i) {
                            return _Bubble(message: messages[i]);
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad),
                    child: canSend
                        ? GlassPanel(
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
                                    onSubmitted: (_) =>
                                        _send(canSend: canSend),
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: empty
                                          ? 'Send your first message…'
                                          : 'Message…',
                                      hintStyle: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.35),
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      filled: false,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton.filled(
                                  onPressed: _sending
                                      ? null
                                      : () => _send(canSend: canSend),
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
                          )
                        : GlassPanel(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            opacity: 0.1,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: 18,
                                  color: MapDevTheme.amber
                                      .withValues(alpha: 0.9),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Messaging locked until admin opens the chat.',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.65),
                                      fontSize: 13,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ChatGateBanner extends StatelessWidget {
  final bool empty;
  final bool waitingForAdmin;

  const _ChatGateBanner({
    required this.empty,
    required this.waitingForAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final title = empty
        ? 'One message first'
        : 'Chat is closed';
    final body = empty
        ? 'You can send only one message to start. After that, wait for admin to open the chat before sending more.'
        : 'Your message was sent. You cannot send more until an admin turns chat on.';

    return GlassPanel(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(16),
      opacity: 0.12,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            waitingForAdmin
                ? Icons.hourglass_top_rounded
                : Icons.warning_amber_rounded,
            color: MapDevTheme.amber,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: MapDevTheme.amber,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                    height: 1.4,
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

class _Bubble extends StatelessWidget {
  final ChatMessage message;

  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final mine = message.isFromUser;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
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
            if (!mine)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.displayNameForUser(),
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
    );
  }
}
