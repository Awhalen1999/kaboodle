import 'package:flutter/material.dart';

class ColorPicker extends StatefulWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const ColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  int _selectedIndex = 0;
  late List<Color> _colors;

  @override
  void initState() {
    super.initState();

    // We'll define the color list once here
    _colors = [
      Colors.grey,
      Colors.red,
      Colors.pink,
      Colors.lightBlue,
      Colors.green,
      Colors.orange,
    ];

    // Check the current color and find which index matches
    final currentColor = widget.selectedColor;

    // If the current color is in our list, pick that index. Otherwise default to 0.
    final index = _colors.indexOf(currentColor);
    if (index != -1) {
      _selectedIndex = index;
    }
  }

  @override
  void didUpdateWidget(ColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedColor != widget.selectedColor) {
      final index = _colors.indexOf(widget.selectedColor);
      if (index != -1) {
        _selectedIndex = index;
      }
    }
  }

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
              'Choose a list color',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Select a color to easily identify your list.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_colors.length, (index) {
                final color = _colors[index];
                return IconButton(
                  icon: Icon(
                    Icons.circle,
                    color: color,
                    size: _selectedIndex == index ? 32 : 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                    // Update with the new color
                    widget.onColorSelected(_colors[index]);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
