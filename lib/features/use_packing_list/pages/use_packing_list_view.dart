import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:kaboodle_app/features/use_packing_list/widgets/use_packing_list_body.dart';
import 'package:kaboodle_app/shared/widgets/custom_app_bar.dart';
import 'package:kaboodle_app/models/packing_item.dart';
import 'package:kaboodle_app/providers/use_packing_items_provider.dart';

class UsePackingListView extends ConsumerStatefulWidget {
  final String packingListId;
  final String packingListName;

  const UsePackingListView({
    super.key,
    required this.packingListId,
    required this.packingListName,
  });

  @override
  ConsumerState<UsePackingListView> createState() => _UsePackingListViewState();
}

class _UsePackingListViewState extends ConsumerState<UsePackingListView> {
  PackingListStats? _stats;

  void _onStatsUpdated(PackingListStats stats) {
    setState(() {
      _stats = stats;
    });
  }

  Future<bool> _onWillPop() async {
    debugPrint('🚪 [UsePackingListView] Back button pressed');

    final notifier =
        ref.read(usePackingItemsProvider(widget.packingListId).notifier);
    final hasUnsavedChanges = notifier.hasUnsavedChanges();

    if (!hasUnsavedChanges) {
      debugPrint(
          '✅ [UsePackingListView] No unsaved changes, allowing navigation');
      return true;
    }

    debugPrint(
        '⚠️ [UsePackingListView] Unsaved changes detected, showing dialog');

    if (!mounted) return false;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved packing progress. Do you want to save before leaving?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint(
                  '🗑️ [UsePackingListView] User chose to discard changes');
              // Refresh provider to discard local changes and reload from API
              ref.invalidate(usePackingItemsProvider(widget.packingListId));
              Navigator.of(context).pop(true); // Discard and leave
            },
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () {
              debugPrint('🚫 [UsePackingListView] User cancelled navigation');
              Navigator.of(context).pop(false); // Cancel navigation
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              debugPrint('💾 [UsePackingListView] User chose to save changes');
              final navigator = Navigator.of(context);

              // Save progress
              final success = await notifier.saveProgress();

              if (!mounted) return;

              navigator.pop(success); // Close dialog with save result
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Main content
            UsePackingListBody(
              packingListId: widget.packingListId,
              packingListName: widget.packingListName,
              onStatsUpdated: _onStatsUpdated,
            ),
            // Floating action buttons
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left floating button (back)
                    FloatingActionButton(
                      heroTag: 'back_button',
                      onPressed: () async {
                        final shouldPop = await _onWillPop();
                        if (shouldPop && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      elevation: 2,
                      mini: true,
                      child: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    // Right floating button (options/menu)
                    FloatingActionButton(
                      heroTag: 'options_button',
                      onPressed: () {
                        // TODO: Add options/menu functionality
                      },
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      elevation: 2,
                      mini: true,
                      child: Icon(
                        Icons.more_horiz,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Progress bar (commented out for later use)
            // if (_stats != null)
            //   Positioned(
            //     top: 0,
            //     left: 0,
            //     right: 0,
            //     child: SafeArea(
            //       child: Padding(
            //         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            //         child: StepProgressIndicator(
            //           totalSteps: _stats!.total > 0 ? _stats!.total : 1,
            //           currentStep: _stats!.packed,
            //           size: 8,
            //           padding: 0,
            //           selectedGradientColor: LinearGradient(
            //             colors: [
            //               Theme.of(context).colorScheme.secondary,
            //               Theme.of(context).colorScheme.tertiary,
            //             ],
            //           ),
            //           unselectedColor: Colors.grey[300]!,
            //         ),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
