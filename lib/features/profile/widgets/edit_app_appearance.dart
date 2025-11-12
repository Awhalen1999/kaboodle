import 'package:flutter/material.dart';
import 'package:kaboodle_app/features/profile/widgets/color_mode_selector.dart';
import 'package:kaboodle_app/features/profile/widgets/accent_color_selector.dart';

class EditAppTheme extends StatefulWidget {
  const EditAppTheme({super.key});

  @override
  State<EditAppTheme> createState() => _EditAppThemeState();
}

class _EditAppThemeState extends State<EditAppTheme> {
  ColorMode _selectedColorMode = ColorMode.system;
  Color? _selectedAccentColor; // null means default (primary color)

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Simple list-based approach - easy to add/remove sections
    final sections = [
      _buildSection(
        title: 'Color Scheme',
        subtitle:
            'Kaboodle will match your device settings by default, or choose light or dark mode.',
        content: ColorModeSelector(
          selectedMode: _selectedColorMode,
          onModeSelected: (ColorMode mode) {
            setState(() {
              _selectedColorMode = mode;
            });
          },
        ),
      ),
      _buildSection(
        title: 'Custom theme accent',
        subtitle:
            'Choose a custom accent color or use the default theme color.',
        content: AccentColorSelector(
          selectedColor: _selectedAccentColor,
          onColorSelected: (Color? color) {
            setState(() {
              _selectedAccentColor = color;
            });
          },
        ),
      ),
      // Add more sections here easily - just add another _buildSection call
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...sections
            .expand((section) => [
                  section,
                  const SizedBox(height: 32),
                ])
            .toList()
          ..removeLast(), // Remove last spacing
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }
}
