import 'dart:async';
import 'package:kaboodle/shared/widgets/custom_chip.dart';
import 'package:kaboodle/shared/widgets/packing_list_tile.dart';
import 'package:kaboodle/services/data/packing_list_cache.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:swipe_refresh/swipe_refresh.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({
    super.key,
  });

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  final _refreshController = StreamController<SwipeRefreshState>.broadcast();

  @override
  void initState() {
    super.initState();
    // Load lists when drawer is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PackingListCache>().getLists();
    });
  }

  @override
  void dispose() {
    _refreshController.close();
    super.dispose();
  }

  Future<void> _refresh() async {
    await context.read<PackingListCache>().refresh();
    _refreshController.sink.add(SwipeRefreshState.hidden);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
                trailing: Consumer<PackingListCache>(
                  builder: (context, cache, child) {
                    return CustomChip(label: cache.count.toString());
                  },
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/my-packing-lists');
                },
              ),
              ListTile(
                title: const Text('Upcoming trips'),
                leading: const Icon(Icons.double_arrow_rounded),
                trailing: Consumer<PackingListCache>(
                  builder: (context, cache, child) {
                    // Calculate upcoming trips count
                    final now = DateTime.now();
                    final upcomingTripsCount = cache.lists.where((list) {
                      final dateStr = list['travelDate'] as String?;
                      if (dateStr == null) return false;
                      final date = DateTime.tryParse(dateStr);
                      return date != null &&
                          date.isAfter(now.subtract(const Duration(days: 1)));
                    }).length;
                    return CustomChip(label: upcomingTripsCount.toString());
                  },
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/upcoming-trips');
                },
              ),
              const Divider(
                color: Colors.grey,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    const Text(
                      "Lists",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Consumer<PackingListCache>(
                      builder: (context, cache, child) {
                        return Text(
                          "(${cache.count})",
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add_rounded),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      style: const ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/create-packing-list');
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<PackingListCache>(
                  builder: (context, cache, child) {
                    if (cache.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (cache.error != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading lists',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              cache.error!,
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => cache.refresh(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (cache.lists.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 48,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No lists saved',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create your first packing list to get started',
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                context.push('/create-packing-list');
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Create List'),
                            ),
                          ],
                        ),
                      );
                    }
                    return SwipeRefresh.builder(
                      stateStream: _refreshController.stream,
                      onRefresh: _refresh,
                      itemCount: cache.lists.length,
                      itemBuilder: (context, index) {
                        final listData = cache.lists[index];
                        final listName =
                            listData['title'] as String? ?? 'Untitled List';
                        final listColorValue =
                            listData['listColor'] as int? ?? Colors.grey.value;
                        final listColor = Color(listColorValue);
                        final items = listData['items'] as List? ?? [];
                        final itemCount = items.length;
                        return PackingListTile(
                          listName: listName,
                          listColor: listColor,
                          itemCount: itemCount,
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/list-viewer/${listData['id']}');
                          },
                        );
                      },
                      padding: const EdgeInsets.only(bottom: 16),
                    );
                  },
                ),
              ),
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
                    user?.email ?? 'Profile',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                  subtitle: const Text('View and edit'),
                  leading: CircleAvatar(
                    child: const Icon(Icons.person),
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
