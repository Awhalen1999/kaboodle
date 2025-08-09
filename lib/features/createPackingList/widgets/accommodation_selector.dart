import 'package:flutter/material.dart';
import 'package:kaboodle/features/createPackingList/widgets/svg_button_column.dart';
import 'package:kaboodle/core/constants/app_constants.dart';

class AccommodationSelector extends StatelessWidget {
  final String? selectedAccommodation;
  final ValueChanged<String?> onAccommodationSelected;

  const AccommodationSelector({
    super.key,
    required this.selectedAccommodation,
    required this.onAccommodationSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Helper to build a row of buttons
    Widget buildRow(List<String> keys) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: keys.map((key) {
          final details = accommodationDetails[key]!;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: SvgButtonColumn(
                svgAsset: details['svgPath']!,
                label: details['label']!,
                isSelected: selectedAccommodation == key,
                onPressed: () => onAccommodationSelected(key),
              ),
            ),
          );
        }).toList(),
      );
    }

    // Get the keys and split them for two rows
    final keys = accommodationDetails.keys.toList();
    final firstRowKeys = keys.sublist(0, (keys.length / 2).ceil());
    final secondRowKeys = keys.sublist((keys.length / 2).ceil());

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
              'Accommodations',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildRow(firstRowKeys),
                const SizedBox(height: 16),
                buildRow(secondRowKeys),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
