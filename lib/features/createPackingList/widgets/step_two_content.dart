import 'package:flutter/material.dart';
import 'package:kaboodle/features/createPackingList/widgets/gender_selector.dart';
import 'package:kaboodle/features/createPackingList/widgets/purpose_of_trip_selector.dart';
import 'package:kaboodle/features/createPackingList/widgets/weather_condition_selector.dart';
import 'package:kaboodle/features/createPackingList/widgets/trip_length_slider.dart';
import 'package:kaboodle/features/createPackingList/widgets/accommodation_selector.dart';
import 'package:kaboodle/features/createPackingList/widgets/items_activities_selector.dart';

class StepTwoContent extends StatelessWidget {
  final String? gender;
  final String? tripPurpose;
  final String? weatherCondition;
  final double tripLength;
  final String? accommodation;
  final List<String> selectedItems;
  final ValueChanged<String?> onGenderChanged;
  final ValueChanged<String?> onTripPurposeChanged;
  final ValueChanged<String?> onWeatherConditionChanged;
  final ValueChanged<double> onTripLengthChanged;
  final ValueChanged<String?> onAccommodationChanged;
  final ValueChanged<String> onItemToggled;

  const StepTwoContent({
    super.key,
    required this.gender,
    required this.tripPurpose,
    required this.weatherCondition,
    required this.tripLength,
    required this.accommodation,
    required this.selectedItems,
    required this.onGenderChanged,
    required this.onTripPurposeChanged,
    required this.onWeatherConditionChanged,
    required this.onTripLengthChanged,
    required this.onAccommodationChanged,
    required this.onItemToggled,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Let's personalize your list",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tell us a bit more about your plans so we can tailor our packing recommendations. Feel free to skip any questions you don't want to answer or are unsure about.",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          GenderSelector(
            selectedGender: gender,
            onGenderSelected: onGenderChanged,
          ),
          PurposeOfTripSelector(
            selectedPurpose: tripPurpose,
            onPurposeSelected: onTripPurposeChanged,
          ),
          WeatherConditionSelector(
            selectedWeather: weatherCondition,
            onWeatherSelected: onWeatherConditionChanged,
          ),
          TripLengthSlider(
            tripLength: tripLength,
            onTripLengthChanged: onTripLengthChanged,
          ),
          AccommodationSelector(
            selectedAccommodation: accommodation,
            onAccommodationSelected: onAccommodationChanged,
          ),
          ItemsActivitiesSelector(
            selectedItems: selectedItems,
            onItemToggled: onItemToggled,
          ),
        ],
      ),
    );
  }
}
