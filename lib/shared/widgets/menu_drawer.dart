import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaboodle_app/providers/trips_provider.dart';
import 'package:kaboodle_app/providers/user_provider.dart';

class MenuDrawer extends ConsumerWidget {
  const MenuDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsState = ref.watch(tripsProvider);
    final userState = ref.watch(userProvider);

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
                      fontWeight: FontWeight.bold,
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
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
                margin: const EdgeInsets.only(top: 8.0),
                padding: const EdgeInsets.only(top: 8.0),
                child: ListTile(
                  visualDensity: const VisualDensity(
                    horizontal: -2,
                    vertical: -4,
                  ),
                  title: Text(
                    userState.user?.displayName ?? userState.user?.email ?? 'Profile',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                  subtitle: const Text('View and edit'),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: userState.user?.photoUrl != null
                        ? Image.network(
                            userState.user!.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 24,
                                color: Colors.grey[600],
                              );
                            },
                          )
                        : Icon(
                            Icons.person,
                            size: 24,
                            color: Colors.grey[600],
                          ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/profile');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
