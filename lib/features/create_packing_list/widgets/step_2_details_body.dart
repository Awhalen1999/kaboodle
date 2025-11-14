import 'package:flutter/material.dart';
import 'package:kaboodle_app/features/create_packing_list/widgets/svg_option_button.dart';
import 'package:kaboodle_app/features/create_packing_list/widgets/svg_option_tile.dart';

class Step2DetailsBody extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(Map<String, dynamic>) onDataChanged;

  const Step2DetailsBody({
    super.key,
    required this.formData,
    required this.onDataChanged,
  });

  @override
  State<Step2DetailsBody> createState() => _Step2DetailsBodyState();
}

class _Step2DetailsBodyState extends State<Step2DetailsBody> {
  String? _selectedGender;
  final Set<String> _selectedWeather = {};
  String? _selectedPurpose;
  String? _selectedAccommodations;
  final Set<String> _selectedActivities = {};

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.formData['gender'] as String?;
    _selectedPurpose = widget.formData['purpose'] as String?;
    _selectedAccommodations = widget.formData['accommodations'] as String?;

    // Initialize weather selections from formData
    final weatherList = widget.formData['weather'] as List<dynamic>?;
    if (weatherList != null) {
      _selectedWeather.addAll(weatherList.cast<String>());
    }

    // Initialize activities selections from formData
    final activitiesList = widget.formData['activities'] as List<dynamic>?;
    if (activitiesList != null) {
      _selectedActivities.addAll(activitiesList.cast<String>());
    }
  }

  void _updateGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
    widget.onDataChanged({'gender': gender});
  }

  void _toggleWeather(String weather) {
    setState(() {
      if (_selectedWeather.contains(weather)) {
        _selectedWeather.remove(weather);
      } else {
        _selectedWeather.add(weather);
      }
    });
    widget.onDataChanged({'weather': _selectedWeather.toList()});
  }

  void _updatePurpose(String purpose) {
    setState(() {
      _selectedPurpose = purpose;
    });
    widget.onDataChanged({'purpose': purpose});
  }

  void _updateAccommodations(String accommodations) {
    setState(() {
      _selectedAccommodations = accommodations;
    });
    widget.onDataChanged({'accommodations': accommodations});
  }

  void _toggleActivity(String activity) {
    setState(() {
      if (_selectedActivities.contains(activity)) {
        _selectedActivities.remove(activity);
      } else {
        _selectedActivities.add(activity);
      }
    });
    widget.onDataChanged({'activities': _selectedActivities.toList()});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Trip Details',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Help us personalize your packing list',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),

          // Gender Section
          Text(
            'Gender',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select the gender this list will be packed for',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SvgOptionButton(
                  svgPath: 'assets/svg/male.svg',
                  title: 'Male',
                  isSelected: _selectedGender == 'male',
                  onTap: () => _updateGender('male'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SvgOptionButton(
                  svgPath: 'assets/svg/female.svg',
                  title: 'Female',
                  isSelected: _selectedGender == 'female',
                  onTap: () => _updateGender('female'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SvgOptionButton(
                  svgPath: 'assets/svg/other.svg',
                  title: 'Other',
                  isSelected: _selectedGender == 'other',
                  onTap: () => _updateGender('other'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Weather Section
          Text(
            'Weather',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'What weather conditions should we prepare for? (Select all that apply)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SvgOptionButton(
                  svgPath: 'assets/svg/warm.svg',
                  title: 'Warm',
                  isSelected: _selectedWeather.contains('warm'),
                  onTap: () => _toggleWeather('warm'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SvgOptionButton(
                  svgPath: 'assets/svg/cool.svg',
                  title: 'Cold',
                  isSelected: _selectedWeather.contains('cold'),
                  onTap: () => _toggleWeather('cold'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SvgOptionButton(
                  svgPath: 'assets/svg/mild.svg',
                  title: 'Mild',
                  isSelected: _selectedWeather.contains('mild'),
                  onTap: () => _toggleWeather('mild'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Purpose Section
          Text(
            'Purpose',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'What\'s the main purpose of your trip?',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SvgOptionButton(
                  svgPath: 'assets/svg/vacation.svg',
                  title: 'Vacation',
                  isSelected: _selectedPurpose == 'vacation',
                  onTap: () => _updatePurpose('vacation'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SvgOptionButton(
                  svgPath: 'assets/svg/business.svg',
                  title: 'Business',
                  isSelected: _selectedPurpose == 'business',
                  onTap: () => _updatePurpose('business'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Accommodations Section
          Text(
            'Accommodations',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Where will you be staying?',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              // First row: Cabin, Road Trip, Camping
              Row(
                children: [
                  Expanded(
                    child: SvgOptionButton(
                      svgPath: 'assets/svg/cabin.svg',
                      title: 'Cabin',
                      isSelected: _selectedAccommodations == 'cabin',
                      onTap: () => _updateAccommodations('cabin'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SvgOptionButton(
                      svgPath: 'assets/svg/camper-van.svg',
                      title: 'Road Trip',
                      isSelected: _selectedAccommodations == 'roadTrip',
                      onTap: () => _updateAccommodations('roadTrip'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SvgOptionButton(
                      svgPath: 'assets/svg/camping.svg',
                      title: 'Camping',
                      isSelected: _selectedAccommodations == 'camping',
                      onTap: () => _updateAccommodations('camping'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Second row: Cruise, House, Hotel
              Row(
                children: [
                  Expanded(
                    child: SvgOptionButton(
                      svgPath: 'assets/svg/cruise.svg',
                      title: 'Cruise',
                      isSelected: _selectedAccommodations == 'cruise',
                      onTap: () => _updateAccommodations('cruise'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SvgOptionButton(
                      svgPath: 'assets/svg/home.svg',
                      title: 'House',
                      isSelected: _selectedAccommodations == 'house',
                      onTap: () => _updateAccommodations('house'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SvgOptionButton(
                      svgPath: 'assets/svg/hotel.svg',
                      title: 'Hotel',
                      isSelected: _selectedAccommodations == 'hotel',
                      onTap: () => _updateAccommodations('hotel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Activities Section
          Text(
            'Activities',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'What activities do you plan to do? (Select all that apply)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              SvgOptionTile(
                svgPath: 'assets/svg/bicycle.svg',
                title: 'Biking',
                isSelected: _selectedActivities.contains('biking'),
                onTap: () => _toggleActivity('biking'),
              ),
              const SizedBox(height: 8),
              SvgOptionTile(
                svgPath: 'assets/svg/camera.svg',
                title: 'Photography',
                isSelected: _selectedActivities.contains('photography'),
                onTap: () => _toggleActivity('photography'),
              ),
              const SizedBox(height: 8),
              SvgOptionTile(
                svgPath: 'assets/svg/dumbbell.svg',
                title: 'Fitness',
                isSelected: _selectedActivities.contains('fitness'),
                onTap: () => _toggleActivity('fitness'),
              ),
              const SizedBox(height: 8),
              SvgOptionTile(
                svgPath: 'assets/svg/golf-field.svg',
                title: 'Golf',
                isSelected: _selectedActivities.contains('golf'),
                onTap: () => _toggleActivity('golf'),
              ),
              const SizedBox(height: 8),
              SvgOptionTile(
                svgPath: 'assets/svg/mountain-route.svg',
                title: 'Hiking',
                isSelected: _selectedActivities.contains('hiking'),
                onTap: () => _toggleActivity('hiking'),
              ),
              const SizedBox(height: 8),
              SvgOptionTile(
                svgPath: 'assets/svg/rod.svg',
                title: 'Fishing',
                isSelected: _selectedActivities.contains('fishing'),
                onTap: () => _toggleActivity('fishing'),
              ),
              const SizedBox(height: 8),
              SvgOptionTile(
                svgPath: 'assets/svg/laptop.svg',
                title: 'Work',
                isSelected: _selectedActivities.contains('work'),
                onTap: () => _toggleActivity('work'),
              ),
              const SizedBox(height: 8),
              SvgOptionTile(
                svgPath: 'assets/svg/umbrella.svg',
                title: 'Beach',
                isSelected: _selectedActivities.contains('beach'),
                onTap: () => _toggleActivity('beach'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
