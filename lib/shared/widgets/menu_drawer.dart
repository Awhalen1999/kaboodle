import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaboodle_app/providers/trips_provider.dart';
import 'package:kaboodle_app/shared/utils/color_tag_utils.dart';
import 'package:kaboodle_app/shared/widgets/profile_tile.dart';
import 'package:kaboodle_app/shared/widgets/packing_list_drawer_tile.dart';

class MenuDrawer extends ConsumerWidget {
  const MenuDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packingListsAsync = ref.watch(packingListsProvider);

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
                  context.push('/my-packing-lists?tab=upcoming_trips');
                },
              ),
              const Divider(
                color: Colors.grey,
              ),

              // Packing lists section
              Expanded(
                child: packingListsAsync.when(
                  data: (packingLists) {
                    if (packingLists.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Nothing here yet',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      itemCount: packingLists.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final packingList = packingLists[index];
                        final accentColor = ColorTagUtils.getColorFromTag(
                            packingList.colorTag, index);

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
                              // List is incomplete - continue creation
                              final step = packingList.stepCompleted;
                              context.push(
                                '/create-packing-list?id=${packingList.id}&step=$step',
                              );
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
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                  error: (error, stackTrace) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Error loading trips',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
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
