import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kaboodle/services/data/packing_list_cache.dart';
import 'package:go_router/go_router.dart';
import 'package:swipe_refresh/swipe_refresh.dart';
import 'package:kaboodle/shared/widgets/packing_list_card.dart';

class MyPackingListsBody extends StatefulWidget {
  const MyPackingListsBody({super.key});

  @override
  State<MyPackingListsBody> createState() => _MyPackingListsBodyState();
}

class _MyPackingListsBodyState extends State<MyPackingListsBody> {
  final _refreshController = StreamController<SwipeRefreshState>.broadcast();

  @override
  void initState() {
    super.initState();
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
    return Consumer<PackingListCache>(
      builder: (context, cache, child) {
        Widget listContent;
        if (cache.isLoading) {
          listContent = const Center(child: CircularProgressIndicator());
        } else if (cache.error != null) {
          listContent = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 48, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text('Error loading lists',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(cache.error!,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => cache.refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (cache.lists.isEmpty) {
          listContent = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text('No lists saved',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Create your first packing list to get started',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center),
              ],
            ),
          );
        } else {
          listContent = SwipeRefresh.builder(
            stateStream: _refreshController.stream,
            onRefresh: _refresh,
            itemCount: cache.lists.length,
            itemBuilder: (context, index) {
              final listData = cache.lists[index];
              final listName = listData['title'] as String? ?? 'Untitled List';
              final description = listData['description'] as String? ?? '';
              final listColorValue =
                  listData['listColor'] as int? ?? Colors.grey.value;
              final listColor = Color(listColorValue);
              final selectedSections =
                  (listData['selectedSections'] as List?)?.cast<String>() ?? [];

              return PackingListCard(
                // todo: this will never really be empty, this is temporary
                listId: listData['id'] as String? ?? '',
                title: listName,
                description: description,
                color: listColor,
                selectedSections: selectedSections,
                onTap: () {
                  context.push('/list-viewer/${listData['id']}');
                },
              );
            },
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          );
        }

        return Stack(
          children: [
            listContent,
            Positioned(
              bottom: 36,
              right: 20,
              child: FloatingActionButton(
                onPressed: () => context.push('/create-packing-list'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.add, size: 32),
              ),
            ),
          ],
        );
      },
    );
  }
}
