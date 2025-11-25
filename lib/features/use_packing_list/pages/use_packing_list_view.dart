import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaboodle_app/features/use_packing_list/widgets/use_packing_list_body.dart';
import 'package:kaboodle_app/models/packing_item.dart';
import 'package:kaboodle_app/providers/use_packing_items_provider.dart';
import 'package:kaboodle_app/shared/widgets/custom_dialog.dart';

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
  OverlayEntry? _overlayEntry;
  final GlobalKey _menuButtonKey = GlobalKey();

  void _onStatsUpdated(PackingListStats stats) {
    // Stats updated callback - can be used for progress bar in future
  }

  void _showMenu() {
    final RenderBox? renderBox =
        _menuButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final buttonHeight = renderBox.size.height;

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _hideMenu,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              top: position.dy + buttonHeight + 8,
              right: 16,
              child: GestureDetector(
                onTap: () {},
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainer
                      .withValues(alpha: 0.9),
                  child: Container(
                    width: 200,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMenuItem(
                          icon: Icons.check_box_rounded,
                          label: 'Check All',
                          onTap: () {
                            _hideMenu();
                            ref
                                .read(usePackingItemsProvider(
                                        widget.packingListId)
                                    .notifier)
                                .checkAllItems();
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.check_box_outline_blank_rounded,
                          label: 'Uncheck All',
                          onTap: () {
                            _hideMenu();
                            ref
                                .read(usePackingItemsProvider(
                                        widget.packingListId)
                                    .notifier)
                                .uncheckAllItems();
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.visibility_outlined,
                          label: 'Unhide All',
                          onTap: () {
                            _hideMenu();
                            debugPrint(
                                '👁️ [UsePackingListView] Unhide All clicked');
                          },
                        ),
                        const Divider(height: 1),
                        _buildMenuItem(
                          icon: Icons.refresh,
                          label: 'Reset to Saved',
                          onTap: () {
                            _hideMenu();
                            ref
                                .read(usePackingItemsProvider(
                                        widget.packingListId)
                                    .notifier)
                                .refresh();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hideMenu();
    super.dispose();
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

    final shouldPop = await CustomDialog.show<bool>(
      context: context,
      title: 'Unsaved Changes',
      description:
          'You have unsaved packing progress. Do you want to save before leaving?',
      actions: [
        CustomDialogAction(
          label: 'Discard',
          isDestructive: true,
          onPressed: () {
            debugPrint(
                '🗑️ [UsePackingListView] User chose to discard changes');
            // Restore provider state to original (before any local changes)
            ref
                .read(usePackingItemsProvider(widget.packingListId).notifier)
                .discardChanges();
            Navigator.of(context).pop(true);
          },
        ),
        CustomDialogAction(
          label: 'Save',
          isPrimary: true,
          onPressed: () async {
            debugPrint('💾 [UsePackingListView] User chose to save changes');
            final navigator = Navigator.of(context);

            final success = await notifier.saveProgress();

            if (!mounted) return;

            navigator.pop(success);
          },
        ),
      ],
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
                      key: _menuButtonKey,
                      heroTag: 'options_button',
                      onPressed: _showMenu,
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
          ],
        ),
      ),
    );
  }
}
