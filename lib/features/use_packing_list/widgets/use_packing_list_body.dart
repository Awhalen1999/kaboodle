import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaboodle_app/models/packing_item.dart';
import 'package:kaboodle_app/providers/trips_provider.dart';
import 'package:kaboodle_app/providers/use_packing_items_provider.dart';
import 'package:kaboodle_app/providers/user_provider.dart';
import 'package:kaboodle_app/shared/utils/format_utils.dart';
import 'package:kaboodle_app/shared/constants/category_constants.dart';
import 'package:kaboodle_app/theme/expanded_palette.dart';
import 'package:kaboodle_app/features/use_packing_list/widgets/use_packing_list_item_tile.dart';
import 'package:kaboodle_app/services/trip/trip_service.dart';
import 'package:toastification/toastification.dart';
import 'package:lottie/lottie.dart';

class UsePackingListBody extends ConsumerStatefulWidget {
  final String packingListId;
  final String packingListName;
  final void Function(PackingListStats)? onStatsUpdated;

  const UsePackingListBody({
    super.key,
    required this.packingListId,
    required this.packingListName,
    this.onStatsUpdated,
  });

  @override
  ConsumerState<UsePackingListBody> createState() => _UsePackingListBodyState();
}

class _UsePackingListBodyState extends ConsumerState<UsePackingListBody> {
  bool _isSaving = false;

  // Track expansion state for each category
  final Map<String, bool> _categoryExpanded = {};

  @override
  void initState() {
    super.initState();
    debugPrint(
        '🎬 [UsePackingListBody] Initializing for list: ${widget.packingListId}');
  }

  void _toggleItemPacked(String itemId) {
    debugPrint('🔘 [UsePackingListBody] User toggled item: $itemId');
    ref
        .read(usePackingItemsProvider(widget.packingListId).notifier)
        .toggleItemPacked(itemId);
    // Stats will be updated in build method via postFrameCallback
  }

