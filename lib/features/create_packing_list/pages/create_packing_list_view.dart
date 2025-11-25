import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:toastification/toastification.dart';
import 'package:kaboodle_app/features/create_packing_list/widgets/step_1_general_info_body.dart';
import 'package:kaboodle_app/features/create_packing_list/widgets/step_2_details_body.dart';
import 'package:kaboodle_app/features/create_packing_list/widgets/step_3_generate_items_body.dart';
import 'package:kaboodle_app/features/create_packing_list/widgets/step_4_overview_body.dart';
import 'package:kaboodle_app/services/trip/trip_service.dart';
import 'package:kaboodle_app/providers/trips_provider.dart';

class CreatePackingListView extends ConsumerStatefulWidget {
  final String? packingListId;
  final int? initialStep;

  const CreatePackingListView({
    super.key,
    this.packingListId,
    this.initialStep,
  });

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

  // Edit mode state
  bool _isEditMode = false;

  // Loading state for initial data
  bool _isLoadingInitialData = false;

  @override
  void initState() {
    super.initState();
    // Load existing packing list data if ID is provided
    if (widget.packingListId != null) {
      _loadExistingPackingList();
    }
    // Set initial step if provided
    if (widget.initialStep != null) {
      _currentStep = widget.initialStep!;
    }
  }

