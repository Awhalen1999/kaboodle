import 'package:flutter/material.dart';

enum ColorMode {
  light,
  dark,
  system,
}

class ColorModeSelector extends StatelessWidget {
  final ColorMode selectedMode;
  final Function(ColorMode) onModeSelected;

  const ColorModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ColorModeCard(
            mode: ColorMode.system,
            isSelected: selectedMode == ColorMode.system,
            onTap: () {
              print('Color mode selected: System');
              onModeSelected(ColorMode.system);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ColorModeCard(
            mode: ColorMode.light,
            isSelected: selectedMode == ColorMode.light,
            onTap: () {
              print('Color mode selected: Light');
              onModeSelected(ColorMode.light);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ColorModeCard(
            mode: ColorMode.dark,
            isSelected: selectedMode == ColorMode.dark,
            onTap: () {
              print('Color mode selected: Dark');
              onModeSelected(ColorMode.dark);
            },
          ),
        ),
      ],
    );
  }
}

class _ColorModeCard extends StatelessWidget {
  final ColorMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorModeCard({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = mode == ColorMode.light;
    final isDark = mode == ColorMode.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme icon
            Icon(
              isLight
                  ? Icons.wb_sunny
                  : isDark
                      ? Icons.dark_mode
                      : Icons.brightness_auto,
              color: isSelected ? Colors.black : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(height: 16),
            // Label
            Text(
              mode == ColorMode.light
                  ? 'Light'
                  : mode == ColorMode.dark
                      ? 'Dark'
                      : 'System',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? Colors.black : Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
