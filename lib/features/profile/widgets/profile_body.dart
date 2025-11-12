import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kaboodle_app/providers/user_provider.dart';
import 'package:kaboodle_app/services/auth/auth_service.dart';
import 'package:kaboodle_app/features/profile/widgets/settings_tile.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ProfileBody extends ConsumerWidget {
  const ProfileBody({super.key});

  String _formatMemberSince(DateTime? creationTime) {
    if (creationTime == null) return 'Unknown';
    return DateFormat('MMMM yyyy').format(creationTime);
  }

  String _formatDisplayName(String? displayName, String email) {
    // If display name exists, use first name only
    if (displayName != null && displayName.isNotEmpty) {
      return displayName.split(' ').first;
    }

    // Otherwise, use email username with ellipsis if too long
    final username = email.split('@').first;
    if (username.length > 12) {
      return '${username.substring(0, 12)}...';
    }
    return username;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);

    // TanStack Query pattern: Load data on demand if not already loaded
    if (!userState.hasLoaded && !userState.isLoading) {
      print('🎯 [ProfileBody] Triggering user profile load');
      // Trigger load after build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(userProvider.notifier).loadUserProfile();
      });
    }

    // Loading state
    if (userState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Error state
    if (userState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load profile',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              userState.error!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(userProvider.notifier).refreshUserProfile();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // No user data
    if (userState.user == null) {
      return const Center(
        child: Text('No user data available'),
      );
    }

    final user = userState.user!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Rounded square profile picture
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[300],
              ),
              clipBehavior: Clip.antiAlias,
              child: user.photoUrl != null
                  ? Image.network(
                      user.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey[600],
                        );
                      },
                    )
                  : Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey[600],
                    ),
            ),
            const SizedBox(height: 16),

            // Greeting with name
            Text(
              'Hey, ${_formatDisplayName(user.displayName, user.email)} ✌️',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Member since
            Text(
              'Member since ${_formatMemberSince(user.createdAt)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),

            // Settings tiles
            Column(
              children: [
                SettingsTile(
                  icon: Icons.person,
                  iconColor: Theme.of(context).colorScheme.primary,
                  text: 'Profile',
                  onTap: () {
                    CupertinoScaffold.showCupertinoModalBottomSheet(
                      context: context,
                      expand: false,
                      builder: (context) => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text(
                            'profile body',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    );
                  },
                  showDivider: false,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      'App Styles',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SettingsTileGroup(
                  tiles: [
                    SettingsTile(
                      icon: Icons.dark_mode,
                      iconColor: Theme.of(context).colorScheme.primary,
                      text: 'App Theme',
                      onTap: () {
                        // Dark mode action
                      },
                      isGrouped: true,
                    ),
                    SettingsTile(
                      icon: Icons.light_mode,
                      iconColor: Theme.of(context).colorScheme.primary,
                      text: 'Icon Style',
                      onTap: () {
                        // Light mode action
                      },
                      isGrouped: true,
                      showDivider: false,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SettingsTile(
                  icon: Icons.language,
                  iconColor: Theme.of(context).colorScheme.primary,
                  text: 'Automatic Time Zone',
                  onTap: () {
                    // Automatic time zone action
                  },
                  showDivider: false,
                  showChevron: false,
                ),
                const SizedBox(height: 16),
                SettingsTile(
                  icon: Icons.credit_card,
                  iconColor: Colors.amber,
                  text: 'Manage Subscription',
                  onTap: () {
                    // Manage subscription action
                  },
                  showDivider: false,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      'Support & Feedback',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SettingsTileGroup(
                  tiles: [
                    SettingsTile(
                      icon: Icons.star_outline,
                      iconColor: Colors.purple,
                      text: 'Give Feedback',
                      onTap: () {
                        // Give feedback action
                      },
                      isGrouped: true,
                    ),
                    SettingsTile(
                      icon: Icons.info,
                      iconColor: Theme.of(context).colorScheme.primary,
                      text: 'Help & Support',
                      onTap: () {
                        // Light mode action
                      },
                      isGrouped: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      'Legal',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SettingsTileGroup(
                  tiles: [
                    SettingsTile(
                      iconColor: Theme.of(context).colorScheme.primary,
                      text: 'Terms of Service',
                      onTap: () {
                        // Terms of service action
                      },
                      isGrouped: true,
                    ),
                    SettingsTile(
                      iconColor: Theme.of(context).colorScheme.primary,
                      text: 'Privacy Policy',
                      onTap: () {
                        // Privacy policy action
                      },
                      isGrouped: true,
                    ),
                    SettingsTile(
                      iconColor: Theme.of(context).colorScheme.primary,
                      text: 'Data Deletion',
                      onTap: () {
                        // Data deletion action
                      },
                      isGrouped: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SettingsTile(
                  icon: Icons.logout,
                  iconColor: Colors.red,
                  text: 'Logout',
                  onTap: () {
                    AuthService().signout(context: context, ref: ref);
                  },
                  showDivider: false,
                  showChevron: false,
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Version text
            // todo: make this dynamic
            Center(
              child: Text(
                'v 1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
