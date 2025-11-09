import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kaboodle_app/providers/user_provider.dart';

class ProfileBody extends ConsumerWidget {
  const ProfileBody({super.key});

  String _formatMemberSince(DateTime? creationTime) {
    if (creationTime == null) return 'Unknown';
    return DateFormat('MMMM yyyy').format(creationTime);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);

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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            const SizedBox(height: 24),

            // Greeting with name
            Text(
              'Hey, ${user.displayName ?? user.email}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Peace emoji
            const Text(
              '✌️',
              style: TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 16),

            // Tier badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey[400]!,
                  width: 1,
                ),
              ),
              child: Text(
                user.tier.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Member since
            Text(
              'Member since ${_formatMemberSince(user.createdAt)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
