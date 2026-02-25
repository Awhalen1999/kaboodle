import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaboodle_app/features/guest_demo/pages/guest_demo_packing_view.dart';
import 'package:kaboodle_app/features/my_packing_lists/widgets/packing_list_tile.dart';
import 'package:kaboodle_app/features/my_packing_lists/widgets/filter_chip_button.dart';
import 'package:kaboodle_app/shared/widgets/custom_app_bar.dart';
import 'package:kaboodle_app/shared/widgets/custom_dialog.dart';
import 'package:kaboodle_app/shared/widgets/packing_list_drawer_tile.dart';

/// Demo landing page that mirrors MyPackingListsView exactly.
///
/// Shows one sample packing list tile. Tapping it opens the demo packing view.
/// Completely self-contained — no providers, no auth, no API calls.
class GuestDemoView extends StatefulWidget {
  const GuestDemoView({super.key});

  @override
  State<GuestDemoView> createState() => _GuestDemoViewState();
}

class _GuestDemoViewState extends State<GuestDemoView> {
  String _selectedFilter = 'all';

  static final _now = DateTime.now();
  static final _startDate = _now.add(const Duration(days: 14));
  static final _endDate = _now.add(const Duration(days: 21));

  // The demo list is upcoming (starts in 14 days), complete (step 4), not packed
  bool get _showList =>
      _selectedFilter == 'all' || _selectedFilter == 'upcoming_trips';

  void _setFilter(String filter) {
    setState(() => _selectedFilter = filter);
  }

  void _openPacking() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GuestDemoPackingView()),
    );
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
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  count: 1,
                  isSelected: _selectedFilter == 'all',
                  onTap: () => _setFilter('all'),
                ),
                const SizedBox(width: 8),
                FilterChipButton(
                  label: 'Upcoming Trips',
                  count: 1,
                  isSelected: _selectedFilter == 'upcoming_trips',
                  onTap: () => _setFilter('upcoming_trips'),
                ),
                const SizedBox(width: 8),
                FilterChipButton(
                  label: 'Incomplete Lists',
                  count: 0,
                  isSelected: _selectedFilter == 'incomplete_lists',
                  onTap: () => _setFilter('incomplete_lists'),
                ),
                const SizedBox(width: 8),
                FilterChipButton(
                  label: 'Current Trips',
                  count: 0,
                  isSelected: _selectedFilter == 'current_trips',
                  onTap: () => _setFilter('current_trips'),
                ),
                const SizedBox(width: 8),
                FilterChipButton(
                  label: 'Past Trips',
                  count: 0,
                  isSelected: _selectedFilter == 'past_trips',
                  onTap: () => _setFilter('past_trips'),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),

          // List or empty state
          Expanded(
            child: _showList
                ? ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 64),
                    children: [
                      PackingListTile(
                        tripName: 'Beach Trip - Hawaii',
                        description: '7 days in Maui',
                        startDate:
                            DateFormat('MMM d, yyyy').format(_startDate),
                        endDate: DateFormat('MMM d, yyyy').format(_endDate),
                        destination: 'US',
                        accentColor: Colors.blue,
                        stepCompleted: 4,
                        isCompleted: false,
                        onTap: _openPacking,
                      ),
                    ],
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

              // Demo list entry
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  children: [
                    PackingListDrawerTile(
                      tripName: 'Beach Trip - Hawaii',
                      description: '7 days in Maui',
                      accentColor: Colors.blue,
                      stepCompleted: 4,
                      onTap: () {
                        Navigator.pop(context);
                        _openPacking();
                      },
                    ),
                  ],
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
}
