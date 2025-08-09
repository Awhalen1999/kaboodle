import 'package:kaboodle/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:kaboodle/features/createPackingList/widgets/svg_button_row.dart';

class GenderSelector extends StatelessWidget {
  final String? selectedGender;
  final ValueChanged<String?> onGenderSelected;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onGenderSelected,
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
              'Select your packing profile',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: genderDetails.entries.map((entry) {
                final key = entry.key;
                final details = entry.value;
                return SvgButtonRow(
                  svgAsset: details['svgPath']!,
                  label: details['label']!,
                  isSelected: selectedGender == key,
                  onPressed: () {
                    onGenderSelected(key);
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
