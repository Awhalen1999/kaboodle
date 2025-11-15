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
    final packingListsAsync = ref.watch(packingListsProvider);
    print('👀 [MenuDrawer] Watching packing lists provider');

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

              // Packing lists count section - simple text display
              // todo: create packing list menu tile widget + empty state
              Expanded(
                child: Center(
                  child: packingListsAsync.when(
                    data: (packingLists) {
                      print(
                          '✅ [MenuDrawer] Packing lists data: ${packingLists.length} list(s)');
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          packingLists.isEmpty
                              ? 'Nothing here yet'
                              : '${packingLists.length} packing list${packingLists.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      );
                    },
                    loading: () {
                      print('⏳ [MenuDrawer] Trips loading...');
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      );
                    },
                    error: (error, stackTrace) {
                      print('❌ [MenuDrawer] Trips error: $error');
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Error loading trips',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      );
                    },
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
