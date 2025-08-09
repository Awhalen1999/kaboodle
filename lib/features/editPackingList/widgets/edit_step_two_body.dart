import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kaboodle/services/data/packing_list_cache.dart';
import 'package:kaboodle/services/data/firestore.dart';
import 'package:kaboodle/features/createPackingList/widgets/step_two_content.dart';
import 'package:kaboodle/shared/widgets/custom_button.dart';

class EditStepTwoBody extends StatefulWidget {
  final String listId;
  const EditStepTwoBody({super.key, required this.listId});

  @override
  State<EditStepTwoBody> createState() => _EditStepTwoBodyState();
}

class _EditStepTwoBodyState extends State<EditStepTwoBody> {
  bool _isSaving = false;
  String? _gender;
  String? _tripPurpose;
  String? _weatherCondition;
  double _tripLength = 1.0;
  String? _accommodation;
  List<String> _itemsActivities = [];

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
        _tripLength = (listData['tripLength'] as num?)?.toDouble() ?? 1.0;
        _accommodation = listData['accommodation'] as String?;
        _itemsActivities =
            List<String>.from(listData['selectedSections'] ?? []);
      });
    }
  }

  void _toggleItemActivity(String itemId) {
    setState(() {
      if (_itemsActivities.contains(itemId)) {
        _itemsActivities.remove(itemId);
      } else {
        _itemsActivities.add(itemId);
      }
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

      // Update with new values
      final updatedData = {
        ...currentData,
        'gender': _gender,
        'tripPurpose': _tripPurpose,
        'weatherCondition': _weatherCondition,
        'tripLength': _tripLength,
        'accommodation': _accommodation,
        'selectedSections': _itemsActivities,
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
          content: const Text('Trip requirements updated successfully!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isSaving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating trip requirements: $e'),
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
                child: StepTwoContent(
                  gender: _gender,
                  tripPurpose: _tripPurpose,
                  weatherCondition: _weatherCondition,
                  tripLength: _tripLength,
                  accommodation: _accommodation,
                  selectedItems: _itemsActivities,
                  onGenderChanged: (value) => setState(() => _gender = value),
                  onTripPurposeChanged: (value) =>
                      setState(() => _tripPurpose = value),
                  onWeatherConditionChanged: (value) =>
                      setState(() => _weatherCondition = value),
                  onTripLengthChanged: (value) =>
                      setState(() => _tripLength = value),
                  onAccommodationChanged: (value) =>
                      setState(() => _accommodation = value),
                  onItemToggled: _toggleItemActivity,
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
