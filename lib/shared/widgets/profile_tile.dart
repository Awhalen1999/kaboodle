import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaboodle_app/providers/user_provider.dart';
import 'package:kaboodle_app/shared/utils/format_utils.dart';

class ProfileTile extends ConsumerWidget {
  const ProfileTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      child: userAsync.when(
        data: (user) {
          return ListTile(
            visualDensity: const VisualDensity(
              horizontal: -2,
              vertical: -4,
            ),
            title: SizedBox(
              height: 20, // Match skeleton height
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  user != null
                      ? FormatUtils.formatDisplayName(
                          user.displayName, user.email)
                      : 'Profile',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
            subtitle: const Text('View and edit'),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.2),
              ),
              child: Icon(
                Icons.person_rounded,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.pop(context);
              context.push('/profile');
            },
          );
        },
        loading: () {
          return const _ProfileTileSkeleton();
        },
        error: (error, stackTrace) {
          return ListTile(
            visualDensity: const VisualDensity(
              horizontal: -2,
              vertical: -4,
            ),
            title: SizedBox(
              height: 20,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Profile',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
            subtitle: const Text('View and edit'),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.2),
              ),
              child: Icon(
                Icons.person,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.pop(context);
              context.push('/profile');
            },
          );
        },
      ),
    );
  }
}

class _ProfileTileSkeleton extends StatelessWidget {
  const _ProfileTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: const VisualDensity(
        horizontal: -2,
        vertical: -4,
      ),
      title: SizedBox(
        height: 20, // Match text line height for fontSize 14
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            height: 14,
            width: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
      subtitle: const Text('View and edit'),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
        child: Icon(
          Icons.person,
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: null, // Disabled during loading
    );
  }
}
