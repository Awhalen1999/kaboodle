import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kaboodle/services/data/packing_list_cache.dart';
import 'package:kaboodle/services/data/firestore.dart';
import 'package:kaboodle/features/createPackingList/widgets/step_one_content.dart';
import 'package:kaboodle/shared/widgets/custom_button.dart';

class EditStepOneBody extends StatefulWidget {
  final String listId;
  const EditStepOneBody({super.key, required this.listId});

  @override
  State<EditStepOneBody> createState() => _EditStepOneBodyState();
}

class _EditStepOneBodyState extends State<EditStepOneBody> {
  bool _isSaving = false;
  String _title = '';
  String _description = '';
  Color _listColor = Colors.grey;
  DateTime? _travelDate;

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
        _title = listData['title'] ?? '';
        _description = listData['description'] ?? '';
        _listColor = Color(listData['listColor'] ?? Colors.grey.shade500.value);

        final travelDateString = listData['travelDate'] as String?;
        _travelDate = travelDateString != null
            ? DateTime.tryParse(travelDateString)
            : null;
      });
    }
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
        'title': _title,
        'description': _description,
        'listColor': _listColor.value,
        'travelDate': _travelDate?.toIso8601String(),
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
          content: const Text('Trip details updated successfully!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isSaving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating trip details: $e'),
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
                child: StepOneContent(
                  title: _title,
                  description: _description,
                  listColor: _listColor,
                  travelDate: _travelDate,
                  onTitleChanged: (value) => setState(() => _title = value),
                  onDescriptionChanged: (value) =>
                      setState(() => _description = value),
                  onColorChanged: (value) => setState(() => _listColor = value),
                  onDateChanged: (value) => setState(() => _travelDate = value),
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
