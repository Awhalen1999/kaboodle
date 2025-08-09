import 'package:flutter/material.dart';
import 'package:kaboodle/features/createPackingList/provider/create_packing_list_provider.dart';
import 'package:kaboodle/features/createPackingList/widgets/step_two_content.dart';
import 'package:provider/provider.dart';

class MainStepTwoBody extends StatelessWidget {
  const MainStepTwoBody({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreatePackingListProvider>();
    return StepTwoContent(
      gender: provider.gender,
      tripPurpose: provider.tripPurpose,
      weatherCondition: provider.weatherCondition,
      tripLength: provider.tripLength,
      accommodation: provider.accommodation,
      selectedItems: provider.itemsActivities,
      onGenderChanged: provider.updateGender,
      onTripPurposeChanged: provider.updateTripPurpose,
      onWeatherConditionChanged: provider.updateWeatherCondition,
      onTripLengthChanged: provider.updateTripLength,
      onAccommodationChanged: provider.updateAccommodation,
      onItemToggled: provider.toggleItemActivity,
    );
  }
}
