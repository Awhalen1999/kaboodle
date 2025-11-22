import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:kaboodle_app/models/item_template.dart';
import 'package:kaboodle_app/services/trip/trip_service.dart';
import 'package:kaboodle_app/features/create_packing_list/widgets/checkbox_tile.dart';
import 'package:kaboodle_app/features/create_packing_list/widgets/edit_item_sheet.dart';
import 'package:kaboodle_app/features/create_packing_list/widgets/add_custom_item_sheet.dart';
import 'package:kaboodle_app/shared/utils/icon_utils.dart';
import 'package:kaboodle_app/shared/constants/category_constants.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

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

  // Track selected items, their quantities, and notes
  final Map<String, bool> _selectedItems = {};
  final Map<String, int> _itemQuantities = {};
  final Map<String, String> _itemNotes = {};

  // Track expansion state for each category
  final Map<String, bool> _categoryExpanded = {};

  // Track custom items by category
  // Each item: {id, name, quantity, note}
  final Map<String, List<Map<String, dynamic>>> _customItems = {};

  // Helper to get trip length in days
  int? get _tripLength {
    final startDate = widget.formData['startDate'] as DateTime?;
    final endDate = widget.formData['endDate'] as DateTime?;
    if (startDate != null && endDate != null) {
      return endDate.difference(startDate).inDays;
    }
    return null;
  }

  // Helper to get destination
  String? get _destination {
    final dest = widget.formData['destination'] as String?;
    return (dest != null && dest.isNotEmpty) ? dest : null;
  }

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  /// Show error toast notification
  void _showErrorToast(String message) {
    if (!mounted) return;

    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.minimal,
      title: const Text('Error'),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.bottomCenter,
    );
  }

  /// Notify parent of data changes (selected items and custom items)
  void _notifyDataChanged() {
    widget.onDataChanged({
      'selectedItems': _selectedItems,
      'itemQuantities': _itemQuantities,
      'itemNotes': _itemNotes,
      'customItems': _customItems,
      'suggestions': _suggestions, // Include suggestions for name matching
    });
  }

  Future<void> _loadSuggestions() async {
    final packingListId = widget.formData['packingListId'] as String?;

    if (packingListId == null) {
      setState(() {
        _errorMessage =
            'No packing list ID found. Please complete previous steps first.';
      });
      _showErrorToast('Please complete Step 1 first');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('💡 Generating packing suggestions...');

      // Load both suggestions and existing items in parallel
      final suggestionsFuture = _tripService.generateSuggestions(
        packingListId: packingListId,
        context: context,
      );
      final itemsFuture = _tripService.getPackingListItems(
        packingListId: packingListId,
        context: context,
      );

      final results = await Future.wait([suggestionsFuture, itemsFuture]);
      final suggestionsResult = results[0] as List?;
      final itemsResult = results[1] as Map<String, dynamic>?;

      print('✅ Generated ${suggestionsResult?.length ?? 0} suggestions');

      if (suggestionsResult != null) {
        final suggestions = suggestionsResult
            .map((json) => ItemTemplate.fromJson(json as Map<String, dynamic>))
            .toList();

        // Sort by priority (highest first)
        suggestions.sort((a, b) => b.priority.compareTo(a.priority));

        // Initialize all items as unselected with their calculated quantities
        _selectedItems.clear();
        _itemQuantities.clear();
        _itemNotes.clear();
        _customItems.clear();
        for (var suggestion in suggestions) {
          _selectedItems[suggestion.id] = false;
          _itemQuantities[suggestion.id] = suggestion.quantity;
        }

        // Pre-populate selections from existing items
        if (itemsResult != null) {
          final existingItems = itemsResult['items'] as List;

          for (var item in existingItems) {
            if (item.isCustom) {
              // It's a custom item - add to custom items list
              final category = item.category ?? 'Miscellaneous';
              final customId = 'custom_${item.id}';

              _customItems[category] ??= [];
              _customItems[category]!.add({
                'id': customId,
                'name': item.name,
                'quantity': item.quantity,
                'note': item.notes ?? '',
              });

              // Mark as selected
              _selectedItems[customId] = true;
              _itemQuantities[customId] = item.quantity;
              _itemNotes[customId] = item.notes ?? '';

              print('✨ [Step3] Restored custom item: ${item.name}');
            } else {
              // It's a template item - find matching suggestion by name
              final matchingSuggestion = suggestions.where(
                (s) => s.name.toLowerCase() == item.name.toLowerCase(),
              );

              if (matchingSuggestion.isNotEmpty) {
                final suggestion = matchingSuggestion.first;
                _selectedItems[suggestion.id] = true;
                _itemQuantities[suggestion.id] = item.quantity;
                if (item.notes != null && item.notes!.isNotEmpty) {
                  _itemNotes[suggestion.id] = item.notes!;
                }
              }
            }
          }
        }

        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });

        // Notify parent of initial data
        _notifyDataChanged();
      } else {
        final errorMsg = 'Failed to generate suggestions';
        setState(() {
          _errorMessage = errorMsg;
          _isLoading = false;
        });
        _showErrorToast(errorMsg);
      }
    } catch (e, stackTrace) {
      final errorMsg = 'Error generating suggestions: ${e.toString()}';
      _showErrorToast(errorMsg);
      print('❌ [Step3] Error: $e');
      print('❌ Stack trace: $stackTrace');

      setState(() {
        _errorMessage = errorMsg;
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

          // Loading state
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 48.0),
                child: CircularProgressIndicator(),
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
              'We found ${_suggestions!.length} items for your ${_tripLength != null ? '$_tripLength day trip' : 'trip'}${_destination != null ? ' to $_destination' : ''}. Tap items to add them and hit edit to adjust quantity or add notes.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
  Widget _buildCategorySection(String category, List<ItemTemplate> items) {
    // Initialize expansion state if not already set
    _categoryExpanded[category] ??= true;
    final isExpanded = _categoryExpanded[category]!;

    // Get custom items for this category
    final customItems = _customItems[category] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header with clickable arrow and add button
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
            // Non-clickable category title
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
            // Add custom item button
            InkWell(
              onTap: () => _showAddCustomItemSheet(category),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.add,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        // Collapsible items section
        if (isExpanded) ...[
          const SizedBox(height: 12),
          // Show custom items first
          ...customItems
              .map((customItem) => _buildCustomItemTile(customItem, category)),
          // Then show suggestions
          ...items.map((item) => _buildItemTile(item)),
        ],
      ],
    );
  }

  /// Build an individual item tile
  Widget _buildItemTile(ItemTemplate item) {
    final isSelected = _selectedItems[item.id] ?? false;
    final quantity = _itemQuantities[item.id] ?? item.defaultQuantity;
    final note = _itemNotes[item.id] ?? '';

    return CheckboxTile(
      icon: IconUtils.getIconData(item.icon),
      itemName: item.name,
      quantity: quantity,
      note: note,
      isSelected: isSelected,
      onToggle: () {
        setState(() {
          _selectedItems[item.id] = !isSelected;
        });
        _notifyDataChanged();
      },
      onEdit: () {
        _showEditItemSheet(item);
      },
    );
  }

  /// Show bottom sheet to edit item quantity and notes
  void _showEditItemSheet(ItemTemplate item) {
    final currentQuantity = _itemQuantities[item.id] ?? item.quantity;
    final currentNote = _itemNotes[item.id] ?? '';

    showCupertinoModalBottomSheet(
      context: context,
      expand: false,
      builder: (context) => EditItemSheet(
        itemName: item.name,
        currentQuantity: currentQuantity,
        currentNote: currentNote,
        onSave: (quantity, note) {
          setState(() {
            _itemQuantities[item.id] = quantity;
            _itemNotes[item.id] = note;
          });
          _notifyDataChanged();
          print('💾 [Step3] Saved ${item.name}: Qty=$quantity, Note="$note"');
        },
      ),
    );
  }

  /// Show bottom sheet to add a custom item
  void _showAddCustomItemSheet(String category) {
    showCupertinoModalBottomSheet(
      context: context,
      expand: false,
      builder: (context) => AddCustomItemSheet(
        category: category,
        onAdd: (name, quantity, note) {
          setState(() {
            // Generate a unique ID using timestamp
            final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';

            // Initialize custom items list for this category if needed
            _customItems[category] ??= [];

            // Add the custom item
            _customItems[category]!.add({
              'id': id,
              'name': name,
              'quantity': quantity,
              'note': note,
            });

            // Mark as selected by default
            _selectedItems[id] = true;
            _itemQuantities[id] = quantity;
            _itemNotes[id] = note;
          });
          _notifyDataChanged();
        },
      ),
    );
  }

  /// Build a custom item tile
  Widget _buildCustomItemTile(
      Map<String, dynamic> customItem, String category) {
    final id = customItem['id'] as String;
    final name = customItem['name'] as String;
    final isSelected = _selectedItems[id] ?? true; // Default to selected
    final quantity = _itemQuantities[id] ?? customItem['quantity'] as int;
    final note = _itemNotes[id] ?? customItem['note'] as String;

    return CheckboxTile(
      icon: Icons.bookmark_border_rounded, // Custom item indicator icon
      itemName: name,
      quantity: quantity,
      note: note,
      isSelected: isSelected,
      onToggle: () {
        setState(() {
          _selectedItems[id] = !isSelected;
        });
        _notifyDataChanged();
      },
      onEdit: () {
        // Edit custom item
        showCupertinoModalBottomSheet(
          context: context,
          expand: false,
          builder: (context) => EditItemSheet(
            itemName: name,
            currentQuantity: quantity,
            currentNote: note,
            onSave: (newQuantity, newNote) {
              setState(() {
                _itemQuantities[id] = newQuantity;
                _itemNotes[id] = newNote;
                // Update in custom items list
                customItem['quantity'] = newQuantity;
                customItem['note'] = newNote;
              });
              _notifyDataChanged();
            },
          ),
        );
      },
    );
  }
}
