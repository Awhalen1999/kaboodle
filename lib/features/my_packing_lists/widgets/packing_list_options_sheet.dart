import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Bottom sheet for packing list options (edit/continue building, share, and delete)
///
/// Clean, modern UI matching the create packing list feature styling
class PackingListOptionsSheet extends StatelessWidget {
  final int stepCompleted;
  final bool isCompleted;
  final VoidCallback? onEdit;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;
  final VoidCallback? onSetNewTripDate;
  final VoidCallback? onResetProgress;

  const PackingListOptionsSheet({
    super.key,
    required this.stepCompleted,
    this.isCompleted = false,
    this.onEdit,
    this.onShare,
    this.onDelete,
    this.onSetNewTripDate,
    this.onResetProgress,
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

            // Set New Trip Date option (only for completed lists)
            if (stepCompleted >= 4 && isCompleted && onSetNewTripDate != null)
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  onSetNewTripDate!();
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
                          Icons.calendar_month_rounded,
                          size: 24,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Set New Trip Date',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Reset Progress option (only for completed lists)
            if (stepCompleted >= 4 && onResetProgress != null)
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  debugPrint('🔄 Reset Progress clicked');
                  onResetProgress!();
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
                          Icons.refresh_rounded,
                          size: 24,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Reset Progress',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
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

            // Share option (commented out for future implementation)
            // if (onShare != null)
            //   InkWell(
            //     onTap: () {
            //       Navigator.pop(context);
            //       onShare!();
            //     },
            //     borderRadius: BorderRadius.circular(8),
            //     child: Padding(
            //       padding: const EdgeInsets.symmetric(
            //         horizontal: 4,
            //         vertical: 16,
            //       ),
            //       child: Row(
            //         children: [
            //           Container(
            //             decoration: BoxDecoration(
            //               color: colorScheme.primary.withValues(alpha: 0.2),
            //               borderRadius: BorderRadius.circular(8),
            //             ),
            //             padding: const EdgeInsets.all(4),
            //             child: Icon(
            //               Icons.link_rounded,
            //               size: 24,
            //               color: colorScheme.onSurface,
            //             ),
            //           ),
            //           const SizedBox(width: 16),
            //           Text(
            //             'Share List',
            //             style: theme.textTheme.bodyLarge?.copyWith(
            //               color: colorScheme.onSurface,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),

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
