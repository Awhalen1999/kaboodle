import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kaboodle_app/features/my_packing_lists/widgets/packing_list_tile.dart';
import 'package:kaboodle_app/models/packing_list.dart';
import 'package:kaboodle_app/providers/trips_provider.dart';
import 'package:kaboodle_app/services/trip/trip_service.dart';
import 'package:kaboodle_app/shared/widgets/filter_chip_button.dart';
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

  Future<void> _handleDeletePackingList(String packingListId, String packingListName) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Packing List'),
        content: Text('Are you sure you want to delete "$packingListName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFE4A49),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
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

        return Column(
          children: [
            _buildFilterRow(packingLists.length),
            Expanded(
              child: _buildPackingListsView(context, packingLists),
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
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load packing lists',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(color: Colors.grey[600]),
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

  Widget _buildFilterRow(int totalTrips) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChipButton(
            label: 'All trips',
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
            label: 'Upcoming',
            count: 0, // TODO: Calculate from trips with future dates
            isSelected: selectedFilter == 'upcoming',
            onTap: () {
              setState(() {
                selectedFilter = 'upcoming';
              });
              print('🔍 Filter: Upcoming');
            },
          ),
          const SizedBox(width: 8),
          FilterChipButton(
            label: 'Active',
            count: 0, // Placeholder
            isSelected: selectedFilter == 'active',
            onTap: () {
              setState(() {
                selectedFilter = 'active';
              });
              print('🔍 Filter: Active');
            },
          ),
          const SizedBox(width: 8),
          FilterChipButton(
            label: 'Past',
            count: 0, // Placeholder
            isSelected: selectedFilter == 'past',
            onTap: () {
              setState(() {
                selectedFilter = 'past';
              });
              print('🔍 Filter: Past');
            },
          ),
          const SizedBox(width: 8),
          FilterChipButton(
            label: 'Completed',
            count: 0, // Placeholder
            isSelected: selectedFilter == 'completed',
            onTap: () {
              setState(() {
                selectedFilter = 'completed';
              });
              print('🔍 Filter: Completed');
            },
          ),
          const SizedBox(width: 8),
          FilterChipButton(
            label: 'In Progress',
            count: 0, // Placeholder
            isSelected: selectedFilter == 'in_progress',
            onTap: () {
              setState(() {
                selectedFilter = 'in_progress';
              });
              print('🔍 Filter: In Progress');
            },
          ),
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
              color: Colors.grey[400],
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
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackingListsView(BuildContext context, List<PackingList> packingLists) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: packingLists.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final packingList = packingLists[index];

        // Format dates
        final startDate = _formatDate(packingList.startDate);
        final endDate = _formatDate(packingList.endDate);

        // Generate color based on index
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
        final accentColor = colors[index % colors.length];

        return PackingListTile(
          tripName: packingList.name,
          description: packingList.description,
          startDate: startDate,
          endDate: endDate,
          destination: packingList.destination,
          accentColor: accentColor,
          stepCompleted: packingList.stepCompleted,
          onTap: () {
            if (packingList.stepCompleted < 4) {
              // List is not complete - log for now
              debugPrint('🚧 User clicked continue creation for "${packingList.name}" (step ${packingList.stepCompleted}/4)');
              // TODO: Ask user if they want to continue creation
            } else {
              // List is complete - navigate to use page
              context.push(
                '/use-packing-list/${packingList.id}?name=${Uri.encodeComponent(packingList.name)}',
              );
            }
          },
          onDelete: () => _handleDeletePackingList(packingList.id, packingList.name),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }
}
