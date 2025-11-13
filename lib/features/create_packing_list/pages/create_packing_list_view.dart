import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:kaboodle_app/features/create_packing_list/widgets/step_1_general_info_body.dart';
import 'package:kaboodle_app/features/create_packing_list/widgets/step_2_details_body.dart';
import 'package:kaboodle_app/features/create_packing_list/widgets/step_3_generate_items_body.dart';
import 'package:kaboodle_app/features/create_packing_list/widgets/step_4_overview_body.dart';

class CreatePackingListView extends StatefulWidget {
  const CreatePackingListView({super.key});

  @override
  State<CreatePackingListView> createState() => _CreatePackingListViewState();
}

class _CreatePackingListViewState extends State<CreatePackingListView> {
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Form data that will be collected across steps
  final Map<String, dynamic> _formData = {};

  // Validation state for each step
  bool _isStep1Valid = false;

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _close() {
    context.pop();
  }

  bool _canProceedToNextStep() {
    if (_currentStep >= _totalSteps - 1) return false;

    // Step 1 validation
    if (_currentStep == 0) {
      return _isStep1Valid;
    }

    // For other steps, allow progression (validation will be added later)
    return true;
  }

  Widget _getStepBody() {
    switch (_currentStep) {
      case 0:
        return Step1GeneralInfoBody(
          formData: _formData,
          onDataChanged: (data) {
            setState(() {
              _formData.addAll(data);
            });
          },
          onValidationChanged: (isValid) {
            setState(() {
              _isStep1Valid = isValid;
            });
          },
        );
      case 1:
        return Step2DetailsBody(
          formData: _formData,
          onDataChanged: (data) {
            setState(() {
              _formData.addAll(data);
            });
          },
        );
      case 2:
        return Step3GenerateItemsBody(
          formData: _formData,
          onDataChanged: (data) {
            setState(() {
              _formData.addAll(data);
            });
          },
        );
      case 3:
        return Step4OverviewBody(
          formData: _formData,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _close,
        ),
        title: Text(
          'Create Packing List',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: StepProgressIndicator(
              totalSteps: _totalSteps,
              currentStep: _currentStep + 1,
              size: 8,
              padding: 4,
              selectedColor: Theme.of(context).colorScheme.primary,
              unselectedColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              roundedEdges: const Radius.circular(4),
            ),
          ),
          // Step content
          Expanded(
            child: _getStepBody(),
          ),
          // Navigation buttons
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: SafeArea(
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(
                            color: Colors.grey[300]!,
                          ),
                        ),
                        child: Text(
                          'Back',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: _currentStep == 0 ? 1 : 1,
                    child: ElevatedButton(
                      onPressed: _canProceedToNextStep() ? _nextStep : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Next',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
