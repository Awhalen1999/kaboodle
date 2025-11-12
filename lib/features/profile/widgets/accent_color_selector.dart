import 'package:flutter/material.dart';

class AccentColorSelector extends StatelessWidget {
  final Color? selectedColor;
  final Function(Color?) onColorSelected;

  const AccentColorSelector({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  // Available accent colors - more subtle, Slack/Notion style
  static const List<Color> accentColors = [
    Color(0xFF2196F3), // Blue
    Color(0xFF9C27B0), // Purple
    Color(0xFFE91E63), // Pink
    Color(0xFF00BCD4), // Teal
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFFF44336), // Red
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF9E9E9E), // Grey
    Color(0xFFFFC107), // Amber
    Color(0xFF3F51B5), // Indigo
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDefaultSelected = selectedColor == null;

    return Column(
      children: [
        // First row - Default + 5 colors
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Default option
            GestureDetector(
              onTap: () {
                print('Accent color selected: Default (Primary)');
                onColorSelected(null);
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDefaultSelected ? Colors.black : Colors.grey[300]!,
                    width: isDefaultSelected ? 2 : 1,
                  ),
                ),
              ),
            ),
            // First 5 accent colors
            ...accentColors.take(5).map((Color color) {
              final isSelected =
                  selectedColor != null && color.value == selectedColor!.value;
              return GestureDetector(
                onTap: () {
                  print(
                      'Accent color selected: ${color.value.toRadixString(16)}');
                  onColorSelected(color);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 8),
        // Second row - 6 colors
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: accentColors.skip(5).take(6).map((Color color) {
            final isSelected =
                selectedColor != null && color.value == selectedColor!.value;
            return GestureDetector(
              onTap: () {
                print(
                    'Accent color selected: ${color.value.toRadixString(16)}');
                onColorSelected(color);
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
