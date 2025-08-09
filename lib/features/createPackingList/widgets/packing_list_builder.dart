import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kaboodle/shared/widgets/custom_checkbox_list_tile.dart';
import 'package:kaboodle/features/createPackingList/widgets/items_builder.dart';
import 'package:kaboodle/features/createPackingList/provider/create_packing_list_provider.dart';
import 'package:kaboodle/features/createPackingList/provider/custom_items_provider.dart';
import 'edit_items_bottom_sheet.dart';
import 'add_custom_item_bottom_sheet.dart';
import 'package:kaboodle/core/constants/app_icons.dart';

class PackingListBuilder extends StatelessWidget {
  final String? gender;
  final String? tripPurpose;
  final String? weatherCondition;
  final String? accommodation;
  final List<String> selectedSections;
  final double tripLength;
  final Map<String, PackingListItem>? existingItems;
  final ValueChanged<PackingListItem> onItemAdded;
  final ValueChanged<String> onItemRemoved;
  final ValueChanged<PackingListItem> onItemUpdated;
  final void Function(String section, String itemName, int quantity)
      onCustomItemAdded;
  final void Function(String itemId, bool? value) onCustomItemToggled;
  final ValueChanged<CustomPackingItem> onCustomItemUpdated;

  const PackingListBuilder({
    super.key,
    this.gender,
    this.tripPurpose,
    this.weatherCondition,
    this.accommodation,
    required this.selectedSections,
    required this.tripLength,
    this.existingItems,
    required this.onItemAdded,
    required this.onItemRemoved,
    required this.onItemUpdated,
    required this.onCustomItemAdded,
    required this.onCustomItemToggled,
    required this.onCustomItemUpdated,
  });

  // Helper function that calculates the final quantity based on tripLength.
  // For fixed items, we return the baseQuantity.
  // For others, we multiply the baseQuantity by the trip length.
  int getCalculatedQuantity(PackingItem item, double tripLength) {
    const fixedItems = {
      'medication',
      'wallet',
      'watch',
      'map',
      'campas',
      'portable_charger',
      'glasses',
      'earbuds',
      'toothbrush',
      'toothpaste',
      'razor',
      'electric_shaver',
      'hairbrush',
      'nail_clippers',
      'shampoo',
      'conditioner',
      'shaving_cream',
      'mouthwash',
      'tweezers',
      'contacts',
      'contact_solution',
      'deodorant',
      'cologne',
      'laptop',
      'laptop_case',
      'laptop_charger',
      'tablet',
      'tablet_charger',
      'tablet_case',
      'phone',
      'phone_charger',
      'headphones',
      'headphones_charger',
      'keyboard',
      'mouse',
      'camera',
      'camera_charger',
    };

    if (fixedItems.contains(item.id)) {
      return item.baseQuantity;
    }
    return (item.baseQuantity * tripLength).round();
  }

  // Convert PackingItem to PackingListItem
  PackingListItem createPackingListItem(
      PackingItem item, double tripLength, String sectionKey) {
    final calculatedQuantity = getCalculatedQuantity(item, tripLength);

    return PackingListItem(
      id: item.id,
      label: item.label,
      section: sectionKey,
      baseQuantity: item.baseQuantity,
      calculatedQuantity: calculatedQuantity,
      isChecked: false, // Items are not packed yet when added to list
      iconName: item.iconName,
    );
  }