  Future<void> _loadExistingPackingList() async {
    if (widget.packingListId == null) return;

    setState(() {
      _isLoadingInitialData = true;
    });

    try {
      // Get packing list from provider
      final packingListsAsync = ref.read(packingListsProvider);

      packingListsAsync.whenData((packingLists) {
        final packingList = packingLists.firstWhere(
          (pl) => pl.id == widget.packingListId,
          orElse: () => throw Exception('Packing list not found'),
        );

        // Determine if this is editing (complete list) or continuing (incomplete list)
        final isCompleteList = packingList.stepCompleted >= 4;

        // Populate form data with existing values
        setState(() {
          _formData['packingListId'] = packingList.id;
          _formData['name'] = packingList.name;
          _formData['description'] = packingList.description;
          _formData['destination'] = packingList.destination;
          _formData['startDate'] = packingList.startDate;
          _formData['endDate'] = packingList.endDate;
          _formData['colorTag'] = packingList.colorTag ?? 'grey';
          _formData['gender'] = packingList.gender;
          _formData['weather'] = packingList.weather;
          _formData['purpose'] = packingList.purpose;
          _formData['accommodations'] = packingList.accommodations;
          _formData['activities'] = packingList.activities;
          _formData['currentStepCompleted'] = packingList.stepCompleted;

          // Only set edit mode if the list is complete
          // If incomplete, we're continuing the creation process
          _isEditMode = isCompleteList;

          // Mark step 1 as valid since we have existing data
          _isStep1Valid = true;
        });

        if (isCompleteList) {
          debugPrint('✏️ Editing complete packing list: ${packingList.name}');
        } else {
          debugPrint(
              '▶️ Continuing incomplete packing list: ${packingList.name} (step ${packingList.stepCompleted}/4)');
        }
      });
    } catch (e) {
      debugPrint('❌ Error loading packing list: $e');
      _showErrorToast('Failed to load packing list data');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingInitialData = false;
        });
      }
    }
  }

  /// Show error toast notification
  void _showErrorToast(String message) {
    if (!mounted) return;

    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.minimal,
      title: const Text('Error'),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.bottomCenter,
    );
  }

  /// Revalidate current step (used when returning to a step)
  void _revalidateCurrentStep() {
    switch (_currentStep) {
      case 0:
        // Step 1 validation will be triggered by the widget itself
        break;
      case 1:
        // Step 2 is always valid (optional)
        break;
      case 2:
        // Step 3 is always valid
        break;
      case 3:
        // Step 4 is always valid
        break;
    }
  }

  Future<void> _nextStep() async {
    // Save current step data to backend before proceeding
    final success = await _saveCurrentStepData();

    // Proceed to next step only if save was successful
    if (success && _currentStep < _totalSteps - 1 && mounted) {
      setState(() {
        _currentStep++;
      });
    }
  }

  Future<bool> _saveCurrentStepData() async {
    switch (_currentStep) {
      case 0:
        return await _saveStepData(
          stepNumber: 1,
          requiredFields: ['name', 'startDate', 'endDate'],
        );
      case 1:
        return await _saveStepData(
          stepNumber: 2,
          requiredFields: [],
        );
      case 2:
        return await _saveStep3Data();
      case 3:
        // Final step - will handle submission differently
        return true;
      default:
        return false;
    }
  }

  Future<bool> _saveStepData({
    required int stepNumber,
    required List<String> requiredFields,
  }) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final packingListId = _formData['packingListId'] as String?;
      final isNewList = packingListId == null;

      // Convert weather and activities lists properly
      final weatherList = _formData['weather'] as List<dynamic>?;
      final activitiesList = _formData['activities'] as List<dynamic>?;

      // Determine what stepCompleted value to send
      int? stepCompletedValue;
      if (_isEditMode) {
        stepCompletedValue = null;
      } else {
        final currentStepCompleted =
            _formData['currentStepCompleted'] as int? ?? 0;
        stepCompletedValue =
            stepNumber > currentStepCompleted ? stepNumber : null;
      }

      debugPrint(
          '📝 Step $stepNumber: ${isNewList ? "Creating" : "Updating"} "${_formData['name']}" (stepCompleted: ${stepCompletedValue ?? "unchanged"})');

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
        stepCompleted: stepCompletedValue,
        context: context,
      );

      if (result != null && mounted) {
        setState(() {
          _formData['packingListId'] = result.id;
          _formData['currentStepCompleted'] = result.stepCompleted;
        });

        if (isNewList) {
          ref.read(packingListsProvider.notifier).addPackingList(result);
        } else {
          ref.read(packingListsProvider.notifier).updatePackingList(result);
        }
        debugPrint(
            '✅ Step $stepNumber saved (progress: ${result.stepCompleted}/4)');
        return true;
      } else {
        _showErrorToast('Failed to save trip details');
        debugPrint('❌ Step $stepNumber failed: No result');
        return false;
      }
    } catch (e, stackTrace) {
      _showErrorToast('Error saving trip details: ${e.toString()}');
      debugPrint('❌ Step $stepNumber error: $e');
      debugPrint(stackTrace.toString());
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _saveStep3Data() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final packingListId = _formData['packingListId'] as String?;

      if (packingListId == null) {
        _showErrorToast('No packing list found. Please start from Step 1.');
        debugPrint('❌ Step 3: No packing list ID');
        return false;
      }

      // Get selected items data from Step 3
      final selectedItems =
          _formData['selectedItems'] as Map<String, bool>? ?? {};
      final itemQuantities =
          _formData['itemQuantities'] as Map<String, int>? ?? {};
      final itemNotes = _formData['itemNotes'] as Map<String, String>? ?? {};
      final customItems = _formData['customItems']
              as Map<String, List<Map<String, dynamic>>>? ??
          {};
      final suggestions = _formData['suggestions'] as List? ?? [];

      final selectedCount = selectedItems.values.where((v) => v).length;
      debugPrint('📦 Step 3: Saving $selectedCount items');

      // Get existing items to avoid duplicates
      final existingItemsResult = await _tripService.getPackingListItems(
        packingListId: packingListId,
        context: mounted ? context : null,
      );

      final existingItems = existingItemsResult?['items'] as List? ?? [];
      final existingItemNames = <String>{};
      final existingItemsById = <String, dynamic>{};

      for (var item in existingItems) {
        existingItemNames.add(item.name.toLowerCase());
        existingItemsById[item.id] = item;
      }

      // Build a map of template ID to item name for later matching
      final Map<String, String> templateIdToName = {};
      for (var suggestion in suggestions) {
        templateIdToName[suggestion.id] = suggestion.name;
      }

      // Separate template items from custom items, filter out existing ones
      final List<String> newTemplateItemIds = [];
      final Map<String, Map<String, dynamic>> itemUpdates = {};

      for (var entry in selectedItems.entries) {
        final itemId = entry.key;
        final isSelected = entry.value;

        if (!isSelected) continue; // Skip unselected items

        // Check if it's a custom item
        if (itemId.startsWith('custom_')) {
          continue; // We'll handle custom items separately
        }

        final itemName = templateIdToName[itemId];
        if (itemName == null) continue;

        // Check if this item already exists
        if (!existingItemNames.contains(itemName.toLowerCase())) {
          // New item - add to bulk add list
          newTemplateItemIds.add(itemId);
        }

        // Track items that need note updates (both new and existing)
        final note = itemNotes[itemId] ?? '';
        if (note.isNotEmpty) {
          itemUpdates[itemId] = {
            'name': itemName,
            'note': note,
          };
        }
      }

      // Step 1: Bulk add new template items
      List? addedItems;
      if (newTemplateItemIds.isNotEmpty) {
        final bulkResult = await _tripService.bulkAddItems(
          packingListId: packingListId,
          itemTemplateIds: newTemplateItemIds,
          context: mounted ? context : null,
        );

        if (bulkResult != null) {
          addedItems = bulkResult['added'] as List?;
        }
      }

      // Step 1.5: Update items that have custom notes
      if (itemUpdates.isNotEmpty) {
        for (var updateEntry in itemUpdates.entries) {
          final updateData = updateEntry.value;
          final itemName = updateData['name'] as String?;
          final note = updateData['note'] as String;

          if (itemName == null) continue;

          // Find the item in either newly added items or existing items
          dynamic targetItem;

          // First check newly added items
          if (addedItems != null) {
            try {
              targetItem = addedItems.firstWhere(
                (item) => item.name == itemName,
              );
            } catch (e) {
              // Not in newly added items
            }
          }

          // If not found in newly added, check existing items
          if (targetItem == null) {
            for (var item in existingItems) {
              if (item.name.toLowerCase() == itemName.toLowerCase()) {
                targetItem = item;
                break;
              }
            }
          }

          if (targetItem != null) {
            await _tripService.updateItem(
              itemId: targetItem.id,
              notes: note,
              context: mounted ? context : null,
            );
          }
        }
      }

      // Step 2: Add new custom items (skip existing ones)
      int customItemCount = 0;
      for (var categoryEntry in customItems.entries) {
        final category = categoryEntry.key;
        final items = categoryEntry.value;

        for (var customItem in items) {
          final itemId = customItem['id'] as String;

          // Only add if selected
          if (selectedItems[itemId] != true) continue;

          final name = customItem['name'] as String;

          // Skip if this custom item already exists (by name)
          if (existingItemNames.contains(name.toLowerCase())) {
            continue;
          }

          final quantity =
              itemQuantities[itemId] ?? customItem['quantity'] as int;
          final note = itemNotes[itemId] ?? customItem['note'] as String;

          await _tripService.addCustomItem(
            packingListId: packingListId,
            name: name,
            category: category,
            quantity: quantity,
            notes: note.isNotEmpty ? note : null,
            context: mounted ? context : null,
          );

          customItemCount++;
        }
      }

      final totalNew = newTemplateItemIds.length + customItemCount;
      if (totalNew > 0) {
        debugPrint(
            '✅ Step 3: Added $totalNew items (${newTemplateItemIds.length} template, $customItemCount custom)');
      }

      // Update step completion
      final success = await _saveStepData(
        stepNumber: 3,
        requiredFields: [],
      );

      return success;
    } catch (e, stackTrace) {
      _showErrorToast('Error saving packing items: ${e.toString()}');
      debugPrint('❌ Step 3 error: $e');
      debugPrint(stackTrace.toString());
      return false;
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
        // Revalidate when returning to a step
        _revalidateCurrentStep();
      });
    }
  }

  void _close() {
    if (mounted) {
      context.pop();
    }
  }

  bool _canProceedToNextStep() {
    // On step 4, always allow finishing
    if (_currentStep == _totalSteps - 1) return true;

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

  Future<void> _handleFinish() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final packingListId = _formData['packingListId'] as String?;

      if (packingListId != null) {
        debugPrint('🏁 Finishing "${_formData['name']}"');

        // Mark as completed by setting stepCompleted to 4
        final result = await _tripService.upsertPackingList(
          id: packingListId,
          name: _formData['name'] as String,
          startDate: _formData['startDate'] as DateTime,
          endDate: _formData['endDate'] as DateTime,
          description: _formData['description'] as String?,
          destination: _formData['destination'] as String?,
          colorTag: _formData['colorTag'] as String?,
          gender: _formData['gender'] as String?,
          weather: (_formData['weather'] as List<dynamic>?)?.cast<String>(),
          purpose: _formData['purpose'] as String?,
          accommodations: _formData['accommodations'] as String?,
          activities:
              (_formData['activities'] as List<dynamic>?)?.cast<String>(),
          stepCompleted: 4,
          context: context,
        );

        if (result != null && mounted) {
          ref.read(packingListsProvider.notifier).updatePackingList(result);
          debugPrint('✅ Packing list complete!');
        } else {
          _showErrorToast('Failed to complete packing list');
        }
      }
    } catch (e, stackTrace) {
      _showErrorToast('Error completing packing list: ${e.toString()}');
      debugPrint('❌ Finish error: $e');
      debugPrint(stackTrace.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Navigate back to packing lists page
        context.pop();
      }
    }
  }

  void _handleEditStep(int step) {
    setState(() {
      _isEditMode = true;
      _currentStep = step;
      // Revalidate when entering edit mode
      _revalidateCurrentStep();
    });
  }

  Future<void> _handleDone() async {
    // Save current step data
    final success = await _saveCurrentStepData();

    // Return to overview and exit edit mode only if save was successful
    if (success && mounted) {
      setState(() {
        _currentStep = 3; // Back to Step 4 (Overview)
        _isEditMode = false;
      });
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
          onEditStep: _handleEditStep,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while initial data is loading
    if (_isLoadingInitialData) {
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
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
              // todo: use theme color here instead of hardcoded color
              unselectedColor: Theme.of(context).colorScheme.surfaceTint,
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
              child: _isEditMode
                  ? // Edit mode: Single full-width "Done" button
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: !_isLoading ? _handleDone : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
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
                                'Done',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                      ),
                    )
                  : // Normal mode: Back/Next buttons
                  Row(
                      children: [
                        if (_currentStep > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _previousStep,
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                side: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              child: Text(
                                'Back',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
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
                                ? (_currentStep == _totalSteps - 1
                                    ? _handleFinish
                                    : _nextStep)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
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
                                    _currentStep == _totalSteps - 1
                                        ? 'Finish'
                                        : 'Next',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
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
