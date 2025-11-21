import 'package:flutter/material.dart';

/// Bottom sheet for packing list options (edit/continue building and delete)
///
/// Clean, modern UI matching the create packing list feature styling
class PackingListOptionsSheet extends StatelessWidget {
  final int stepCompleted;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PackingListOptionsSheet({
    super.key,
    required this.stepCompleted,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 40.0,
          top: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Edit/Continue Building option
            if (onEdit != null)
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  onEdit!();
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          stepCompleted < 4 ? Icons.edit_note : Icons.edit,
                          size: 24,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        stepCompleted < 4
                            ? 'Continue Building List (Step ${stepCompleted + 1}/4)'
                            : 'Edit List',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Delete option
            if (onDelete != null)
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  onDelete!();
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_rounded,
                          size: 24,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Delete List',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
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
