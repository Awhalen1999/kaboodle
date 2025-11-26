import 'package:flutter/material.dart';
import 'package:kaboodle_app/models/packing_item.dart';
import 'package:kaboodle_app/shared/utils/icon_utils.dart';
import 'package:kaboodle_app/theme/expanded_palette.dart';

/// A clean, modern checkbox tile widget for the use packing list feature
///
/// Features:
/// - Checkbox on the left
/// - Icon with colored background next to checkbox
/// - Item name with optional notes
/// - Quantity chip (always shown, even if quantity is 1)
/// - Eye icon button for hiding items
/// - Entire tile is clickable to toggle selection
class UsePackingListItemTile extends StatelessWidget {
  final PackingItem item;
  final VoidCallback onToggle;
  final VoidCallback onHide;

  const UsePackingListItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onHide,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get icon from category if available, otherwise use default
    final icon = item.category != null
        ? IconUtils.getIconData(item.category!)
        : Icons.category;

    // Get category color
    final categoryColor = item.category != null
        ? ExpandedPalette.getCategoryColorWithContext(item.category!, context)
        : colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: item.isPacked
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isPacked
              ? colorScheme.outlineVariant
              : colorScheme.outline.withValues(alpha: 0.75),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Expanded InkWell wrapping checkbox, icon, text, and quantity chip
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
                            value: item.isPacked,
                            onChanged: (_) => onToggle(),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            fillColor:
                                WidgetStateProperty.resolveWith((states) {
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

                    // Text section with name and optional note
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.normal,
                              decoration: item.isPacked
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: item.isPacked
                                  ? colorScheme.onSurface.withValues(alpha: 0.6)
                                  : colorScheme.onSurface,
                            ),
                          ),
                          if (item.notes != null && item.notes!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                item.notes!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Quantity chip (always shown)
                    const SizedBox(width: 8),
                    Chip(
                      label: Text('x${item.quantity}'),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Eye icon button for hiding items
          IconButton(
            icon: const Icon(Icons.visibility_outlined, size: 20),
            onPressed: onHide,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
