import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaboodle_app/providers/trips_provider.dart';
import 'package:kaboodle_app/shared/widgets/profile_tile.dart';

class MenuDrawer extends ConsumerWidget {
  const MenuDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsState = ref.watch(tripsProvider);

    // Query pattern: Load trips data on demand if not already loaded
    if (!tripsState.hasLoaded && !tripsState.isLoading) {
      print('🎯 [MenuDrawer] Triggering trips load');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(tripsProvider.notifier).loadTrips();
      });
    }

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('My packing lists'),
                leading: const Icon(Icons.format_list_bulleted),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/my-packing-lists');
                },
              ),
              ListTile(
                title: const Text('Upcoming trips'),
                leading: const Icon(Icons.double_arrow_rounded),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/my-packing-lists?tab=upcoming');
                },
              ),
              const Divider(
                color: Colors.grey,
              ),

              // Trips count section - simple text display
              // todo: create trip menu tile widget + empty state
              Expanded(
                child: Center(
                  child: tripsState.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        )
                      : tripsState.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Nothing here yet',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                '${tripsState.trips.length} trip${tripsState.trips.length == 1 ? '' : 's'}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                ),
              ),

              // Profile section - always pinned at bottom
              const Divider(
                color: Colors.grey,
              ),
              const ProfileTile(),
            ],
          ),
        ),
      ),
    );
  }
}
