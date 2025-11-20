import 'package:flutter/material.dart';

class PackingListDrawerTile extends StatelessWidget {
  final String tripName;
  final String? description;
  final Color accentColor;
  final VoidCallback onTap;
  final bool isSelected;

  const PackingListDrawerTile({
    super.key,
    required this.tripName,
    this.description,
    required this.accentColor,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surfaceContainer,
          border: Border.all(
            color: colorScheme.outline,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            // Color stripe
            Container(
              width: 3,
              constraints: const BoxConstraints(minHeight: 40),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(6),
                ),
              ),
            ),
            // Trip name and description
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tripName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (description != null && description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
