import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:kaboodle_app/features/create_packing_list/widgets/step_1_general_info_body.dart';
import 'package:kaboodle_app/features/create_packing_list/widgets/step_2_details_body.dart';
import 'package:kaboodle_app/features/create_packing_list/widgets/step_3_generate_items_body.dart';
import 'package:kaboodle_app/features/create_packing_list/widgets/step_4_overview_body.dart';
import 'package:kaboodle_app/services/trip/trip_service.dart';
import 'package:kaboodle_app/providers/trips_provider.dart';

class CreatePackingListView extends ConsumerStatefulWidget {
  const CreatePackingListView({super.key});

  @override
  ConsumerState<CreatePackingListView> createState() =>
      _CreatePackingListViewState();
}

class _CreatePackingListViewState extends ConsumerState<CreatePackingListView> {
  int _currentStep = 0;
  final int _totalSteps = 4;
  final TripService _tripService = TripService();

  // Form data that will be collected across steps
  final Map<String, dynamic> _formData = {
    'colorTag': 'grey', // Default color tag
  };

  // Validation state for each step
  bool _isStep1Valid = false;
  bool _isStep2Valid = true; // Optional step, always valid
  bool _isStep3Valid = true; // Will validate later
  bool _isStep4Valid = true; // Overview, always valid

  // Loading state for API calls
  bool _isLoading = false;

  Future<void> _nextStep() async {
    // Save current step data to backend before proceeding
    await _saveCurrentStepData();

    // Proceed to next step if save was successful
    if (_currentStep < _totalSteps - 1 && mounted) {
      setState(() {
        _currentStep++;
      });
    }
  }

  Future<void> _saveCurrentStepData() async {
    switch (_currentStep) {
      case 0:
        await _saveStepData(
          stepNumber: 1,
          requiredFields: ['name', 'startDate', 'endDate'],
        );
        break;
      case 1:
        await _saveStepData(
          stepNumber: 2,
          requiredFields: [],
        );
        break;
      case 2:
        await _saveStepData(
          stepNumber: 3,
          requiredFields: [],
        );
        break;
      case 3:
        // Final step - will handle submission differently
        break;
    }
  }

  Future<void> _saveStepData({
    required int stepNumber,
    required List<String> requiredFields,
  }) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final packingListId = _formData['packingListId'] as String?;

      print('📝 [SaveStep$stepNumber] Starting save...');
      print('📝 [SaveStep$stepNumber] packingListId: $packingListId');
      print('📝 [SaveStep$stepNumber] Form data: ${_formData.toString()}');

      // Convert weather and activities lists properly
      final weatherList = _formData['weather'] as List<dynamic>?;
      final activitiesList = _formData['activities'] as List<dynamic>?;

      final result = await _tripService.upsertPackingList(
        id: packingListId,
        name: _formData['name'] as String,
        startDate: _formData['startDate'] as DateTime,
        endDate: _formData['endDate'] as DateTime,
        description: _formData['description'] as String?,
        destination: _formData['destination'] as String?,
        colorTag: _formData['colorTag'] as String?,
        gender: _formData['gender'] as String?,
        weather: weatherList?.cast<String>(),
        purpose: _formData['purpose'] as String?,
        accommodations: _formData['accommodations'] as String?,
        activities: activitiesList?.cast<String>(),
        stepCompleted: stepNumber,
        context: context,
      );

      if (result != null && mounted) {
        // Store the packing list ID for subsequent saves
        setState(() {
          _formData['packingListId'] = result.id;
        });

        // Update the provider with the new/updated packing list
        // If packingListId was null, it's a new list - add it
        // If packingListId was not null, it's an update - update it
        final wasNewList = packingListId == null;
        if (wasNewList) {
          ref.read(packingListsProvider.notifier).addPackingList(result);
        } else {
          ref.read(packingListsProvider.notifier).updatePackingList(result);
        }
      }
    } catch (e, stackTrace) {
      print('❌ [SaveStep$stepNumber] Error: $e');
      print('❌ [SaveStep$stepNumber] Stack trace: $stackTrace');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

    switch (_currentStep) {
      case 0:
        return _isStep1Valid;
      case 1:
        return _isStep2Valid;
      case 2:
        return _isStep3Valid;
      case 3:
        return _isStep4Valid;
      default:
        return false;
    }
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
                      onPressed: _canProceedToNextStep() && !_isLoading
                          ? _nextStep
                          : null,
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
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : Text(
                              'Next',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
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
