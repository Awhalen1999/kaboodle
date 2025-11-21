import 'package:flutter/material.dart';
import 'package:kaboodle_app/services/trip/trip_service.dart';
import 'package:kaboodle_app/models/packing_item.dart';

class UsePackingListBody extends StatefulWidget {
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
  State<UsePackingListBody> createState() => _UsePackingListBodyState();
}

class _UsePackingListBodyState extends State<UsePackingListBody> {
  final TripService _tripService = TripService();
  List<PackingItem>? _items;
  PackingListStats? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _tripService.getPackingListItems(
        packingListId: widget.packingListId,
      );

      if (mounted) {
        setState(() {
          if (result != null) {
            _items = result['items'] as List<PackingItem>;
            _stats = result['stats'] as PackingListStats;
            // Notify parent of stats update
            widget.onStatsUpdated?.call(_stats!);
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleItemPacked(PackingItem item) async {
    final newPackedStatus = !item.isPacked;

    try {
      final updatedItem = await _tripService.updateItem(
        itemId: item.id,
        isPacked: newPackedStatus,
        context: context,
      );

      if (updatedItem != null && mounted) {
        // Update local state
        setState(() {
          final index = _items!.indexWhere((i) => i.id == item.id);
          if (index != -1) {
            _items![index] = updatedItem;
          }

          // Recalculate stats
          final packedCount = _items!.where((i) => i.isPacked).length;
          _stats = PackingListStats(
            total: _items!.length,
            packed: packedCount,
            remaining: _items!.length - packedCount,
          );

          // Notify parent of stats update
          widget.onStatsUpdated?.call(_stats!);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update item: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip name
          Text(
            widget.packingListName,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          // Items section
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error loading items: $_error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadItems,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (_items != null && _items!.isNotEmpty)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Packing Items',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    // Display items
                    ..._items!.map((item) => _buildItemTile(item)),
                  ],
                ),
              ),
            )
          else
            const Expanded(
              child: Center(child: Text('No items found')),
            ),
        ],
      ),
    );
  }

  Widget _buildItemTile(PackingItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: item.isPacked,
        onChanged: (_) => _toggleItemPacked(item),
        title: Text(
          item.name,
          style: TextStyle(
            decoration: item.isPacked
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: item.isPacked
                ? colorScheme.onSurface.withValues(alpha: 0.6)
                : colorScheme.onSurface,
          ),
        ),
        subtitle: item.notes != null && item.notes!.isNotEmpty
            ? Text(item.notes!)
            : null,
        secondary: item.quantity > 1
            ? Chip(
                label: Text('x${item.quantity}'),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )
            : null,
      ),
    );
  }
}
