import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../../models/user_profile.dart';
import '../../services/post_repository.dart';
import '../../theme/app_theme.dart';
import '../../theme/glass.dart';

/// Facebook-style feed of admin posts for the user app.
class PostsTab extends StatelessWidget {
  final UserProfile profile;

  const PostsTab({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final repo = PostRepository();
    final bottomPad = MediaQuery.paddingOf(context).bottom + 96;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
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
                  'Posts',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Updates from the MAP.DEV team',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Post>>(
              stream: repo.watchAll(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Could not load posts: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: MapDevTheme.red),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final posts = snapshot.data ?? [];
                if (posts.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
                    child: GlassPanel(
                      padding: const EdgeInsets.all(22),
                      child: Text(
                        'No posts yet. Check back soon for announcements.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          height: 1.4,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(22, 8, 22, bottomPad),
                  itemCount: posts.length,
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PostCard(
                      post: posts[i],
                      profile: profile,
                      repo: repo,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatefulWidget {
  final Post post;
  final UserProfile profile;
  final PostRepository repo;

  const _PostCard({
    required this.post,
    required this.profile,
    required this.repo,
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _liking = false;

  Future<void> _like(bool alreadyLiked) async {
    if (alreadyLiked || _liking) return;
    setState(() => _liking = true);
    try {
      final ok = await widget.repo.likePost(
        postId: widget.post.id,
        userEmail: widget.profile.email,
        username: widget.profile.username,
      );
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You already liked this post.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not like: $e')),
      );
    } finally {
      if (mounted) setState(() => _liking = false);
    }
  }

  Future<void> _openComments({required bool alreadyCommented}) async {
    final textCtrl = TextEditingController();
    var sending = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: MapDevTheme.bgPanel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(ctx).bottom,
              ),
              child: SafeArea(
                child: SizedBox(
                  height: MediaQuery.sizeOf(ctx).height * 0.62,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Comments',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              '${widget.post.commentCount}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.45),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder<List<PostComment>>(
                          stream: widget.repo.watchComments(widget.post.id),
                          builder: (context, snapshot) {
                            final comments = snapshot.data ?? [];
                            if (comments.isEmpty) {
                              return Center(
                                child: Text(
                                  'No comments yet.',
                                  style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.45),
                                  ),
                                ),
                              );
                            }
                            return ListView.separated(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 4, 20, 12),
                              itemCount: comments.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, i) {
                                final c = comments[i];
                                return GlassPanel(
                                  padding: const EdgeInsets.all(14),
                                  borderRadius: BorderRadius.circular(14),
                                  opacity: 0.1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              c.displayName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                                color: MapDevTheme.cyan,
                                              ),
                                            ),
                                          ),
                                          if (c.formattedDate.isNotEmpty)
                                            Text(
                                              c.formattedDate,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.white
                                                    .withValues(alpha: 0.35),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        c.text,
                                        style: TextStyle(
                                          height: 1.4,
                                          color: Colors.white
                                              .withValues(alpha: 0.85),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      if (alreadyCommented)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                          child: Text(
                            'You already commented on this post (one comment per user).',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.45),
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: textCtrl,
                                  minLines: 1,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    hintText: 'Write a comment…',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filled(
                                onPressed: sending
                                    ? null
                                    : () async {
                                        final text = textCtrl.text.trim();
                                        if (text.isEmpty) return;
                                        setSheetState(() => sending = true);
                                        try {
                                          await widget.repo.addComment(
                                            postId: widget.post.id,
                                            userEmail: widget.profile.email,
                                            username: widget.profile.username,
                                            text: text,
                                          );
                                          textCtrl.clear();
                                          if (ctx.mounted) {
                                            Navigator.pop(ctx);
                                          }
                                        } on AlreadyCommentedException catch (
                                            e) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(content: Text('$e')),
                                          );
                                        } catch (e) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Could not comment: $e',
                                              ),
                                            ),
                                          );
                                        } finally {
                                          if (ctx.mounted) {
                                            setSheetState(
                                              () => sending = false,
                                            );
                                          }
                                        }
                                      },
                                style: IconButton.styleFrom(
                                  backgroundColor: MapDevTheme.cyan,
                                  foregroundColor: Colors.white,
                                ),
                                icon: sending
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.send_rounded),
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
      },
    );
    textCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final email = widget.profile.email;

    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      borderRadius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: MapDevTheme.cyan.withValues(alpha: 0.22),
                child: Text(
                  (post.authorName.isEmpty ? 'M' : post.authorName[0])
                      .toUpperCase(),
                  style: const TextStyle(
                    color: MapDevTheme.cyan,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName.isEmpty
                          ? Post.defaultAuthorName
                          : post.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    if (post.formattedDate.isNotEmpty)
                      Text(
                        post.formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (post.title.isNotEmpty) ...[
            Text(
              post.title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: MapDevTheme.cyan,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            post.body.isEmpty ? 'No content' : post.body,
            style: TextStyle(
              height: 1.45,
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${post.likeCount} like${post.likeCount == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                '${post.commentCount} comment${post.commentCount == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
          Divider(height: 20, color: Colors.white.withValues(alpha: 0.12)),
          StreamBuilder<bool>(
            stream: widget.repo.watchHasLiked(
              postId: post.id,
              userEmail: email,
            ),
            builder: (context, likedSnap) {
              final liked = likedSnap.data ?? false;
              return StreamBuilder<PostComment?>(
                stream: widget.repo.watchMyComment(
                  postId: post.id,
                  userEmail: email,
                ),
                builder: (context, commentSnap) {
                  final myComment = commentSnap.data;
                  final alreadyCommented = myComment != null;

                  return Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: liked
                              ? Icons.thumb_up_alt
                              : Icons.thumb_up_alt_outlined,
                          label: liked ? 'Liked' : 'Like',
                          active: liked,
                          onTap: liked || _liking
                              ? null
                              : () => _like(liked),
                        ),
                      ),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: alreadyCommented ? 'Commented' : 'Comment',
                          active: alreadyCommented,
                          onTap: () => _openComments(
                            alreadyCommented: alreadyCommented,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active
        ? MapDevTheme.cyan
        : Colors.white.withValues(alpha: 0.7);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
