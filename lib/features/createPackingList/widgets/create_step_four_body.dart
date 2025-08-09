import 'package:flutter/material.dart';
import 'package:kaboodle/core/utils/date_formatter.dart';
import 'package:kaboodle/features/createPackingList/provider/create_packing_list_provider.dart';
import 'package:kaboodle/features/createPackingList/provider/custom_items_provider.dart';
import 'package:kaboodle/shared/widgets/trip_details_overview.dart';
import 'package:kaboodle/shared/widgets/trip_items_overview.dart';
import 'package:kaboodle/shared/widgets/trip_requirements_overview.dart';
import 'package:provider/provider.dart';

class MainStepFourBody extends StatelessWidget {
  final VoidCallback? onEditTripDetails;
  final VoidCallback? onEditTripRequirements;
  final VoidCallback? onEditPackingList;

  const MainStepFourBody({
    super.key,
    this.onEditTripDetails,
    this.onEditTripRequirements,
    this.onEditPackingList,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreatePackingListProvider>();
    final customItemsProvider = context.watch<CustomItemsProvider>();

    // Trip Details
    final title = provider.title.isNotEmpty ? provider.title : 'NA';
    final description =
        provider.description.isNotEmpty ? provider.description : 'NA';
    final date = provider.travelDate != null
        ? DateFormatter.formatDateToString(provider.travelDate!)
        : 'NA';

    // Trip Requirements
    final weather = provider.weatherCondition ?? 'NA';
    final purpose = provider.tripPurpose ?? 'NA';
    final tripLength = DateFormatter.formatTripLength(provider.tripLength);
    final accommodation = provider.accommodation ?? 'NA';
    final itemsActivities = provider.itemsActivities;

    // Trip Items
    final regularItems =
        provider.selectedItemsList; // All items in the list are selected
    final customItems =
        customItemsProvider.customItemsList; // All custom items are selected
    final allItems = [
      ...regularItems.map((item) => TripItemOverviewData(
            label: item.label,
            quantity: item.finalQuantity,
            note: item.note,
            icon: item.icon,
          )),
      ...customItems.map((item) => TripItemOverviewData(
            label: item.label,
            quantity: item.quantity,
            note: item.note,
            icon: item.icon,
          )),
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Overview",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            "Review your trip details and packing list before saving.",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          TripDetailsOverview(
            title: title,
            description: description,
            date: date,
            onEdit: onEditTripDetails,
          ),
          TripRequirementsOverview(
            purpose: purpose,
            weather: weather,
            tripLength: tripLength,
            accommodation: accommodation,
            itemsActivities: itemsActivities,
            onEdit: onEditTripRequirements,
          ),
          TripItemsOverview(
            items: allItems,
            onEdit: onEditPackingList,
          ),
        ],
      ),
    );
  }
}
