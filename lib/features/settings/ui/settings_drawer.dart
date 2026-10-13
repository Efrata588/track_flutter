import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/widgets/app_logo.dart';
import '../../auth/state/auth_controller.dart';
import '../../tasks/state/tasks_controller.dart';

class SettingsDrawer extends ConsumerWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with App Logo and title
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 20, bottom: 20),
              child: const AppLogo(size: 32),
            ),
            const Divider(height: 1),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                children: [
                  ListTile(
                    leading: Icon(
                      LucideIcons.layoutGrid,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    title: const Text('Dashboard'),
                    selected: true,
                    selectedTileColor: theme.colorScheme.primary.withValues(
                      alpha: 0.08,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go('/dashboard');
                    },
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Text(
                      'SETTINGS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.user, size: 20),
                    title: const Text('Profile'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/settings/profile');
                    },
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.sunMedium, size: 20),
                    title: const Text('Appearance'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/settings/appearance');
                    },
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.shieldCheck, size: 20),
                    title: const Text('Security'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/settings/security');
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Footer User Profile & Logout
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  if (user != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.15),
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  user.email,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 6),
                  ListTile(
                    leading: Icon(
                      LucideIcons.logOut,
                      size: 20,
                      color: theme.colorScheme.error,
                    ),
                    title: Text(
                      'Log out',
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      ref.read(tasksControllerProvider.notifier).clear();
                      await ref.read(authControllerProvider.notifier).logout();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