  Future<void> _handleSaveProgress() async {
    debugPrint('💾 [UsePackingListBody] Save button pressed');

    final itemsAsync = ref.read(usePackingItemsProvider(widget.packingListId));

    // Get allPacked state from items
    final allPacked = itemsAsync.whenOrNull(
          data: (items) =>
              items.isNotEmpty && items.every((item) => item.isPacked),
        ) ??
        false;

    debugPrint('💾 [UsePackingListBody] All items packed: $allPacked');

    setState(() {
      _isSaving = true;
    });

    try {
      final notifier =
          ref.read(usePackingItemsProvider(widget.packingListId).notifier);
      final success = await notifier.saveProgress();

      if (!mounted) return;

      if (success) {
        debugPrint('✅ [UsePackingListBody] Save successful');

        // If all items are packed, mark the packing list as complete
        if (allPacked) {
          debugPrint(
              '🎯 [UsePackingListBody] Marking packing list as complete');
          final tripService = TripService();
          final packingList = await tripService.getPackingList(
            packingListId: widget.packingListId,
          );

          if (packingList != null && mounted) {
            final updateResult = await tripService.upsertPackingList(
              id: widget.packingListId,
              name: packingList.name,
              startDate: packingList.startDate,
              endDate: packingList.endDate,
              description: packingList.description,
              destination: packingList.destination,
              colorTag: packingList.colorTag,
              gender: packingList.gender,
              weather: packingList.weather,
              purpose: packingList.purpose,
              accommodations: packingList.accommodations,
              activities: packingList.activities,
              isCompleted: true,
            );
            debugPrint(
                '📦 [UsePackingListBody] Mark complete result: ${updateResult.success}');

            // Refresh the packing lists provider so the main page shows the complete tag
            if (updateResult.success) {
              ref.read(packingListsProvider.notifier).refresh();
              debugPrint(
                  '🔄 [UsePackingListBody] Refreshed packing lists provider');
            }
          }
        }

        if (!mounted) return;

        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.minimal,
          title: Text(allPacked ? 'Packing complete! 🎉' : 'Progress saved'),
          description: allPacked
              ? const Text('All items packed and saved')
              : const Text('Your packing progress has been saved'),
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.topCenter,
        );

        if (allPacked) {
          debugPrint(
              '🎯 [UsePackingListBody] All items complete, navigating back');
          // Navigate back after a short delay to show the success message
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      } else {
        debugPrint('❌ [UsePackingListBody] Save failed');
        _showErrorToast('Failed to save progress');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [UsePackingListBody] Error saving: $e');
      debugPrint(stackTrace.toString());

      if (mounted) {
        _showErrorToast('Error saving progress: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showErrorToast(String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.minimal,
      title: const Text('Error'),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      alignment: Alignment.topCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemsAsync = ref.watch(usePackingItemsProvider(widget.packingListId));
    final userAsync = ref.watch(userProvider);

    return Column(
      children: [
        // Items section
        Expanded(
          child: itemsAsync.when(
            data: (items) {
              // Calculate stats directly from items
              final packedCount = items.where((item) => item.isPacked).length;
              final stats = PackingListStats(
                total: items.length,
                packed: packedCount,
                remaining: items.length - packedCount,
              );

              // Update parent with stats whenever items change
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.onStatsUpdated?.call(stats);
              });

              if (items.isEmpty) {
                return const Center(child: Text('No items found'));
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Character/Illustration Section
                    Stack(
                      children: [
                        ClipPath(
                          clipper: WaveClipper(),
                          child: Container(
                            width: double.infinity,
                            height: 350,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  theme.colorScheme.secondaryContainer
                                      .withValues(alpha: 0.35),
                                  theme.colorScheme.secondaryContainer
                                      .withValues(alpha: 0.15),
                                  theme.colorScheme.secondaryContainer
                                      .withValues(alpha: 0.05),
                                ],
                                stops: const [0.0, 0.6, 1.0],
                              ),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 48, left: 16, right: 16, bottom: 0),
                                child: Lottie.asset(
                                  'assets/lottie/laughing_cat.json',
                                  fit: BoxFit.contain,
                                  height: 220,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Header Content Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userAsync.when(
                              data: (user) => user != null
                                  ? 'Hi, ${FormatUtils.formatDisplayName(user.displayName, user.email)} 👋 '
                                  : 'Hi, there!',
                              loading: () => 'Hi,',
                              error: (_, __) => 'Hi,',
                            ),
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lets get started!',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Check off items as you pack them for your trip.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Checklist Section with categorized items
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: _buildCategorizedItems(items),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () {
              return const Center(child: CircularProgressIndicator());
            },
            error: (error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error loading items: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(usePackingItemsProvider(widget.packingListId)
                                .notifier)
                            .refresh();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Overall Progress Bar and Save Progress / Finish Button
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: SafeArea(
            top: false,
            child: itemsAsync.when(
              data: (items) {
                if (items.isEmpty) return const SizedBox.shrink();

                // Calculate if all items are packed directly from items
                final allPacked =
                    items.isNotEmpty && items.every((item) => item.isPacked);
                final buttonText = allPacked ? 'Finish' : 'Save Progress';

                return Column(
                  children: [
                    // Overall segmented progress bar
                    _buildOverallProgressBar(items),
                    const SizedBox(height: 16),
                    // Save/Finish button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _isSaving ? null : _handleSaveProgress,
                        child: _isSaving
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : Text(
                                buttonText,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }

  /// Build categorized list of items
  List<Widget> _buildCategorizedItems(List<PackingItem> items) {
    if (items.isEmpty) {
      return [];
    }

    // Group items by category
    final Map<String, List<PackingItem>> categorizedItems = {};
    for (var item in items) {
      final category = item.category ?? 'Miscellaneous';
      if (!categorizedItems.containsKey(category)) {
        categorizedItems[category] = [];
      }
      categorizedItems[category]!.add(item);
    }

    // Sort categories using CategoryConstants
    final sortedCategories =
        CategoryConstants.sortCategories(categorizedItems.keys.toList());

    // Build UI for each category in sorted order
    final List<Widget> widgets = [];
    for (var category in sortedCategories) {
      widgets.add(_buildCategorySection(category, categorizedItems[category]!));
      widgets.add(const SizedBox(height: 24));
    }

    return widgets;
  }

  /// Build a category section with its items
  Widget _buildCategorySection(String category, List<PackingItem> items) {
    // Initialize expansion state if not already set
    _categoryExpanded[category] ??= true;
    final isExpanded = _categoryExpanded[category]!;

    // Calculate progress for this category
    final totalItems = items.length;
    final packedItems = items.where((item) => item.isPacked).length;
    final progress = totalItems > 0 ? packedItems / totalItems : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header with clickable arrow
        Row(
          children: [
            // Clickable arrow icon
            InkWell(
              onTap: () {
                setState(() {
                  _categoryExpanded[category] = !isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Category title
            Expanded(
              child: Text(
                category.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
              ),
            ),
          ],
        ),
        // Progress indicator below category title
        const SizedBox(height: 8),
        _buildCategoryProgressIndicator(
            category, progress, packedItems, totalItems),
        // Collapsible items section
        if (isExpanded) ...[
          const SizedBox(height: 12),
          ...items.map((item) => UsePackingListItemTile(
                item: item,
                onToggle: () => _toggleItemPacked(item.id),
              )),
        ],
      ],
    );
  }

  /// Build overall segmented progress bar showing all categories
  Widget _buildOverallProgressBar(List<PackingItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    // Group items by category
    final Map<String, List<PackingItem>> categorizedItems = {};
    for (var item in items) {
      final category = item.category ?? 'Miscellaneous';
      if (!categorizedItems.containsKey(category)) {
        categorizedItems[category] = [];
      }
      categorizedItems[category]!.add(item);
    }

    // Sort categories
    final sortedCategories =
        CategoryConstants.sortCategories(categorizedItems.keys.toList());

    // Calculate total items for proportional width
    final totalItems = items.length;

    return SizedBox(
      height: 12,
      child: Row(
        children: sortedCategories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final categoryItems = categorizedItems[category]!;
          final categoryItemCount = categoryItems.length;
          final packedCount =
              categoryItems.where((item) => item.isPacked).length;
          final categoryProgress =
              categoryItemCount > 0 ? packedCount / categoryItemCount : 0.0;

          // Calculate proportional width
          final widthFraction = categoryItemCount / totalItems;

          return Expanded(
            flex: (widthFraction * 1000)
                .round(), // Use flex for proportional sizing
            child: Padding(
              padding: EdgeInsets.only(
                right: index < sortedCategories.length - 1 ? 4.0 : 0,
              ),
              child: _buildSegment(category, categoryProgress),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build a single segment for the overall progress bar
  Widget _buildSegment(String category, double progress) {
    final categoryColor =
        ExpandedPalette.getCategoryColorWithContext(category, context);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: progress),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceTint,
            borderRadius: BorderRadius.circular(6),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build progress indicator for a category section
  Widget _buildCategoryProgressIndicator(
      String category, double progress, int packedItems, int totalItems) {
    final categoryColor =
        ExpandedPalette.getCategoryColorWithContext(category, context);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0,
        end: progress,
      ),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Stack(
          children: [
            // Background (unfilled portion)
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceTint,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            // Filled portion with category color
            FractionallySizedBox(
              widthFactor: value,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(3),
                    bottomLeft: const Radius.circular(3),
                    topRight:
                        value == 1.0 ? const Radius.circular(3) : Radius.zero,
                    bottomRight:
                        value == 1.0 ? const Radius.circular(3) : Radius.zero,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Custom clipper for soft, rounded cloud-like bottom edge
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Start from top left
    path.lineTo(0, 0);
    path.lineTo(0, size.height - 35);

    // First cloud bump (tall, climbing UP from left edge)
    path.cubicTo(
      size.width * 0.02,
      size.height - 40,
      size.width * 0.08,
      size.height - 5,
      size.width * 0.18,
      size.height - 10,
    );

    path.cubicTo(
      size.width * 0.25,
      size.height - 14,
      size.width * 0.30,
      size.height - 28,
      size.width * 0.38,
      size.height - 22,
    );

    // Second cloud bump (medium rounded)
    path.cubicTo(
      size.width * 0.44,
      size.height - 18,
      size.width * 0.50,
      size.height - 38,
      size.width * 0.58,
      size.height - 36,
    );

    path.cubicTo(
      size.width * 0.64,
      size.height - 34,
      size.width * 0.68,
      size.height - 24,
      size.width * 0.74,
      size.height - 20,
    );

    // Third cloud bump (gentle rounded)
    path.cubicTo(
      size.width * 0.80,
      size.height - 18,
      size.width * 0.86,
      size.height - 32,
      size.width * 0.92,
      size.height - 30,
    );

    path.cubicTo(
      size.width * 0.96,
      size.height - 28,
      size.width * 0.99,
      size.height - 22,
      size.width,
      size.height - 20,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
