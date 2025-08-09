import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kaboodle/services/data/packing_list_cache.dart';
import 'package:go_router/go_router.dart';
import 'package:swipe_refresh/swipe_refresh.dart';
import 'package:kaboodle/shared/widgets/packing_list_card.dart';

class UpcomingTripsBody extends StatefulWidget {
  const UpcomingTripsBody({super.key});

  @override
  State<UpcomingTripsBody> createState() => _UpcomingTripsBodyState();
}

class _UpcomingTripsBodyState extends State<UpcomingTripsBody> {
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
                Text('Error loading trips',
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
        } else {
          // Filter for trips with a valid travelDate
          final now = DateTime.now();
          final tripsWithDate = cache.lists.where((list) {
            final dateStr = list['travelDate'] as String?;
            if (dateStr == null) return false;
            final date = DateTime.tryParse(dateStr);
            return date != null &&
                date.isAfter(now.subtract(const Duration(days: 1)));
          }).toList();
          // Sort by date ascending
          tripsWithDate.sort((a, b) {
            final aDate =
                DateTime.tryParse(a['travelDate'] ?? '') ?? DateTime(2100);
            final bDate =
                DateTime.tryParse(b['travelDate'] ?? '') ?? DateTime(2100);
            return aDate.compareTo(bDate);
          });

          if (tripsWithDate.isEmpty) {
            listContent = Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('No upcoming trips',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Create a trip with a date to see it here.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center),
                ],
              ),
            );
          } else {
            listContent = SwipeRefresh.builder(
              stateStream: _refreshController.stream,
              onRefresh: _refresh,
              itemCount: tripsWithDate.length,
              itemBuilder: (context, index) {
                final listData = tripsWithDate[index];
                final listName =
                    listData['title'] as String? ?? 'Untitled Trip';
                final description = listData['description'] as String? ?? '';
                final listColorValue =
                    listData['listColor'] as int? ?? Colors.grey.value;
                final listColor = Color(listColorValue);
                final selectedSections =
                    (listData['selectedSections'] as List?)?.cast<String>() ??
                        [];
                final dateStr = listData['travelDate'] as String?;
                final tripDate =
                    dateStr != null ? DateTime.tryParse(dateStr) : null;
                final daysUntil =
                    tripDate != null ? tripDate.difference(now).inDays : null;

                return PackingListCard(
                  // todo: this will never really be empty, this is temporary
                  listId: listData['id'] as String? ?? '',
                  title: listName,
                  description: description,
                  color: listColor,
                  selectedSections: selectedSections,
                  daysUntil:
                      (daysUntil != null && daysUntil >= 0) ? daysUntil : null,
                  onTap: () {
                    context.push('/list-viewer/${listData['id']}');
                  },
                );
              },
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            );
          }
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
