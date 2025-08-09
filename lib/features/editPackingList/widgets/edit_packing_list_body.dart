import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kaboodle/services/data/packing_list_cache.dart';
import 'package:kaboodle/shared/widgets/trip_details_overview.dart';
import 'package:kaboodle/shared/widgets/trip_requirements_overview.dart';
import 'package:kaboodle/shared/widgets/trip_items_overview.dart';
import 'package:kaboodle/core/constants/app_icons.dart';
import 'package:kaboodle/core/utils/date_formatter.dart';
import 'package:kaboodle/features/editPackingList/widgets/edit_step_one_body.dart';
import 'package:kaboodle/features/editPackingList/widgets/edit_step_two_body.dart';
import 'package:kaboodle/features/editPackingList/widgets/edit_step_three_body.dart';

class EditPackingListBody extends StatefulWidget {
  final String listId;
  const EditPackingListBody({super.key, required this.listId});

  @override
  State<EditPackingListBody> createState() => _EditPackingListBodyState();
}

class _EditPackingListBodyState extends State<EditPackingListBody> {
  @override
  void initState() {
    super.initState();
    // Ensure cache is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cache = context.read<PackingListCache>();
      if (!cache.hasLoaded) {
        cache.getLists();
      }
    });
  }

  void _navigateToEditStep(int step) {
    Widget editPage;
    switch (step) {
      case 1:
        editPage = Scaffold(
          appBar: AppBar(
            title: const Text('Edit Trip Details'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(child: EditStepOneBody(listId: widget.listId)),
        );
        break;
      case 2:
        editPage = Scaffold(
          appBar: AppBar(
            title: const Text('Edit Trip Requirements'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(child: EditStepTwoBody(listId: widget.listId)),
        );
        break;
      case 3:
        editPage = Scaffold(
          appBar: AppBar(
            title: const Text('Edit Packing List'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(child: EditStepThreeBody(listId: widget.listId)),
        );
        break;
      default:
        return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => editPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PackingListCache>(
      builder: (context, cache, child) {
        if (cache.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cache.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 64, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text('Error loading packing list',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  cache.error!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final listData = cache.getListById(widget.listId);
        if (listData == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text('Packing list not found',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'The packing list you\'re looking for doesn\'t exist or has been deleted.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Extract data from the list
        final title = listData['title'] ?? 'Untitled';
        final description = listData['description'] ?? 'No description';
        final date = DateFormatter.formatDate(listData['travelDate']);
        final purpose = listData['tripPurpose'] ?? 'NA';
        final weather = listData['weatherCondition'] ?? 'NA';
        final tripLength =
            DateFormatter.formatTripLength(listData['tripLength'] ?? 0.0);
        final accommodation = listData['accommodation'] ?? 'NA';
        final itemsActivities =
            List<String>.from(listData['selectedSections'] ?? []);

        // Extract items from the list data
        final items = <TripItemOverviewData>[];
        final itemsList = listData['items'] as List? ?? [];
        for (final itemData in itemsList) {
          final item = itemData as Map<String, dynamic>;
          final iconName = item['iconName'] as String? ?? 'checkroom_rounded';
          items.add(TripItemOverviewData(
            label: item['label'] as String? ?? 'Unknown Item',
            quantity: item['customQuantity'] as int? ??
                item['calculatedQuantity'] as int? ??
                item['baseQuantity'] as int? ??
                1,
            note: item['note'] as String?,
            icon: getIconByName(iconName),
          ));
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      )),
              const SizedBox(height: 8),
              const Text(
                'Edit your packing list details. You can add, remove, and edit items.',
              ),
              const SizedBox(height: 16),
              TripDetailsOverview(
                title: title,
                description: description,
                date: date,
                onEdit: () => _navigateToEditStep(1),
              ),
              TripRequirementsOverview(
                purpose: purpose,
                weather: weather,
                tripLength: tripLength,
                accommodation: accommodation,
                itemsActivities: itemsActivities,
                onEdit: () => _navigateToEditStep(2),
              ),
              TripItemsOverview(
                items: items,
                onEdit: () => _navigateToEditStep(3),
              ),
            ],
          ),
        );
      },
    );
  }
}
