import 'package:flutter/material.dart';

class PackingListDrawerTile extends StatelessWidget {
  final String tripName;
  final String? description;
  final Color accentColor;
  final VoidCallback onTap;
  final bool isSelected;
  final int stepCompleted;

  const PackingListDrawerTile({
    super.key,
    required this.tripName,
    this.description,
    required this.accentColor,
    required this.onTap,
    this.isSelected = false,
    required this.stepCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        debugPrint('🎯 Tapped packing list: $tripName');
        onTap();
      },
      child: Container(
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
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Color stripe
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(6),
                    ),
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
                          fontWeight: stepCompleted < 4
                              ? FontWeight.w500
                              : (isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500),
                          color: stepCompleted < 4
                              ? colorScheme.onSurface.withValues(alpha: 0.5)
                              : null,
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
                            color: stepCompleted < 4
                                ? colorScheme.onSurface.withValues(alpha: 0.4)
                                : colorScheme.onSurface.withValues(alpha: 0.5),
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
      ),
    );
  }
}
