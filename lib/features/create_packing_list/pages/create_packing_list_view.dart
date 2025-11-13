import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:toastification/toastification.dart';
import 'package:kaboodle_app/features/create_packing_list/widgets/step_1_general_info_body.dart';
import 'package:kaboodle_app/features/create_packing_list/widgets/step_2_details_body.dart';
import 'package:kaboodle_app/features/create_packing_list/widgets/step_3_generate_items_body.dart';
import 'package:kaboodle_app/features/create_packing_list/widgets/step_4_overview_body.dart';
import 'package:kaboodle_app/services/trip/trip_service.dart';

class CreatePackingListView extends StatefulWidget {
  const CreatePackingListView({super.key});

  @override
  State<CreatePackingListView> createState() => _CreatePackingListViewState();
}

class _CreatePackingListViewState extends State<CreatePackingListView> {
  int _currentStep = 0;
  final int _totalSteps = 4;
  final TripService _tripService = TripService();

  // Form data that will be collected across steps
  final Map<String, dynamic> _formData = {
    'colorTag': 'grey', // Default color tag
  };

  // Validation state for each step
  bool _isStep1Valid = false;

  // Loading state for API calls
  bool _isLoading = false;

  Future<void> _nextStep() async {
    // Step 1: Save trip data to backend before proceeding
    if (_currentStep == 0) {
      await _saveStep1Data();
    }

    // Proceed to next step
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  Future<void> _saveStep1Data() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tripId = _formData['tripId'] as String?;
      final isUpdate = tripId != null;

      print('📝 [SaveStep1] Starting save...');
      print('📝 [SaveStep1] isUpdate: $isUpdate');
      print('📝 [SaveStep1] tripId: $tripId');
      print('📝 [SaveStep1] Form data: ${_formData.toString()}');

      // Upsert trip (create if no ID, update if ID exists)
      final result = await _tripService.upsertTrip(
        id: tripId,
        name: _formData['name'] as String,
        startDate: _formData['startDate'] as DateTime,
        endDate: _formData['endDate'] as DateTime,
        description: _formData['description'] as String?,
        destination: _formData['destination'] as String?,
        colorTag: _formData['colorTag'] as String?,
        stepCompleted: 1,
        context: context,
      );

      print('✅ [SaveStep1] Result received: ${result != null}');

      if (result != null && mounted) {
        // Store trip ID (always present)
        setState(() {
          _formData['tripId'] = result['trip'].id;

          // Store packing list ID only if present (only on create)
          if (result['packingList'] != null) {
            _formData['packingListId'] = result['packingList'].id;
          }
        });

        print('✅ [SaveStep1] Stored tripId: ${result['trip'].id}');
        if (result['packingList'] != null) {
          print('✅ [SaveStep1] Stored packingListId: ${result['packingList'].id}');
        }

        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.minimal,
          title: Text(isUpdate ? 'Trip updated successfully!' : 'Trip created successfully!'),
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.topCenter,
        );
      }
    } catch (e, stackTrace) {
      print('❌ [SaveStep1] Error occurred: $e');
      print('❌ [SaveStep1] Stack trace: $stackTrace');

      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.minimal,
          title: const Text('Failed to save trip'),
          description: Text(e.toString()),
          autoCloseDuration: const Duration(seconds: 5),
          alignment: Alignment.topCenter,
        );
      }
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
                      onPressed: _canProceedToNextStep() && !_isLoading ? _nextStep : null,
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
