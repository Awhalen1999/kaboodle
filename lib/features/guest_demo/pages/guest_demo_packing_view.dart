import 'package:flutter/material.dart';
import 'package:kaboodle_app/features/use_packing_list/widgets/use_packing_list_item_tile.dart';
import 'package:kaboodle_app/models/packing_item.dart';
import 'package:kaboodle_app/shared/constants/category_constants.dart';
import 'package:kaboodle_app/shared/widgets/custom_dialog.dart';
import 'package:kaboodle_app/theme/expanded_palette.dart';
import 'package:lottie/lottie.dart';

/// Demo packing view that mirrors UsePackingListView exactly.
///
/// Replicates the wave header, categorized items, floating buttons,
/// progress bars, and save button — all with local state.
class GuestDemoPackingView extends StatefulWidget {
  const GuestDemoPackingView({super.key});

  @override
  State<GuestDemoPackingView> createState() => _GuestDemoPackingViewState();
}

class _GuestDemoPackingViewState extends State<GuestDemoPackingView> {
  late List<PackingItem> _items;
  final Map<String, bool> _categoryExpanded = {};
  OverlayEntry? _overlayEntry;
  final GlobalKey _menuButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _items = _buildDemoItems();
  }

  @override
  void dispose() {
    _hideMenu();
    super.dispose();
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

  void _checkAll() {
    setState(() {
      _items = _items.map((i) => i.copyWith(isPacked: true)).toList();
    });
  }

  void _uncheckAll() {
    setState(() {
      _items = _items.map((i) => i.copyWith(isPacked: false)).toList();
    });
  }

  void _resetItems() {
    setState(() {
      _items = _buildDemoItems();
    });
  }

  void _showSignUpDialog() {
    CustomDialog.show(
      context: context,
      title: 'Ready to Get Started?',
      description:
          'Create an account to build custom packing lists, '
          'save your progress, and sync everything across your devices.',
      showCloseButton: false,
      actions: [
        CustomDialogAction(
          label: 'Not Now',
          isOutlined: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
        CustomDialogAction(
          label: 'Sign Up',
          isPrimary: true,
          onPressed: () {
            Navigator.of(context).pop();
            // Pop back to demo list, then back to welcome
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Overlay menu (mirrors UsePackingListView)
  // ---------------------------------------------------------------------------

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
                  child: SizedBox(
                    width: 200,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMenuItem(
                          icon: Icons.check_box_rounded,
                          label: 'Check All',
                          onTap: () {
                            _hideMenu();
                            _checkAll();
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.check_box_outline_blank_rounded,
                          label: 'Uncheck All',
                          onTap: () {
                            _hideMenu();
                            _uncheckAll();
                          },
                        ),
                        const Divider(height: 1),
                        _buildMenuItem(
                          icon: Icons.refresh,
                          label: 'Reset',
                          onTap: () {
                            _hideMenu();
                            _resetItems();
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

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allPacked =
        _items.isNotEmpty && _items.every((item) => item.isPacked);

    return Scaffold(
      body: Stack(
        children: [
          // Main content (mirrors UsePackingListBody)
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Wave header with illustration
                      Stack(
                        children: [
                          ClipPath(
                            clipper: _WaveClipper(),
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
                                      top: 48, left: 16, right: 16),
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

                      // Greeting header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, there! 👋',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Lets get started!',
                              style:
                                  theme.textTheme.headlineMedium?.copyWith(
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

                      // Categorized items
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: _buildCategorizedItems(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom bar (progress + save button)
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      _buildOverallProgressBar(),
                      const SizedBox(height: 16),
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
                          onPressed: _showSignUpDialog,
                          child: Text(
                            allPacked ? 'Finish' : 'Save Progress',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating action buttons (mirrors UsePackingListView)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton(
                    heroTag: 'demo_back',
                    onPressed: () => Navigator.of(context).pop(),
                    backgroundColor: theme.colorScheme.surface,
                    elevation: 2,
                    mini: true,
                    child: Icon(
                      Icons.arrow_back,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  FloatingActionButton(
                    key: _menuButtonKey,
                    heroTag: 'demo_options',
                    onPressed: _showMenu,
                    backgroundColor: theme.colorScheme.surface,
                    elevation: 2,
                    mini: true,
                    child: Icon(
                      Icons.more_horiz,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Categorized item list (mirrors UsePackingListBody)
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
      widgets.add(const SizedBox(height: 24));
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
        const SizedBox(height: 8),
        _buildCategoryProgressBar(categoryColor, progress),
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
      // clothing
      item('Swimsuit', 'clothing'),
      item('T-Shirts', 'clothing', qty: 4),
      item('Shorts', 'clothing', qty: 3),
      item('Sandals', 'clothing'),
      item('Light Jacket', 'clothing'),
      item('Beach Towel', 'clothing'),
      // toiletries
      item('Sunscreen SPF 50', 'toiletries', packed: true),
      item('Toothbrush & Toothpaste', 'toiletries'),
      item('Shampoo', 'toiletries', notes: 'Travel size'),
      // electronics
      item('Phone Charger', 'electronics', packed: true),
      item('Camera', 'electronics'),
      item('Portable Speaker', 'electronics'),
      // medications
      item('Pain Relievers', 'medications'),
      item('First Aid Kit', 'medications'),
      item('Band-Aids', 'medications', qty: 10),
      // documents
      item('Passport', 'documents', packed: true),
      item('Travel Insurance', 'documents'),
      item('Wallet', 'documents', packed: true),
      // accessories
      item('Sunglasses', 'accessories', packed: true),
      item('Hat', 'accessories'),
      item('Reusable Water Bottle', 'accessories'),
      // sports
      item('Snorkel Gear', 'sports'),
      item('Hiking Boots', 'sports'),
    ];
  }
}

/// Mirrors WaveClipper from use_packing_list_body.dart
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    path.lineTo(0, size.height - 35);

    path.cubicTo(size.width * 0.02, size.height - 40, size.width * 0.08,
        size.height - 5, size.width * 0.18, size.height - 10);
    path.cubicTo(size.width * 0.25, size.height - 14, size.width * 0.30,
        size.height - 28, size.width * 0.38, size.height - 22);
    path.cubicTo(size.width * 0.44, size.height - 18, size.width * 0.50,
        size.height - 38, size.width * 0.58, size.height - 36);
    path.cubicTo(size.width * 0.64, size.height - 34, size.width * 0.68,
        size.height - 24, size.width * 0.74, size.height - 20);
    path.cubicTo(size.width * 0.80, size.height - 18, size.width * 0.86,
        size.height - 32, size.width * 0.92, size.height - 30);
    path.cubicTo(size.width * 0.96, size.height - 28, size.width * 0.99,
        size.height - 22, size.width, size.height - 20);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
