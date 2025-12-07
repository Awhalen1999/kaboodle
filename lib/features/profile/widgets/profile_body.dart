import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaboodle_app/models/user.dart';
import 'package:kaboodle_app/providers/user_provider.dart';
import 'package:kaboodle_app/providers/theme_provider.dart';
import 'package:kaboodle_app/shared/constants/theme_constants.dart';
import 'package:kaboodle_app/services/auth/auth_service.dart';
import 'package:kaboodle_app/shared/utils/country_utils.dart';
import 'package:kaboodle_app/shared/utils/format_utils.dart';
import 'package:lottie/lottie.dart';
import 'package:kaboodle_app/features/profile/widgets/settings_tile.dart';
import 'package:kaboodle_app/features/profile/widgets/theme_switch.dart';

class ProfileBody extends ConsumerWidget {
  const ProfileBody({super.key});

  // Helper function to format ColorMode for display
  String _formatColorMode(ColorMode mode) {
    switch (mode) {
      case ColorMode.light:
        return 'Light';
      case ColorMode.dark:
        return 'Dark';
      case ColorMode.system:
        return 'System default';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          print('⚠️ [ProfileBody] User data is null');
          return const Center(
            child: Text('No user data available'),
          );
        }

        print(
            '✅ [ProfileBody] User data received: ${user.displayName ?? user.email}');
        return _buildProfileContent(context, ref, user);
      },
      loading: () {
        print('⏳ [ProfileBody] User loading...');
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
      error: (error, stackTrace) {
        print('❌ [ProfileBody] User error: $error');
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load profile',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.read(userProvider.notifier).refresh();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileContent(BuildContext context, WidgetRef ref, User user) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Sleeping cat animation
            Container(
              width: double.infinity,
              height: 180,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Transform.scale(
                  scale: 1.35,
                  child: Lottie.asset(
                    'assets/lottie/sleeping_cat.json',
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: 180,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Greeting with name
            Text(
              'Hey, ${FormatUtils.formatDisplayName(user.displayName, user.email)} ✌️',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Member since with country flag
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (user.country != null && user.country!.isNotEmpty) ...[
                  CountryUtils.getCountryFlag(user.country!),
                  const SizedBox(width: 8),
                ],
                Text(
                  'Member since ${FormatUtils.formatMemberSince(user.createdAt)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Settings tiles
            Column(
              children: [
                SettingsTile(
                  icon: Icons.person_rounded,
                  iconColor: Theme.of(context).colorScheme.primary,
                  text: 'Profile',
                  onTap: () {
                    context.push('/profile-edit');
                  },
                  showDivider: false,
                ),
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    // Use select() to only rebuild when colorMode changes, not themeMode
                    final colorMode = ref.watch(
                      themeProvider.select((state) => state.colorMode),
                    );
                    return SettingsTile(
                      icon: Icons.brush_rounded,
                      iconColor: Theme.of(context).colorScheme.primary,
                      text: 'Appearance',
                      mode: _formatColorMode(colorMode),
                      onTap: () {
                        ThemeSwitch.show(context, ref);
                      },
                      showDivider: false,
                    );
                  },
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
                      showDivider: false,
                    ),
                  ],
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
                      showDivider: false,
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
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
