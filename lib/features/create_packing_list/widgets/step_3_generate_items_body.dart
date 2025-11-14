import 'package:flutter/material.dart';
import 'package:kaboodle_app/models/item_template.dart';
import 'package:kaboodle_app/services/trip/trip_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final tripId = widget.formData['tripId'] as String?;

    if (tripId == null) {
      setState(() {
        _errorMessage = 'No trip ID found. Please complete previous steps first.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔮 [Step3] Generating suggestions for tripId: $tripId');

      final result = await _tripService.generateSuggestions(
        tripId: tripId,
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
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generate Items',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll create a personalized packing list for you',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),

          // Loading state
          if (_isLoading)
            Center(
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

          // Error state
          if (_errorMessage != null && !_isLoading)
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),

          // Success state (for now, just showing count)
          if (_suggestions != null && !_isLoading)
            Text(
              'Generated ${_suggestions!.length} suggestions!\nCheck console for details.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
        ],
      ),
    );
  }
}
