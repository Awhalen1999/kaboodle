import 'package:flutter/material.dart';
import 'package:kaboodle_app/models/item_template.dart';
import 'package:kaboodle_app/services/trip/trip_service.dart';
import 'package:kaboodle_app/features/create_packing_list/widgets/checkbox_tile.dart';

class Step3GenerateItemsBody extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(Map<String, dynamic>) onDataChanged;

  const Step3GenerateItemsBody({
    super.key,
    required this.formData,
    required this.onDataChanged,
  });

  @override
  State<Step3GenerateItemsBody> createState() => _Step3GenerateItemsBodyState();
}

class _Step3GenerateItemsBodyState extends State<Step3GenerateItemsBody> {
  final TripService _tripService = TripService();
  bool _isLoading = false;
  List<ItemTemplate>? _suggestions;
  String? _errorMessage;

  // Track selected items and their quantities
  final Map<String, bool> _selectedItems = {};
  final Map<String, int> _itemQuantities = {};

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final packingListId = widget.formData['packingListId'] as String?;

    if (packingListId == null) {
      setState(() {
        _errorMessage = 'No packing list ID found. Please complete previous steps first.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔮 [Step3] Generating suggestions for packingListId: $packingListId');

      final result = await _tripService.generateSuggestions(
        packingListId: packingListId,
        context: context,
      );

      print('✅ [Step3] Received ${result?.length ?? 0} suggestions');

      if (result != null) {
        final suggestions = result
            .map((json) => ItemTemplate.fromJson(json as Map<String, dynamic>))
            .toList();

        // Sort by priority (highest first)
        suggestions.sort((a, b) => b.priority.compareTo(a.priority));

        print('📋 [Step3] Suggestions breakdown:');
        for (var suggestion in suggestions) {
          print('   - ${suggestion.name} (${suggestion.category}) [Priority: ${suggestion.priority}, Qty: ${suggestion.defaultQuantity}, Icon: ${suggestion.icon}]');
        }

        // Initialize all items as unselected with their default quantities
        _selectedItems.clear();
        _itemQuantities.clear();
        for (var suggestion in suggestions) {
          _selectedItems[suggestion.id] = false;
          _itemQuantities[suggestion.id] = suggestion.defaultQuantity;
        }

        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to generate suggestions';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ [Step3] Error generating suggestions: $e');
      print('❌ [Step3] Stack trace: $stackTrace');

      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Packing Suggestions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Review and customize your personalized packing list',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),

          // Loading state
          if (_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48.0),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Generating personalized suggestions...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),

          // Error state
          if (_errorMessage != null && !_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

          // Success state - suggestions list
          if (_suggestions != null && !_isLoading) ...[
            // Summary text
            Text(
              'We found ${_suggestions!.length} items for your trip',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap items to adjust quantity or remove them',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),

            // Group items by category
            ..._buildCategorizedItems(),
          ],
        ],
      ),
    );
  }

  /// Build categorized list of items
  List<Widget> _buildCategorizedItems() {
    if (_suggestions == null || _suggestions!.isEmpty) {
      return [];
    }

    // Group items by category
    final Map<String, List<ItemTemplate>> categorizedItems = {};
    for (var item in _suggestions!) {
      if (!categorizedItems.containsKey(item.category)) {
        categorizedItems[item.category] = [];
      }
      categorizedItems[item.category]!.add(item);
    }

    // Build UI for each category
    final List<Widget> widgets = [];
    categorizedItems.forEach((category, items) {
      widgets.add(_buildCategorySection(category, items));
      widgets.add(const SizedBox(height: 24));
    });

    return widgets;
  }

  /// Build a category section with its items
  Widget _buildCategorySection(String category, List<ItemTemplate> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        Text(
          category.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 12),

        // Items in this category
        ...items.map((item) => _buildItemTile(item)),
      ],
    );
  }

  /// Build an individual item tile
  Widget _buildItemTile(ItemTemplate item) {
    final isSelected = _selectedItems[item.id] ?? false;
    final quantity = _itemQuantities[item.id] ?? item.defaultQuantity;

    return CheckboxTile(
      icon: _getIconData(item.icon),
      itemName: item.name,
      quantity: quantity,
      note: '', // Will be populated when user adds notes via edit dialog
      isSelected: isSelected,
      onToggle: () {
        setState(() {
          _selectedItems[item.id] = !isSelected;
        });
      },
      onEdit: () {
        // TODO: Open dialog to edit quantity and notes
        print('🔧 [Step3] Edit item: ${item.name} (id: ${item.id})');
      },
    );
  }


  /// Map icon name string to IconData
  IconData _getIconData(String iconName) {
    // Map common icon names to Material Icons
    final iconMap = {
      'luggage': Icons.luggage,
      'checkroom': Icons.checkroom,
      'local_laundry_service': Icons.local_laundry_service,
      'wc': Icons.wc,
      'clean_hands': Icons.clean_hands,
      'face': Icons.face,
      'health_and_safety': Icons.health_and_safety,
      'headphones': Icons.headphones,
      'phone_iphone': Icons.phone_iphone,
      'laptop': Icons.laptop,
      'camera_alt': Icons.camera_alt,
      'book': Icons.book,
      'sports': Icons.sports,
      'pool': Icons.pool,
      'hiking': Icons.hiking,
      'beach_access': Icons.beach_access,
      'ac_unit': Icons.ac_unit,
      'wb_sunny': Icons.wb_sunny,
      'umbrella': Icons.umbrella,
      'backpack': Icons.backpack,
      'shopping_bag': Icons.shopping_bag,
      'restaurant': Icons.restaurant,
      'local_drink': Icons.local_drink,
      'medication': Icons.medication,
      'vaccines': Icons.vaccines,
      'local_hospital': Icons.local_hospital,
      'power': Icons.power,
      'cable': Icons.cable,
      'vpn_key': Icons.vpn_key,
      'credit_card': Icons.credit_card,
      'attach_money': Icons.attach_money,
      'important_devices': Icons.important_devices,
      'flight': Icons.flight,
      'directions_car': Icons.directions_car,
      'description': Icons.description,
      'badge': Icons.badge,
      'map': Icons.map,
      'navigation': Icons.navigation,
      'toys': Icons.toys,
      'child_care': Icons.child_care,
      'baby_changing_station': Icons.baby_changing_station,
      'pets': Icons.pets,
      'watch': Icons.watch,
      'diamond': Icons.diamond,
      'glasses': Icons.remove_red_eye,
      'umbrella_outline': Icons.beach_access,
    };

    return iconMap[iconName] ?? Icons.category;
  }
}