  // Opens the modal widget for editing quantity and note.
  void _openCustomizationSheet(
      BuildContext context, PackingListItem packingItem) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return EditItemsModal(
          label: packingItem.label,
          initialQuantity: packingItem.finalQuantity,
          initialNote: packingItem.note ?? '',
          onSave: (newQuantity, newNote) {
            // Update the item with new quantity and note
            final updatedItem = packingItem.copyWith(
              customQuantity:
                  newQuantity, // Will be null if quantity wasn't changed
              note: newNote.isEmpty ? null : newNote,
            );
            onItemUpdated(updatedItem);
          },
        );
      },
    );
  }

  // Opens the modal widget for adding custom items
  void _openAddCustomItemSheet(BuildContext context, String sectionKey) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return AddCustomItemModal(
          sectionTitle: _formatSectionTitle(sectionKey),
          onAdd: (itemName, quantity) {
            onCustomItemAdded(sectionKey, itemName, quantity);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use props if provided, otherwise fall back to provider
    final provider = context.watch<CreatePackingListProvider>();
    final customItemsProvider = context.watch<CustomItemsProvider>();

    final String currentGender = gender ?? provider.gender ?? '';
    final String currentTripPurpose = tripPurpose ?? provider.tripPurpose ?? '';
    final String currentWeather =
        weatherCondition ?? provider.weatherCondition ?? '';
    final String currentAccommodation =
        accommodation ?? provider.accommodation ?? '';
    final List<String> currentSelectedSections = selectedSections.isNotEmpty
        ? selectedSections
        : provider.itemsActivities;
    final double currentTripLength =
        tripLength > 0 ? tripLength : provider.tripLength;

    // Use existing items if provided, otherwise use provider items
    final Map<String, PackingListItem> currentItems =
        existingItems ?? provider.selectedItems;

    List<Widget> listWidgets = [];

    for (var sectionKey in currentSelectedSections) {
      final List<PackingItem>? sectionItems = packingItemsBySection[sectionKey];
      if (sectionItems == null || sectionItems.isEmpty) continue;

      final filteredItems = sectionItems.where((item) {
        return itemMatchesCriteria(
          item,
          gender: currentGender,
          tripPurpose: currentTripPurpose,
          weather: currentWeather,
          accommodation: currentAccommodation,
        );
      }).toList();

      // Get custom items for this section
      final customItems =
          customItemsProvider.getCustomItemsForSection(sectionKey);

      // Show section if it has filtered items OR custom items OR existing items
      if (filteredItems.isEmpty &&
          customItems.isEmpty &&
          !currentItems.values.any((item) => item.section == sectionKey))
        continue;

      listWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _formatSectionTitle(sectionKey),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              IconButton(
                onPressed: () => _openAddCustomItemSheet(context, sectionKey),
                icon: Icon(
                  Icons.add_circle_outline_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      );

      // First, show all existing items for this section (even if they don't match current criteria)
      final existingItemsInSection = currentItems.values
          .where((item) => item.section == sectionKey)
          .toList();

      for (var existingItem in existingItemsInSection) {
        listWidgets.add(
          CustomCheckboxListTile(
            iconData: existingItem.icon,
            text: existingItem.label,
            quantity: existingItem.finalQuantity,
            note: existingItem.note ?? '',
            value: true, // If it's in the list, it's selected
            onChanged: (bool? newValue) {
              if (newValue == false) {
                // User unselected this item - remove it from the list
                onItemRemoved(existingItem.id);
              }
            },
            onEdit: () => _openCustomizationSheet(context, existingItem),
          ),
        );
      }

      // Then show filtered items that aren't already in the list
      for (var item in filteredItems) {
        // Check if this item is already in the existing items
        if (currentItems.containsKey(item.id)) continue;

        // Item is not selected - show it as unselected
        final calculatedQuantity =
            getCalculatedQuantity(item, currentTripLength);

        listWidgets.add(
          CustomCheckboxListTile(
            iconData: getIconByName(item.iconName),
            text: item.label,
            quantity: calculatedQuantity,
            note: '',
            value: false, // Not in the list yet
            onChanged: (bool? newValue) {
              if (newValue == true) {
                // User selected this item - add it to the list
                final packingItem =
                    createPackingListItem(item, currentTripLength, sectionKey);
                onItemAdded(packingItem);
              }
            },
            onEdit: () {
              // Create the item first, then open edit modal
              final packingItem =
                  createPackingListItem(item, currentTripLength, sectionKey);
              onItemAdded(packingItem);
              _openCustomizationSheet(context, packingItem);
            },
          ),
        );
      }

      // Add custom items for this section
      for (var customItem in customItems) {
        listWidgets.add(
          CustomCheckboxListTile(
            iconData: customItem.icon,
            text: customItem.label,
            quantity: customItem.quantity,
            note: customItem.note ?? '',
            value: true, // If it's in the custom items list, it's selected
            onChanged: (bool? newValue) {
              if (newValue == false) {
                // User unselected this custom item - remove it
                onCustomItemToggled(customItem.id, false);
              }
            },
            onEdit: () {
              // Open edit modal for custom item
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return EditItemsModal(
                    label: customItem.label,
                    initialQuantity: customItem.quantity,
                    initialNote: customItem.note ?? '',
                    onSave: (newQuantity, newNote) {
                      // Update the custom item with new quantity and note
                      final updatedItem = customItem.copyWith(
                        quantity: newQuantity ?? customItem.quantity,
                        note: newNote.isEmpty ? null : newNote,
                      );
                      onCustomItemUpdated(updatedItem);
                    },
                  );
                },
              );
            },
          ),
        );
      }
    }

    return Column(
      children: listWidgets,
    );
  }

  String _formatSectionTitle(String key) {
    switch (key) {
      case 'commonItems':
        return 'Common Items';
      case 'clothes':
        return 'Clothes';
      case 'toiletries':
        return 'Toiletries';
      case 'electronics':
        return 'Electronics';
      case 'beach':
        return 'Beach';
      case 'gym':
        return 'Gym';
      case 'formal':
        return 'Formal';
      case 'photography':
        return 'Photography';
      default:
        return key;
    }
  }
}
