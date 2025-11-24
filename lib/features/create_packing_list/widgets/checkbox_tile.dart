import 'package:flutter/material.dart';
import 'package:kaboodle_app/shared/constants/category_colors.dart';

/// A clean, modern checkbox tile widget inspired by Notion/ClickUp
///
/// Features:
/// - Checkbox on the left
/// - Icon with colored background next to checkbox
/// - Item name with quantity display (e.g., "T-Shirt x3")
/// - Optional note displayed as subtext
/// - Edit button on the right
/// - Entire tile is clickable to toggle selection
class CheckboxTile extends StatelessWidget {
  final IconData icon;
  final String itemName;
  final String? category;
  final int quantity;
  final String note;
  final bool isSelected;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const CheckboxTile({
    super.key,
    required this.icon,
    required this.itemName,
    this.category,
    this.quantity = 1,
    this.note = '',
    required this.isSelected,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get category color if available
    final categoryColor = category != null
        ? CategoryColors.getCategoryColorWithContext(category!, context)
        : colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? colorScheme.onSurface.withValues(alpha: 0.2)
              : colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Expanded InkWell wrapping checkbox, icon, and text
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onToggle,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    // Checkbox and icon section
                    SizedBox(
                      width: 80,
                      child: Row(
                        children: [
                          Checkbox(
                            value: isSelected,
                            onChanged: (_) => onToggle(),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            fillColor: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.selected)) {
                                return colorScheme.onSurfaceVariant;
                              }
                              return null;
                            }),
                            checkColor: colorScheme.surface,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              icon,
                              size: 22,
                              color: categoryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Text section with name, quantity, and optional note
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$itemName   x$quantity',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.normal,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (note.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                note,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Edit button on the right
          IconButton(
            icon: const Icon(Icons.edit_rounded, size: 20),
            onPressed: onEdit,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
