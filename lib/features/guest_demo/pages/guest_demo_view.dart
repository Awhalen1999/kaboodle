import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaboodle_app/features/guest_demo/pages/guest_demo_packing_view.dart';
import 'package:kaboodle_app/features/my_packing_lists/widgets/packing_list_tile.dart';
import 'package:kaboodle_app/features/my_packing_lists/widgets/filter_chip_button.dart';
import 'package:kaboodle_app/models/packing_item.dart';
import 'package:kaboodle_app/shared/widgets/custom_app_bar.dart';
import 'package:kaboodle_app/shared/widgets/custom_dialog.dart';
import 'package:kaboodle_app/shared/widgets/packing_list_drawer_tile.dart';

/// Demo landing page that mirrors MyPackingListsView exactly.
///
/// Shows sample packing list tiles. Tapping one opens the demo packing view.
/// Completely self-contained — no providers, no auth, no API calls.
class GuestDemoView extends StatefulWidget {
  const GuestDemoView({super.key});

  @override
  State<GuestDemoView> createState() => _GuestDemoViewState();
}

class _GuestDemoViewState extends State<GuestDemoView> {
  String _selectedFilter = 'all';

  // ---------------------------------------------------------------------------
  // Demo list definitions
  // ---------------------------------------------------------------------------

  static final _now = DateTime.now();

  static final _demoLists = <_DemoList>[
    _DemoList(
      name: 'Beach Trip - Hawaii',
      description: '7 days in Maui',
      destination: 'US',
      accentColor: Colors.blue,
      startDate: _now.add(const Duration(days: 14)),
      endDate: _now.add(const Duration(days: 21)),
      items: _beachItems(),
    ),
    _DemoList(
      name: 'Weekend Camping',
      description: '3 days in Yosemite',
      destination: 'US',
      accentColor: Colors.green,
      startDate: _now.subtract(const Duration(days: 8)),
      endDate: _now.subtract(const Duration(days: 5)),
      items: _campingItems(),
    ),
  ];

  // ---------------------------------------------------------------------------
  // Filtering
  // ---------------------------------------------------------------------------

  List<_DemoList> get _filteredLists {
    final today = DateTime(_now.year, _now.month, _now.day);
    switch (_selectedFilter) {
      case 'upcoming_trips':
        return _demoLists.where((l) => l.startDate.isAfter(today)).toList();
      case 'incomplete_lists':
        return [];
      case 'current_trips':
        return _demoLists
            .where((l) =>
                !l.startDate.isAfter(today) && !l.endDate.isBefore(today))
            .toList();
      case 'past_trips':
        return _demoLists.where((l) => l.endDate.isBefore(today)).toList();
      case 'all':
      default:
        return _demoLists;
    }
  }

  int _countForFilter(String filter) {
    final today = DateTime(_now.year, _now.month, _now.day);
    switch (filter) {
      case 'upcoming_trips':
        return _demoLists.where((l) => l.startDate.isAfter(today)).length;
      case 'incomplete_lists':
        return 0;
      case 'current_trips':
        return _demoLists
            .where((l) =>
                !l.startDate.isAfter(today) && !l.endDate.isBefore(today))
            .length;
      case 'past_trips':
        return _demoLists.where((l) => l.endDate.isBefore(today)).length;
      case 'all':
      default:
        return _demoLists.length;
    }
  }

  void _setFilter(String filter) {
    setState(() => _selectedFilter = filter);
  }

