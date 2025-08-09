import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kaboodle/services/data/packing_list_cache.dart';
import 'package:kaboodle/services/data/firestore.dart';
import 'package:kaboodle/features/createPackingList/widgets/step_three_content.dart';
import 'package:kaboodle/features/createPackingList/provider/create_packing_list_provider.dart';
import 'package:kaboodle/shared/widgets/custom_button.dart';

class EditStepThreeBody extends StatefulWidget {
  final String listId;
  const EditStepThreeBody({super.key, required this.listId});

  @override
  State<EditStepThreeBody> createState() => _EditStepThreeBodyState();
}

class _EditStepThreeBodyState extends State<EditStepThreeBody> {
  bool _isSaving = false;
  String? _gender;
  String? _tripPurpose;
  String? _weatherCondition;
  String? _accommodation;
  List<String> _selectedSections = [];
  double _tripLength = 1.0;
  final Map<String, PackingListItem> _existingItems = {};

  @override
  void initState() {
    super.initState();
    _loadDataFromCache();
  }

  void _loadDataFromCache() {
    final cache = context.read<PackingListCache>();
    final listData = cache.getListById(widget.listId);
    if (listData != null) {
      setState(() {
        _gender = listData['gender'] as String?;
        _tripPurpose = listData['tripPurpose'] as String?;
        _weatherCondition = listData['weatherCondition'] as String?;
        _accommodation = listData['accommodation'] as String?;
        _selectedSections =
            List<String>.from(listData['selectedSections'] ?? []);
        _tripLength = (listData['tripLength'] as num?)?.toDouble() ?? 1.0;

        // Load existing items
        _existingItems.clear();
        final itemsList = listData['items'] as List? ?? [];
        for (final itemData in itemsList) {
          final item =
              PackingListItem.fromMap(itemData as Map<String, dynamic>);
          _existingItems[item.id] = item;
        }
      });
    }
  }

  void _onItemAdded(PackingListItem item) {
    setState(() {
      _existingItems[item.id] = item;
    });
  }

  void _onItemRemoved(String itemId) {
    setState(() {
      // Mark the item as unchecked but keep it in the list
      // This matches the create flow behavior where items persist
      final item = _existingItems[itemId];
      if (item != null) {
        _existingItems[itemId] = item.copyWith(isChecked: false);
      }
    });
  }

  void _onItemUpdated(PackingListItem item) {
    setState(() {
      _existingItems[item.id] = item;
    });
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);

    try {
      final firestoreService = FirestoreService();
      final cache = context.read<PackingListCache>();

      // Get current list data
      final currentData = cache.getListById(widget.listId);
      if (currentData == null) throw Exception('List not found');

      // Convert items to the format expected by Firestore
      // Only include checked items (consistent with create flow)
      final itemsList = _existingItems.values
          .where((item) => item.isChecked)
          .map((item) => item.toMap())
          .toList();

      // Update with new items and timestamp
      final updatedData = {
        ...currentData,
        'items': itemsList,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Save to Firestore
      await firestoreService.updatePackingList(widget.listId, updatedData);

      // Update cache
      cache.updateList(widget.listId, updatedData);

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Packing list updated successfully!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isSaving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating packing list: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PackingListCache>(
      builder: (context, cache, child) {
        if (cache.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cache.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading packing list',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  cache.error!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final listData = cache.getListById(widget.listId);
        if (listData == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Packing list not found',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'The packing list you\'re looking for doesn\'t exist or has been deleted.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: StepThreeContent(
                    gender: _gender,
                    tripPurpose: _tripPurpose,
                    weatherCondition: _weatherCondition,
                    accommodation: _accommodation,
                    selectedSections: _selectedSections,
                    tripLength: _tripLength,
                    existingItems: _existingItems,
                    onItemAdded: _onItemAdded,
                    onItemRemoved: _onItemRemoved,
                    onItemUpdated: _onItemUpdated,
                  ),
                ),
              ),
              CustomButton(
                buttonText: 'Save Changes',
                onPressed: _isSaving ? null : _saveChanges,
                textColor: Theme.of(context).colorScheme.onPrimary,
                buttonColor: Theme.of(context).colorScheme.primary,
                isLoading: _isSaving,
              ),
            ],
          ),
        );
      },
    );
  }
}
