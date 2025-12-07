import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:kaboodle_app/features/my_packing_lists/widgets/packing_list_tile.dart';
import 'package:kaboodle_app/models/packing_list.dart';
import 'package:kaboodle_app/providers/trips_provider.dart';
import 'package:kaboodle_app/providers/use_packing_items_provider.dart';
import 'package:kaboodle_app/services/trip/trip_service.dart';
import 'package:kaboodle_app/features/my_packing_lists/widgets/filter_chip_button.dart';
import 'package:kaboodle_app/shared/utils/color_tag_utils.dart';
import 'package:kaboodle_app/shared/widgets/custom_dialog.dart';
import 'package:toastification/toastification.dart';

class MyPackingListsBody extends ConsumerStatefulWidget {
  final String? initialTab;

  const MyPackingListsBody({super.key, this.initialTab});

  @override
  ConsumerState<MyPackingListsBody> createState() => _MyPackingListsBodyState();
}

class _MyPackingListsBodyState extends ConsumerState<MyPackingListsBody> {
  late String selectedFilter;
  final TripService _tripService = TripService();

  @override
  void initState() {
    super.initState();
    // Set initial filter based on the parameter, default to 'all'
    selectedFilter = widget.initialTab ?? 'all';
  }

  Future<void> _handleDeletePackingList(
      String packingListId, String packingListName) async {
    // Show confirmation dialog
    final confirmed = await CustomDialog.show<bool>(
      context: context,
      title: 'Delete Packing List',
      description: 'Are you sure you want to delete "$packingListName"?',
      actions: [
        CustomDialogAction(
          label: 'Cancel',
          isOutlined: true,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        CustomDialogAction(
          label: 'Delete',
          isDestructive: true,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );

    if (confirmed != true || !mounted) return;

    try {
      final success = await _tripService.deletePackingList(
        packingListId: packingListId,
        context: mounted ? context : null,
      );

      if (success && mounted) {
        // Refresh the list
        ref.read(packingListsProvider.notifier).refresh();

        // Show success message
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 3),
          title: Text('Deleted "$packingListName"'),
        );
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 3),
          title: Text('Failed to delete: ${e.toString()}'),
        );
      }
    }
  }

  Future<void> _handleResetProgress(PackingList packingList) async {
    if (!mounted) return;

    try {
      final result = await _tripService.reusePackingList(
        packingListId: packingList.id,
        context: context,
      );

      if (result == null || !mounted) {
        throw Exception('Failed to reset packing list');
      }

      final success = result['success'] as bool? ?? false;
      final itemsReset = result['itemsReset'] as int? ?? 0;

      if (!success) {
        throw Exception('API returned failure');
      }

      // Refresh both providers to fetch fresh data from backend
      // This ensures UI stays in sync with backend state
      await ref
          .read(usePackingItemsProvider(packingList.id).notifier)
          .refresh();
      ref.read(packingListsProvider.notifier).refresh();

      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 3),
          title: Text('Progress reset'),
          description: Text('$itemsReset items reset to unpacked'),
        );
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 3),
          title: Text('Failed to reset progress'),
          description: Text(e.toString()),
        );
      }
    }
  }

  Future<void> _handleSetNewTripDate(PackingList packingList) async {
    // Show date range picker with current dates as initial values
    final results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.range,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        selectedDayHighlightColor: Theme.of(context).colorScheme.primary,
        selectedRangeHighlightColor:
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        cancelButtonTextStyle: Theme.of(context).textTheme.bodyMedium,
        okButtonTextStyle: Theme.of(context).textTheme.bodyMedium,
        cancelButton: const Text('Cancel'),
        okButton: const Text('Save'),
      ),
      dialogSize: const Size(325, 400),
      value: [packingList.startDate, packingList.endDate],
      borderRadius: BorderRadius.circular(15),
    );

    if (results == null || results.isEmpty || results[0] == null) {
      return;
    }

    if (!mounted) return;

    try {
      // Update the packing list with new dates
      await _tripService.upsertPackingList(
        id: packingList.id,
        name: packingList.name,
        startDate: results[0]!,
        endDate: results.length > 1 && results[1] != null
            ? results[1]!
            : results[0]!,
        description: packingList.description,
        destination: packingList.destination,
        colorTag: packingList.colorTag,
        gender: packingList.gender,
        weather: packingList.weather,
        purpose: packingList.purpose,
        accommodations: packingList.accommodations,
        activities: packingList.activities,
        context: mounted ? context : null,
      );

      if (mounted) {
        // Refresh the list
        ref.read(packingListsProvider.notifier).refresh();

        // Show success message
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 3),
          title: const Text('Trip dates updated'),
        );
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 3),
          title: Text('Failed to update dates: ${e.toString()}'),
        );
      }
    }
  }

  List<PackingList> _filterPackingLists(List<PackingList> packingLists) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (selectedFilter) {
      case 'upcoming_trips':
        // Filter trips with start date in the future, sort by start date (earliest first)
        final upcoming = packingLists
            .where((list) => list.startDate.isAfter(today))
            .toList();
        upcoming.sort((a, b) => a.startDate.compareTo(b.startDate));
        return upcoming;

      case 'incomplete_lists':
        // Filter lists that haven't been completed (stepCompleted < 4)
        return packingLists.where((list) => list.stepCompleted < 4).toList();

      case 'current_trips':
        // Filter trips that are currently happening (today is between start and end date)
        return packingLists
            .where((list) =>
                !list.startDate.isAfter(today) && !list.endDate.isBefore(today))
            .toList();

      case 'past_trips':
        // Filter trips that have ended (end date before today), sort by end date (most recent first)
        final past =
            packingLists.where((list) => list.endDate.isBefore(today)).toList();
        past.sort((a, b) => b.endDate.compareTo(a.endDate));
        return past;

      case 'all':
      default:
        return packingLists;
    }
  }

  @override
  Widget build(BuildContext context) {
    final packingListsAsync = ref.watch(packingListsProvider);

    return packingListsAsync.when(
      data: (packingLists) {
        print(
            '✅ [MyPackingListsBody] Packing lists data received: ${packingLists.length} list(s)');
        if (packingLists.isEmpty) {
          print('📭 [MyPackingListsBody] Showing empty state');
          return _buildEmptyState(context);
        }

        // Apply filters
        final filteredLists = _filterPackingLists(packingLists);

        // Calculate filter counts
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final upcomingCount =
            packingLists.where((list) => list.startDate.isAfter(today)).length;
        final incompleteCount =
            packingLists.where((list) => list.stepCompleted < 4).length;
        final currentCount = packingLists
            .where((list) =>
                !list.startDate.isAfter(today) && !list.endDate.isBefore(today))
            .length;
        final pastCount =
            packingLists.where((list) => list.endDate.isBefore(today)).length;

        return Column(
          children: [
            _buildFilterRow(packingLists.length, upcomingCount, incompleteCount,
                currentCount, pastCount),
            Expanded(
              child: filteredLists.isEmpty
                  ? _buildEmptyFilterState(context)
                  : _buildPackingListsView(context, filteredLists),
            ),
          ],
        );
      },
      loading: () {
        print('⏳ [MyPackingListsBody] Packing lists loading...');
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
      error: (error, stackTrace) {
        print('❌ [MyPackingListsBody] Packing lists error: $error');
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load packing lists',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.read(packingListsProvider.notifier).refresh();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterRow(int totalTrips, int upcomingCount, int incompleteCount,
      int currentCount, int pastCount) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          const SizedBox(width: 16),
          FilterChipButton(
            label: 'All Trips',
            count: totalTrips,
            isSelected: selectedFilter == 'all',
            onTap: () {
              setState(() {
                selectedFilter = 'all';
              });
              print('🔍 Filter: All trips');
            },
          ),
          const SizedBox(width: 8),
          FilterChipButton(
            label: 'Upcoming Trips',
            count: upcomingCount,
            isSelected: selectedFilter == 'upcoming_trips',
            onTap: () {
              setState(() {
                selectedFilter = 'upcoming_trips';
              });
              print('🔍 Filter: Upcoming Trips');
            },
          ),
          const SizedBox(width: 8),
          FilterChipButton(
            label: 'Incomplete Lists',
            count: incompleteCount,
            isSelected: selectedFilter == 'incomplete_lists',
            onTap: () {
              setState(() {
                selectedFilter = 'incomplete_lists';
              });
              print('🔍 Filter: Incomplete Lists');
            },
          ),
          const SizedBox(width: 8),
          FilterChipButton(
            label: 'Current Trips',
            count: currentCount,
            isSelected: selectedFilter == 'current_trips',
            onTap: () {
              setState(() {
                selectedFilter = 'current_trips';
              });
              print('🔍 Filter: Current Trips');
            },
          ),
          const SizedBox(width: 8),
          FilterChipButton(
            label: 'Past Trips',
            count: pastCount,
            isSelected: selectedFilter == 'past_trips',
            onTap: () {
              setState(() {
                selectedFilter = 'past_trips';
              });
              print('🔍 Filter: Past Trips');
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.luggage_outlined,
              size: 100,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'Nothing here yet...',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start packing by creating\nyour first trip',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFilterState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'No trips found',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackingListsView(
      BuildContext context, List<PackingList> packingLists) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 64),
      itemCount: packingLists.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final packingList = packingLists[index];

        // Format dates
        final startDate = _formatDate(packingList.startDate);
        final endDate = _formatDate(packingList.endDate);

        // Get color from colorTag, fallback to index-based if not set
        final accentColor =
            ColorTagUtils.getColorFromTag(packingList.colorTag, index);

        return PackingListTile(
          tripName: packingList.name,
          description: packingList.description,
          startDate: startDate,
          endDate: endDate,
          destination: packingList.destination,
          accentColor: accentColor,
          stepCompleted: packingList.stepCompleted,
          isCompleted: packingList.isCompleted,
          onTap: () {
            if (packingList.stepCompleted < 4) {
              // List is incomplete - continue creation
              final step = packingList.stepCompleted;
              debugPrint('🚧 Continuing "${packingList.name}" from step $step');
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
          onEdit: () {
            // Navigate to create/edit page
            // If list is incomplete, go to the next step they need to complete (continuing creation)
            // If list is complete, go to step 4 (overview) where they can navigate to edit any step
            // stepCompleted represents the last completed step, so we go to that step (0-indexed)
            final step =
                packingList.stepCompleted < 4 ? packingList.stepCompleted : 3;
            context.push(
              '/create-packing-list?id=${packingList.id}&step=$step',
            );
          },
          onShare: packingList.stepCompleted >= 4
              ? () {
                  // TODO: Implement share functionality
                  debugPrint('📤 Share packing list: ${packingList.name}');
                }
              : null,
          onDelete: () =>
              _handleDeletePackingList(packingList.id, packingList.name),
          onSetNewTripDate: () => _handleSetNewTripDate(packingList),
          onResetProgress: packingList.stepCompleted >= 4
              ? () => _handleResetProgress(packingList)
              : null,
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
}