  void _openPacking(_DemoList list) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GuestDemoPackingView(
          initialItems: list.items,
        ),
      ),
    );
  }

  void _showSignUpDialog() {
    CustomDialog.show(
      context: context,
      title: 'Ready to get started?',
      description: 'Create an account to build custom packing lists, '
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
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final lists = _filteredLists;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Packing Lists',
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: _buildDemoDrawer(),
      body: Column(
        children: [
          // Filter chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                const SizedBox(width: 16),
                FilterChipButton(
                  label: 'All Trips',
                  count: _countForFilter('all'),
                  isSelected: _selectedFilter == 'all',
                  onTap: () => _setFilter('all'),
                ),
                const SizedBox(width: 8),
                FilterChipButton(
                  label: 'Upcoming Trips',
                  count: _countForFilter('upcoming_trips'),
                  isSelected: _selectedFilter == 'upcoming_trips',
                  onTap: () => _setFilter('upcoming_trips'),
                ),
                const SizedBox(width: 8),
                FilterChipButton(
                  label: 'Incomplete Lists',
                  count: _countForFilter('incomplete_lists'),
                  isSelected: _selectedFilter == 'incomplete_lists',
                  onTap: () => _setFilter('incomplete_lists'),
                ),
                const SizedBox(width: 8),
                FilterChipButton(
                  label: 'Current Trips',
                  count: _countForFilter('current_trips'),
                  isSelected: _selectedFilter == 'current_trips',
                  onTap: () => _setFilter('current_trips'),
                ),
                const SizedBox(width: 8),
                FilterChipButton(
                  label: 'Past Trips',
                  count: _countForFilter('past_trips'),
                  isSelected: _selectedFilter == 'past_trips',
                  onTap: () => _setFilter('past_trips'),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),

          // List or empty state
          Expanded(
            child: lists.isNotEmpty
                ? ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 64),
                    itemCount: lists.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final list = lists[index];
                      return PackingListTile(
                        tripName: list.name,
                        description: list.description,
                        startDate:
                            DateFormat('MMM d, yyyy').format(list.startDate),
                        endDate: DateFormat('MMM d, yyyy').format(list.endDate),
                        destination: list.destination,
                        accentColor: list.accentColor,
                        stepCompleted: 4,
                        isCompleted: false,
                        onTap: () => _openPacking(list),
                      );
                    },
                  )
                : _buildEmptyFilterState(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSignUpDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyFilterState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'No trips found',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoDrawer() {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('My packing lists'),
                leading: const Icon(Icons.format_list_bulleted),
                onTap: () {
                  Navigator.pop(context);
                  _setFilter('all');
                },
              ),
              ListTile(
                title: const Text('Upcoming trips'),
                leading: const Icon(Icons.double_arrow_rounded),
                onTap: () {
                  Navigator.pop(context);
                  _setFilter('upcoming_trips');
                },
              ),
              const Divider(color: Colors.grey),

              // Demo list entries
              Expanded(
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  itemCount: _demoLists.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final list = _demoLists[index];
                    return PackingListDrawerTile(
                      tripName: list.name,
                      description: list.description,
                      accentColor: list.accentColor,
                      stepCompleted: 4,
                      onTap: () {
                        Navigator.pop(context);
                        _openPacking(list);
                      },
                    );
                  },
                ),
              ),

              // Bottom section
              const Divider(color: Colors.grey),
              Container(
                margin: const EdgeInsets.only(top: 8.0),
                child: ListTile(
                  visualDensity: const VisualDensity(
                    horizontal: -2,
                    vertical: -4,
                  ),
                  title: const SizedBox(
                    height: 20,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Sign Up / Log In',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ),
                  ),
                  subtitle: const Text('Create your account'),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: colorScheme.primary.withValues(alpha: 0.2),
                    ),
                    child: Icon(
                      Icons.person_add_rounded,
                      size: 22,
                      color: colorScheme.primary,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(context);
                    _showSignUpDialog();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Demo item data
  // ---------------------------------------------------------------------------

  static List<PackingItem> _beachItems() {
    final now = DateTime.now();
    var i = 0;
    PackingItem item(String name, String cat,
        {bool packed = false, int qty = 1, String? notes}) {
      return PackingItem(
        id: 'beach_$i',
        packingListId: 'beach',
        name: name,
        category: cat,
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
      item('Swimsuit', 'clothing'),
      item('T-Shirts', 'clothing', qty: 4),
      item('Shorts', 'clothing', qty: 3),
      item('Sandals', 'clothing'),
      item('Light Jacket', 'clothing'),
      item('Beach Towel', 'clothing'),
      item('Sunscreen SPF 50', 'toiletries', packed: true),
      item('Toothbrush & Toothpaste', 'toiletries'),
      item('Shampoo', 'toiletries', notes: 'Travel size'),
      item('Phone Charger', 'electronics', packed: true),
      item('Camera', 'electronics'),
      item('Portable Speaker', 'electronics'),
      item('Pain Relievers', 'medications'),
      item('First Aid Kit', 'medications'),
      item('Band-Aids', 'medications', qty: 10),
      item('Passport', 'documents', packed: true),
      item('Travel Insurance', 'documents'),
      item('Wallet', 'documents', packed: true),
      item('Sunglasses', 'accessories', packed: true),
      item('Hat', 'accessories'),
      item('Reusable Water Bottle', 'accessories'),
      item('Snorkel Gear', 'sports'),
      item('Hiking Boots', 'sports'),
    ];
  }

  static List<PackingItem> _campingItems() {
    final now = DateTime.now();
    var i = 0;
    PackingItem item(String name, String cat,
        {bool packed = false, int qty = 1, String? notes}) {
      return PackingItem(
        id: 'camp_$i',
        packingListId: 'camping',
        name: name,
        category: cat,
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
      item('Hiking Pants', 'clothing', qty: 2),
      item('Warm Layers', 'clothing', qty: 2),
      item('Rain Jacket', 'clothing'),
      item('Hiking Socks', 'clothing', qty: 3),
      item('Bug Spray', 'toiletries', packed: true),
      item('Wet Wipes', 'toiletries', packed: true),
      item('Sunscreen', 'toiletries'),
      item('Flashlight', 'electronics', packed: true),
      item('Portable Charger', 'electronics'),
      item('Campsite Reservation', 'documents', packed: true),
      item('ID', 'documents', packed: true),
      item('Backpack', 'accessories'),
      item('Water Bottle', 'accessories', packed: true),
      item('Pocket Knife', 'accessories'),
      item('Trekking Poles', 'sports'),
      item('First Aid Kit', 'medications'),
      item('Allergy Medication', 'medications'),
    ];
  }
}

/// Simple data holder for a demo packing list.
class _DemoList {
  final String name;
  final String description;
  final String destination;
  final Color accentColor;
  final DateTime startDate;
  final DateTime endDate;
  final List<PackingItem> items;

  const _DemoList({
    required this.name,
    required this.description,
    required this.destination,
    required this.accentColor,
    required this.startDate,
    required this.endDate,
    required this.items,
  });
}
