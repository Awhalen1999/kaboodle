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
class GuestDemoView extends StatelessWidget {
  const GuestDemoView({super.key});

  static final _now = DateTime.now();
  static final _startDate = _now.add(const Duration(days: 14));
  static final _endDate = _now.add(const Duration(days: 21));

  void _showSignUpDialog(BuildContext context) {
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
      drawer: _buildDemoDrawer(context),
      body: Column(
        children: [
          // Filter chips (matching real app)
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
                  isSelected: true,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                FilterChipButton(
                  label: 'Upcoming Trips',
                  count: 1,
                  isSelected: false,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                FilterChipButton(
                  label: 'Incomplete Lists',
                  count: 0,
                  isSelected: false,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                FilterChipButton(
                  label: 'Current Trips',
                  count: 0,
                  isSelected: false,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                FilterChipButton(
                  label: 'Past Trips',
                  count: 0,
                  isSelected: false,
                  onTap: () {},
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 64),
              children: [
                PackingListTile(
                  tripName: 'Beach Trip - Hawaii',
                  description: '7 days in Maui',
                  startDate: DateFormat('MMM d, yyyy').format(_startDate),
                  endDate: DateFormat('MMM d, yyyy').format(_endDate),
                  destination: 'US',
                  accentColor: Colors.blue,
                  stepCompleted: 4,
                  isCompleted: false,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GuestDemoPackingView(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSignUpDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDemoDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
              const ListTile(
                title: Text('My packing lists'),
                leading: Icon(Icons.format_list_bulleted),
              ),
              const ListTile(
                title: Text('Upcoming trips'),
                leading: Icon(Icons.double_arrow_rounded),
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const GuestDemoPackingView(),
                          ),
                        );
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
                    _showSignUpDialog(context);
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
