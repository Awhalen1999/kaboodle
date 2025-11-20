import 'package:flutter/material.dart';
import 'package:kaboodle_app/services/trip/trip_service.dart';

class UsePackingListBody extends StatefulWidget {
  final String packingListId;
  final String packingListName;

  const UsePackingListBody({
    super.key,
    required this.packingListId,
    required this.packingListName,
  });

  @override
  State<UsePackingListBody> createState() => _UsePackingListBodyState();
}

class _UsePackingListBodyState extends State<UsePackingListBody> {
  final TripService _tripService = TripService();
  Map<String, dynamic>? _itemsData;
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
          _itemsData = result;
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip name
          Text(
            widget.packingListName,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          // Items section
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(
              child: Column(
                children: [
                  Text('Error loading items: $_error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadItems,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (_itemsData != null)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Packing Items',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    // Display raw items data temporarily
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: Text(
                        _itemsData.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            const Center(child: Text('No items found')),
        ],
      ),
    );
  }
}
