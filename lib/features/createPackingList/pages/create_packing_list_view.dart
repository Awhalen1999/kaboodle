import 'package:kaboodle/features/createPackingList/widgets/create_step_one_body.dart';
import 'package:kaboodle/features/createPackingList/widgets/create_step_two_body.dart';
import 'package:kaboodle/features/createPackingList/widgets/create_step_three_body.dart';
import 'package:kaboodle/features/createPackingList/widgets/create_step_four_body.dart';
import 'package:kaboodle/shared/widgets/custom_button.dart';
import 'package:kaboodle/services/data/firestore.dart';
import 'package:kaboodle/services/data/packing_list_cache.dart';
import 'package:flutter/material.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:kaboodle/features/createPackingList/provider/create_packing_list_provider.dart';
import 'package:kaboodle/features/createPackingList/provider/custom_items_provider.dart';

class CreatePackingListView extends StatefulWidget {
  const CreatePackingListView({super.key});

  @override
  State<CreatePackingListView> createState() => _CreatePackingListViewState();
}

class _CreatePackingListViewState extends State<CreatePackingListView> {
  int _currentStep = 1;
  bool _isSaving = false;
  bool _isEditingStep = false;

  String _getAppBarTitle() {
    switch (_currentStep) {
      case 1:
        return 'Add List';
      case 2:
        return 'List Details';
      case 3:
        return 'Choose Items';
      case 4:
      default:
        return 'Overview List';
    }
  }

  bool _canProceedToNextStep() {
    if (_currentStep == 1) {
      final title = context.read<CreatePackingListProvider>().title;
      if (title.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter a title for your list'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return false;
      }
    }
    return true;
  }

  void _nextStep() async {
    if (!_canProceedToNextStep()) return;

    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      // Final step - save to Firestore
      setState(() => _isSaving = true);

      try {
        final provider = context.read<CreatePackingListProvider>();
        final customItemsProvider = context.read<CustomItemsProvider>();
        final packingListData =
            provider.getPackingListData(customItemsProvider);

        // Save to Firestore
        final firestoreService = FirestoreService();
        final documentId =
            await firestoreService.savePackingList(packingListData);

        // Add to cache
        final cache = context.read<PackingListCache>();
        final newListData = {
          'id': documentId,
          ...packingListData,
        };
        cache.addList(newListData);

        // Success - reset providers and navigate back
        if (context.mounted) {
          // Reset the provider data for next use
          provider.reset();
          customItemsProvider.reset();

          // Navigate back to the previous screen
          Navigator.of(context).pop();

          // Show success message after navigation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Packing list saved successfully!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Error handling - reset loading state
        setState(() => _isSaving = false);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving packing list: $e'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        print('Error saving packing list: $e');
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  String _getButtonText() {
    if (_isSaving) return 'Saving...';
    switch (_currentStep) {
      case 2:
        return 'Build List';
      case 3:
        return 'Review List';
      case 4:
        return 'Finish';
      default:
        return 'Next';
    }
  }

  void _startEditMode(int step) {
    setState(() {
      _currentStep = step;
      _isEditingStep = true;
    });
  }

  void _finishEditMode() {
    setState(() {
      _isEditingStep = false;
      _currentStep = 4; // Go back to the overview step
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: _previousStep,
        ),
        title: Text(_getAppBarTitle()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.close_rounded),
              iconSize: 28,
              color: Theme.of(context).colorScheme.onSurface,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              StepProgressIndicator(
                totalSteps: 4,
                currentStep: _currentStep,
                size: 8,
                unselectedColor: Colors.grey.shade300,
                selectedGradientColor: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.primary,
                  ],
                ),
                roundedEdges: const Radius.circular(10),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildStepContent(_currentStep),
                ),
              ),
              if (_isEditingStep)
                CustomButton(
                  buttonText: 'OK',
                  onPressed: _finishEditMode,
                  textColor: Theme.of(context).colorScheme.onPrimary,
                  buttonColor: Theme.of(context).colorScheme.primary,
                  isLoading: false,
                  borderRadius: 12,
                )
              else
                CustomButton(
                  buttonText: _getButtonText(),
                  onPressed: _isSaving ? null : _nextStep,
                  textColor: Theme.of(context).colorScheme.onPrimary,
                  buttonColor: Theme.of(context).colorScheme.primary,
                  isLoading: false,
                  borderRadius: 12,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 1:
        return const MainStepOneBody();
      case 2:
        return const MainStepTwoBody();
      case 3:
        return const MainStepThreeBody();
      case 4:
      default:
        return MainStepFourBody(
          onEditTripDetails: () => _startEditMode(1),
          onEditTripRequirements: () => _startEditMode(2),
          onEditPackingList: () => _startEditMode(3),
        );
    }
  }
}
