import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kaboodle_app/models/user.dart';
import 'package:kaboodle_app/shared/utils/app_toast.dart';
import 'package:kaboodle_app/providers/user_provider.dart';
import 'package:kaboodle_app/providers/subscription_provider.dart';
import 'package:kaboodle_app/providers/trips_provider.dart';
import 'package:kaboodle_app/providers/theme_provider.dart';
import 'package:kaboodle_app/shared/constants/theme_constants.dart';
import 'package:kaboodle_app/services/auth/auth_service.dart';
import 'package:kaboodle_app/services/subscription/subscription_service.dart';
import 'package:kaboodle_app/shared/utils/country_utils.dart';
import 'package:kaboodle_app/shared/utils/format_utils.dart';
import 'package:lottie/lottie.dart';
import 'package:kaboodle_app/features/profile/widgets/settings_tile.dart';
import 'package:kaboodle_app/features/profile/widgets/theme_switch.dart';
import 'package:kaboodle_app/features/profile/widgets/delete_account_dialog.dart';
import 'package:kaboodle_app/services/user/user_service.dart';

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
          // todo: maybe show that we are logging out maybe handle error here
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return _buildProfileContent(context, ref, user);
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
      error: (error, stackTrace) {
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            // Sleeping cat animation
            SizedBox(
              height: 220,
              child: Lottie.asset(
                'assets/lottie/sleeping_cat.json',
                fit: BoxFit.contain,
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
                      icon: Icons.star_rounded,
                      iconColor: Colors.purpleAccent,
                      text: 'Rate App',
                      onTap: () {
                        AppToast.info(context, 'Coming soon');
                      },
                      isGrouped: true,
                    ),
                    SettingsTile(
                      icon: Icons.info_rounded,
                      iconColor: Colors.blueAccent,
                      text: 'Help & Support',
                      onTap: () async {
                        final email = 'awhalendev@kaboodle.now';
                        final subject = 'Kaboodle App - Help & Support';
                        final uri = Uri(
                          scheme: 'mailto',
                          path: email,
                          query: 'subject=${Uri.encodeComponent(subject)}',
                        );
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          if (context.mounted) {
                            AppToast.info(context,
                                'Unable to open email. Contact $email');
                          }
                        }
                      },
                      isGrouped: true,
                      showDivider: false,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SubscriptionTile(),
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
                      onTap: () async {
                        final uri = Uri.parse(
                            'https://legal.kaboodle.now/terms-of-service');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        } else {
                          if (context.mounted) {
                            AppToast.error(context, 'Unable to open link');
                          }
                        }
                      },
                      isGrouped: true,
                    ),
                    SettingsTile(
                      iconColor: Theme.of(context).colorScheme.primary,
                      text: 'Privacy Policy',
                      onTap: () async {
                        final uri = Uri.parse(
                            'https://legal.kaboodle.now/privacy-policy');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        } else {
                          if (context.mounted) {
                            AppToast.error(context, 'Unable to open link');
                          }
                        }
                      },
                      isGrouped: true,
                    ),
                    SettingsTile(
                      iconColor: Theme.of(context).colorScheme.primary,
                      text: 'Data Deletion',
                      onTap: () async {
                        final uri = Uri.parse(
                            'https://legal.kaboodle.now/data-deletion');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        } else {
                          if (context.mounted) {
                            AppToast.error(context, 'Unable to open link');
                          }
                        }
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
                const SizedBox(height: 16),
                SettingsTile(
                  icon: Icons.delete_forever_rounded,
                  iconColor: Colors.red,
                  text: 'Delete Account',
                  onTap: () => _showDeleteAccountDialog(context, ref),
                  showDivider: false,
                  showChevron: false,
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Version text
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Center(
                    child: Text(
                      'v ${snapshot.data!.version}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Subscription tile that displays status from subscriptionProvider
class _SubscriptionTile extends ConsumerWidget {
  const _SubscriptionTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(subscriptionProvider);
    final packingListsAsync = ref.watch(packingListsProvider);
    final subscriptionService = SubscriptionService();

    return subscriptionAsync.when(
      data: (status) {
        final isPro = status?.isPro ?? false;
        final listCount = packingListsAsync.valueOrNull?.length ?? 0;
        const maxFreeLists = 2;

        return SettingsTile(
          icon: Icons.credit_card,
          iconColor: isPro ? Colors.amber : Colors.grey,
          text: 'Subscription',
          mode: isPro ? 'Pro' : 'Free ($listCount/$maxFreeLists lists)',
          onTap: () {
            if (isPro) {
              context.push('/manage-subscription');
            } else {
              subscriptionService.showPaywall(context);
            }
          },
          showDivider: false,
        );
      },
      loading: () => SettingsTile(
        icon: Icons.credit_card,
        iconColor: Theme.of(context).colorScheme.outlineVariant,
        text: 'Subscription',
        mode: '',
        onTap: () {},
        showDivider: false,
      ),
      error: (error, stackTrace) => SettingsTile(
        icon: Icons.credit_card,
        iconColor: Colors.grey,
        text: 'Subscription',
        mode: 'Error',
        onTap: () {
          ref.read(subscriptionProvider.notifier).refresh();
        },
        showDivider: false,
      ),
    );
  }
}

/// Shows delete account confirmation dialog
Future<void> _showDeleteAccountDialog(
    BuildContext context, WidgetRef ref) async {
  await DeleteAccountDialog.show(
    context,
    () => _handleDeleteAccount(context, ref),
  );
}

/// Handles the account deletion process
Future<void> _handleDeleteAccount(BuildContext context, WidgetRef ref) async {
  final userService = UserService();

  // Show loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  try {
    final success = await userService.deleteAccount(context: context);

    // Close loading dialog
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    if (success) {
      // Sign out and navigate to auth
      if (context.mounted) {
        AppToast.success(context, 'Account deleted successfully');
        await AuthService().signout(context: context, ref: ref);
      }
    } else {
      if (context.mounted) {
        AppToast.error(context, 'Failed to delete account');
      }
    }
  } catch (e) {
    // Close loading dialog
    if (context.mounted) {
      Navigator.of(context).pop();
      AppToast.error(context, 'An error occurred');
    }
  }
}
