import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaboodle_app/providers/trips_provider.dart';
import 'package:kaboodle_app/shared/widgets/filter_chip_button.dart';

class MyPackingListsBody extends ConsumerStatefulWidget {
  final String? initialTab;

  const MyPackingListsBody({super.key, this.initialTab});

  @override
  ConsumerState<MyPackingListsBody> createState() => _MyPackingListsBodyState();
}

class _MyPackingListsBodyState extends ConsumerState<MyPackingListsBody> {
  late String selectedFilter;

  @override
  void initState() {
    super.initState();
    // Set initial filter based on the parameter, default to 'all'
    selectedFilter = widget.initialTab ?? 'all';
  }

  @override
  Widget build(BuildContext context) {
    final tripsState = ref.watch(tripsProvider);

    if (tripsState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (tripsState.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        _buildFilterRow(tripsState.trips.length),
        Expanded(
          child: _buildTripsView(context, tripsState.trips.length),
        ),
      ],
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

  Widget _buildTripsView(BuildContext context, int tripCount) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You have $tripCount trip${tripCount == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              '(List tiles coming soon)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
