import 'package:flutter/material.dart';

import '../models/admin_profile.dart';
import '../models/user_profile.dart';
import '../services/user_profile_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/glass.dart';
import 'user_detail_page.dart';

class UsersTab extends StatelessWidget {
  final AdminProfile admin;
  final VoidCallback onSignOut;

  const UsersTab({
    super.key,
    required this.admin,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final repo = UserProfileRepository();
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
                        'Users',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Signed in as ${admin.displayName}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onSignOut,
                  tooltip: 'Sign out',
                  icon: const Icon(Icons.logout_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<UserProfile>>(
              stream: repo.watchAllProfiles(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Error: ${snapshot.error}',
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

                final users = snapshot.data ?? [];
                if (users.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
                    child: GlassPanel(
                      padding: const EdgeInsets.all(22),
                      child: Text(
                        'No user profiles yet.\n\n'
                        'Users appear after they sign in with Google and complete '
                        'profile setup (Firestore: users/{email}/informations/profile).',
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
                  itemCount: users.length,
                  itemBuilder: (context, i) {
                    final user = users[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlassPanel(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => UserDetailPage(
                                profile: user,
                                admin: admin,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: MapDevTheme.cyan
                                  .withValues(alpha: 0.2),
                              backgroundImage: user.photoUrl != null
                                  ? NetworkImage(user.photoUrl!)
                                  : null,
                              child: user.photoUrl == null
                                  ? Text(
                                      user.username.isNotEmpty
                                          ? user.username[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: MapDevTheme.cyan,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.username.isEmpty
                                        ? 'Unnamed'
                                        : user.username,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    user.email,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color:
                                          Colors.white.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  if (user.banned) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Banned',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: MapDevTheme.red
                                            .withValues(alpha: 0.9),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (user.banned)
                              const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.block_rounded,
                                  color: MapDevTheme.red,
                                  size: 20,
                                ),
                              )
                            else
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white.withValues(alpha: 0.35),
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
