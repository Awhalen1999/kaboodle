import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kaboodle_app/features/use_packing_list/widgets/use_packing_list_item_tile.dart';
import 'package:kaboodle_app/models/packing_item.dart';
import 'package:kaboodle_app/shared/constants/category_constants.dart';
import 'package:kaboodle_app/theme/expanded_palette.dart';

/// Standalone demo page for iOS App Store compliance (Guideline 5.1.1).
///
/// Shows a sample packing list that users can interact with (check/uncheck)
/// without creating an account. Completely self-contained -- no providers,
/// no auth, no API calls. Just local state and hardcoded data.
class GuestDemoView extends StatefulWidget {
  const GuestDemoView({super.key});

  @override
  State<GuestDemoView> createState() => _GuestDemoViewState();
}

class _GuestDemoViewState extends State<GuestDemoView> {
  late List<PackingItem> _items;
  final Map<String, bool> _categoryExpanded = {};

  @override
  void initState() {
    super.initState();
    _items = _buildDemoItems();
  }

  void _toggleItem(String itemId) {
    setState(() {
      _items = _items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(isPacked: !item.isPacked);
        }
        return item;
      }).toList();
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final packedCount = _items.where((i) => i.isPacked).length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: colorScheme.onSurface),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Beach Trip — Hawaii',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '7 days in Maui  •  18 items',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Progress bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Row(
                children: [
                  Expanded(child: _buildOverallProgressBar()),
                  const SizedBox(width: 12),
                  Text(
                    '$packedCount / ${_items.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Demo banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.touch_app_rounded,
                        size: 20, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This is a sample list — try checking off items!',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Categorized items
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                _buildCategorizedItems(),
              ),
            ),
          ),
        ],
      ),

      // Sign up CTA
      bottomSheet: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: Platform.isIOS ? 32 : 16,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
          ),
        ),
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: Text(
            'Create Your Account',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Categorized item list
  // ---------------------------------------------------------------------------

  List<Widget> _buildCategorizedItems() {
    final Map<String, List<PackingItem>> grouped = {};
    for (final item in _items) {
      final cat = item.category ?? 'Miscellaneous';
      grouped.putIfAbsent(cat, () => []).add(item);
    }

    final sorted = CategoryConstants.sortCategories(grouped.keys.toList());
    final widgets = <Widget>[];

    for (final category in sorted) {
      widgets.add(_buildCategorySection(category, grouped[category]!));
      widgets.add(const SizedBox(height: 20));
    }

    return widgets;
  }

  Widget _buildCategorySection(String category, List<PackingItem> items) {
    _categoryExpanded[category] ??= true;
    final isExpanded = _categoryExpanded[category]!;
    final packedCount = items.where((i) => i.isPacked).length;
    final progress = items.isNotEmpty ? packedCount / items.length : 0.0;
    final categoryColor =
        ExpandedPalette.getCategoryColorWithContext(category, context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            InkWell(
              onTap: () =>
                  setState(() => _categoryExpanded[category] = !isExpanded),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(8),
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

        // Category progress bar
        const SizedBox(height: 8),
        _buildCategoryProgressBar(categoryColor, progress),

        // Items
        if (isExpanded) ...[
          const SizedBox(height: 12),
          ...items.map((item) => UsePackingListItemTile(
                item: item,
                onToggle: () => _toggleItem(item.id),
              )),
        ],
      ],
    );
  }

  Widget _buildCategoryProgressBar(Color color, double progress) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      builder: (context, value, _) {
        return Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceTint,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            FractionallySizedBox(
              widthFactor: value,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: color,
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

  Widget _buildOverallProgressBar() {
    final Map<String, List<PackingItem>> grouped = {};
    for (final item in _items) {
      final cat = item.category ?? 'Miscellaneous';
      grouped.putIfAbsent(cat, () => []).add(item);
    }

    final sorted = CategoryConstants.sortCategories(grouped.keys.toList());

    return SizedBox(
      height: 12,
      child: Row(
        children: sorted.asMap().entries.map((entry) {
          final idx = entry.key;
          final cat = entry.value;
          final catItems = grouped[cat]!;
          final packed = catItems.where((i) => i.isPacked).length;
          final progress = catItems.isNotEmpty ? packed / catItems.length : 0.0;
          final flex = (catItems.length / _items.length * 1000).round();

          return Expanded(
            flex: flex,
            child: Padding(
              padding:
                  EdgeInsets.only(right: idx < sorted.length - 1 ? 4.0 : 0),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                builder: (context, value, _) {
                  final color = ExpandedPalette.getCategoryColorWithContext(
                      cat, context);
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
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Demo data
  // ---------------------------------------------------------------------------

  static List<PackingItem> _buildDemoItems() {
    final now = DateTime.now();
    var i = 0;

    PackingItem item(
      String name,
      String category, {
      bool packed = false,
      int qty = 1,
      String? notes,
    }) {
      return PackingItem(
        id: 'demo_$i',
        packingListId: 'demo_list',
        name: name,
        category: category,
        quantity: qty,
        notes: notes,
        isPacked: packed,
        isCustom: false,
        orderIndex: i++,
        createdAt: now,
        updatedAt: now,
      );
    }

    return [
      item('Swimsuit', 'Clothing'),
      item('T-Shirts', 'Clothing', qty: 4),
      item('Shorts', 'Clothing', qty: 3),
      item('Sandals', 'Clothing'),
      item('Light Jacket', 'Clothing'),
      item('Sunglasses', 'Accessories', packed: true),
      item('Hat', 'Accessories'),
      item('Sunscreen SPF 50', 'Toiletries', packed: true),
      item('Toothbrush & Toothpaste', 'Toiletries'),
      item('Shampoo', 'Toiletries', notes: 'Travel size'),
      item('Phone Charger', 'Electronics', packed: true),
      item('Camera', 'Electronics'),
      item('Portable Speaker', 'Electronics'),
      item('Passport', 'Documents', packed: true),
      item('Travel Insurance', 'Documents'),
      item('Reusable Water Bottle', 'Miscellaneous'),
      item('Beach Towel', 'Miscellaneous'),
      item('Snorkeling Gear', 'Miscellaneous'),
    ];
  }
}
