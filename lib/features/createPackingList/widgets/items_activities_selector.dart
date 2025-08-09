import 'package:kaboodle/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:kaboodle/shared/widgets/custom_svg_checkbox_list_tile.dart';

class ItemsActivitiesSelector extends StatelessWidget {
  final List<String> selectedItems;
  final ValueChanged<String> onItemToggled;

  const ItemsActivitiesSelector({
    super.key,
    required this.selectedItems,
    required this.onItemToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Items/Activities',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: activityDetails.entries.map((entry) {
                final String itemId = entry.key;
                final Map<String, dynamic> itemData = entry.value;
                final bool isChecked = selectedItems.contains(itemId);

                return CustomSvgCheckboxListTile(
                  svgAsset: itemData['svgPath'] as String,
                  text: itemData['label'] as String,
                  value: isChecked,
                  onChanged: (val) {
                    if (val != null) {
                      onItemToggled(itemId);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
