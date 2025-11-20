import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaboodle_app/providers/trips_provider.dart';
import 'package:kaboodle_app/shared/widgets/profile_tile.dart';
import 'package:kaboodle_app/shared/widgets/packing_list_drawer_tile.dart';

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

              // Packing lists section
              Expanded(
                child: packingListsAsync.when(
                  data: (packingLists) {
                    print(
                        '✅ [MenuDrawer] Packing lists data: ${packingLists.length} list(s)');

                    if (packingLists.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Nothing here yet',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }

                    // Generate colors for each packing list
                    final colors = [
                      Colors.blue,
                      Colors.purple,
                      Colors.green,
                      Colors.orange,
                      Colors.red,
                      Colors.teal,
                      Colors.indigo,
                      Colors.pink,
                    ];

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      itemCount: packingLists.length,
                      itemBuilder: (context, index) {
                        final packingList = packingLists[index];
                        final accentColor = colors[index % colors.length];

                        return PackingListDrawerTile(
                          tripName: packingList.name,
                          description: packingList.description,
                          accentColor: accentColor,
                          isSelected:
                              false, // TODO: Track selected packing list
                          stepCompleted: packingList.stepCompleted,
                          onTap: () {
                            Navigator.pop(context);
                            if (packingList.stepCompleted < 4) {
                              // List is not complete - log for now
                              debugPrint(
                                  '🚧 User clicked continue creation for "${packingList.name}" (step ${packingList.stepCompleted}/4)');
                              // TODO: Ask user if they want to continue creation
                            } else {
                              // List is complete - navigate to use page
                              context.push(
                                '/use-packing-list/${packingList.id}?name=${Uri.encodeComponent(packingList.name)}',
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                  loading: () {
                    print('⏳ [MenuDrawer] Trips loading...');
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                  error: (error, stackTrace) {
                    print('❌ [MenuDrawer] Trips error: $error');
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Error loading trips',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
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
