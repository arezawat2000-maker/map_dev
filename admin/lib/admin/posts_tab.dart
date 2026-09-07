import 'package:flutter/material.dart';

import '../models/admin_profile.dart';
import '../models/post.dart';
import '../services/post_repository.dart';
import '../services/user_profile_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/glass.dart';

class PostsTab extends StatelessWidget {
  final AdminProfile admin;

  const PostsTab({super.key, required this.admin});

  Future<void> _createOrEdit(
    BuildContext context, {
    Post? existing,
  }) async {
    final repo = PostRepository();
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final bodyCtrl = TextEditingController(text: existing?.body ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: MapDevTheme.bgPanel,
          title: Text(existing == null ? 'New post' : 'Edit post'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bodyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Body',
                  ),
                  minLines: 4,
                  maxLines: 8,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(existing == null ? 'Publish' : 'Save'),
            ),
          ],
        );
      },
    );

    if (saved != true) {
      titleCtrl.dispose();
      bodyCtrl.dispose();
      return;
    }

    final title = titleCtrl.text.trim();
    final body = bodyCtrl.text.trim();
    titleCtrl.dispose();
    bodyCtrl.dispose();

    if (title.isEmpty && body.isEmpty) return;

    try {
      if (existing == null) {
        await repo.create(title: title, body: body);
      } else {
        await repo.update(id: existing.id, title: title, body: body);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save post: $e')),
      );
    }
  }

  Future<void> _delete(BuildContext context, Post post) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MapDevTheme.bgPanel,
        title: const Text('Delete post?'),
        content: Text(post.title.isEmpty ? 'This post' : '"${post.title}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await PostRepository().delete(post.id);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete: $e')),
      );
    }
  }

  Future<void> _banFromComment(
    BuildContext context,
    PostComment comment,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MapDevTheme.bgPanel,
        title: const Text('Ban user?'),
        content: Text(
          'Ban ${comment.displayName} (${comment.userEmail})?\n\n'
          'They will only see a ban screen and can log out.',
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
      await UserProfileRepository().banUser(
        emailId: comment.userEmail,
        bannedBy: admin.email,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Banned ${comment.userEmail}')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not ban: $e')),
      );
    }
  }

  Future<void> _showComments(BuildContext context, Post post) async {
    final repo = PostRepository();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: MapDevTheme.bgPanel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
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
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Long-press a comment to ban its author',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<PostComment>>(
                    stream: repo.watchComments(post.id),
                    builder: (context, snapshot) {
                      final comments = snapshot.data ?? [];
                      if (comments.isEmpty) {
                        return Center(
                          child: Text(
                            'No comments yet.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                        itemCount: comments.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final c = comments[i];
                          return GestureDetector(
                            onLongPress: () => _banFromComment(context, c),
                            child: GlassPanel(
                              padding: const EdgeInsets.all(14),
                              borderRadius: BorderRadius.circular(14),
                              opacity: 0.1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  Text(
                                    c.userEmail,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          Colors.white.withValues(alpha: 0.35),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    c.text,
                                    style: TextStyle(
                                      height: 1.4,
                                      color:
                                          Colors.white.withValues(alpha: 0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MAP.DEV ADMIN',
                        style: TextStyle(
                          color: MapDevTheme.cyan,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                          fontSize: 12,
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
                        'Published to the user Posts tab',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _createOrEdit(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('New'),
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
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: MapDevTheme.red),
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
                        'No posts yet. Tap New to publish an announcement.',
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
                  itemBuilder: (context, i) {
                    final post = posts[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassPanel(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                        borderRadius: BorderRadius.circular(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor:
                                      MapDevTheme.cyan.withValues(alpha: 0.22),
                                  child: const Text(
                                    'M',
                                    style: TextStyle(
                                      color: MapDevTheme.cyan,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        post.authorName.isEmpty
                                            ? Post.defaultAuthorName
                                            : post.authorName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (post.formattedDate.isNotEmpty)
                                        Text(
                                          post.formattedDate,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.white
                                                .withValues(alpha: 0.4),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Edit',
                                  onPressed: () =>
                                      _createOrEdit(context, existing: post),
                                  icon: const Icon(Icons.edit_outlined,
                                      size: 20),
                                ),
                                IconButton(
                                  tooltip: 'Delete',
                                  onPressed: () => _delete(context, post),
                                  icon: const Icon(Icons.delete_outline,
                                      size: 20),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (post.title.isNotEmpty) ...[
                              Text(
                                post.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: MapDevTheme.cyan,
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                            Text(
                              post.body.isEmpty ? 'No content' : post.body,
                              style: TextStyle(
                                height: 1.45,
                                fontSize: 15,
                                color: Colors.white.withValues(alpha: 0.82),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.thumb_up_alt_outlined,
                                  size: 16,
                                  color: Colors.white.withValues(alpha: 0.45),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${post.likeCount}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        Colors.white.withValues(alpha: 0.55),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                InkWell(
                                  onTap: () => _showComments(context, post),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.chat_bubble_outline_rounded,
                                          size: 16,
                                          color: Colors.white
                                              .withValues(alpha: 0.45),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${post.commentCount} comments',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white
                                                .withValues(alpha: 0.55),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
