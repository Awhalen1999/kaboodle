import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:intl/intl.dart';
import 'package:country_picker/country_picker.dart';
import 'package:kaboodle_app/shared/utils/country_utils.dart';

class Step1GeneralInfoBody extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(Map<String, dynamic>) onDataChanged;
  final Function(bool)? onValidationChanged;

  const Step1GeneralInfoBody({
    super.key,
    required this.formData,
    required this.onDataChanged,
    this.onValidationChanged,
  });

  @override
  State<Step1GeneralInfoBody> createState() => _Step1GeneralInfoBodyState();
}

class _Step1GeneralInfoBodyState extends State<Step1GeneralInfoBody> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  Country? _selectedCountry;
  bool _countryInitialized = false;
  List<DateTime?> _selectedDates = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.formData['name'] as String? ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.formData['description'] as String? ?? '',
    );

    // Initialize country from formData if available
    if (!_countryInitialized &&
        widget.formData['destination'] != null &&
        widget.formData['destination']!.isNotEmpty) {
      _selectedCountry = CountryUtils.getCountry(widget.formData['destination']!);
      _countryInitialized = true;
    }

    // Initialize dates from formData if available
    if (widget.formData['startDate'] != null &&
        widget.formData['endDate'] != null) {
      _selectedDates = [
        widget.formData['startDate'] as DateTime,
        widget.formData['endDate'] as DateTime,
      ];
    }

    // Listen to changes and update form data
    _nameController.addListener(_updateFormData);
    _descriptionController.addListener(_updateFormData);

    // Check initial validation state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onValidationChanged != null) {
        widget.onValidationChanged!(_isValid());
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _isValid() {
    final name = _nameController.text.trim();
    final hasStartDate = _selectedDates.isNotEmpty && _selectedDates[0] != null;
    final hasEndDate = _selectedDates.length > 1 && _selectedDates[1] != null;

    return name.isNotEmpty && hasStartDate && hasEndDate;
  }

  void _updateFormData() {
    widget.onDataChanged({
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'destination': _selectedCountry?.countryCode,
      'startDate': _selectedDates.isNotEmpty && _selectedDates[0] != null
          ? _selectedDates[0]
          : null,
      'endDate': _selectedDates.length > 1 && _selectedDates[1] != null
          ? _selectedDates[1]
          : null,
    });

    // Notify parent of validation state
    if (widget.onValidationChanged != null) {
      widget.onValidationChanged!(_isValid());
    }
  }

  void _selectColorTag(String? color) {
    widget.onDataChanged({
      'colorTag': color,
    });
  }

  Future<void> _selectDateRange() async {
    final results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.range,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        selectedDayHighlightColor: Theme.of(context).colorScheme.primary,
        selectedRangeHighlightColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.3),
        cancelButtonTextStyle: Theme.of(context).textTheme.bodyMedium,
        okButtonTextStyle: Theme.of(context).textTheme.bodyMedium,
      ),
      dialogSize: const Size(325, 400),
      value: _selectedDates,
      borderRadius: BorderRadius.circular(15),
    );

    if (results != null && results.isNotEmpty) {
      setState(() {
        _selectedDates = results;
      });
      _updateFormData();
    } else if (results != null && results.isEmpty) {
      // User cleared the selection
      setState(() {
        _selectedDates = [];
      });
      _updateFormData();
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _getDateRangeText() {
    if (_selectedDates.isEmpty || _selectedDates[0] == null) {
      return 'Select trip dates';
    }
    if (_selectedDates.length == 1 || _selectedDates[1] == null) {
      return '${_formatDate(_selectedDates[0])} - Select end date';
    }
    return '${_formatDate(_selectedDates[0])} - ${_formatDate(_selectedDates[1])}';
  }

  int? _getTripLength() {
    if (_selectedDates.length < 2 ||
        _selectedDates[0] == null ||
        _selectedDates[1] == null) {
      return null;
    }
    return _selectedDates[1]!.difference(_selectedDates[0]!).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'General Information',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tell us the basics about your trip',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),

          // Name field (required)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Trip Name',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '*',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter trip name',
                  hintStyle: Theme.of(context).textTheme.bodyLarge,
                  filled: false,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 0.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 0.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Description field (optional)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Description',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add a description (optional)',
                  hintStyle: Theme.of(context).textTheme.bodyLarge,
                  filled: false,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 0.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 0.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Destination field (optional)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Destination',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode: false,
                    onSelect: (Country country) {
                      setState(() {
                        _selectedCountry = country;
                      });
                      _updateFormData();
                    },
                    countryListTheme: CountryListThemeData(
                      bottomSheetHeight:
                          MediaQuery.of(context).size.height * 0.60,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      inputDecoration: InputDecoration(
                        labelText: 'Search',
                        hintText: 'Start typing to search',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (_selectedCountry != null) ...[
                        Text(
                          _selectedCountry!.flagEmoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedCountry!.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ] else
                        Expanded(
                          child: Text(
                            'Where are you going? (optional)',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Color tag selector
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Color Tag',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'This is just a color to help you identify and organize your trips',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // Grey
                  _ColorTagOption(
                    color: 'grey',
                    selectedColor: widget.formData['colorTag'] as String?,
                    onTap: _selectColorTag,
                  ),
                  const SizedBox(width: 12),
                  // Red
                  _ColorTagOption(
                    color: 'red',
                    selectedColor: widget.formData['colorTag'] as String?,
                    onTap: _selectColorTag,
                  ),
                  const SizedBox(width: 12),
                  // Blue
                  _ColorTagOption(
                    color: 'blue',
                    selectedColor: widget.formData['colorTag'] as String?,
                    onTap: _selectColorTag,
                  ),
                  const SizedBox(width: 12),
                  // Green
                  _ColorTagOption(
                    color: 'green',
                    selectedColor: widget.formData['colorTag'] as String?,
                    onTap: _selectColorTag,
                  ),
                  const SizedBox(width: 12),
                  // Purple
                  _ColorTagOption(
                    color: 'purple',
                    selectedColor: widget.formData['colorTag'] as String?,
                    onTap: _selectColorTag,
                  ),
                  const SizedBox(width: 12),
                  // Orange
                  _ColorTagOption(
                    color: 'orange',
                    selectedColor: widget.formData['colorTag'] as String?,
                    onTap: _selectColorTag,
                  ),
                  const SizedBox(width: 12),
                  // Pink
                  _ColorTagOption(
                    color: 'pink',
                    selectedColor: widget.formData['colorTag'] as String?,
                    onTap: _selectColorTag,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Dates section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Trip Dates',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '*',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Select your trip start and end dates',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),

              // Trip length display
              if (_getTripLength() != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Trip length: ${_getTripLength()} ${_getTripLength() == 1 ? 'day' : 'days'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Date range picker
              InkWell(
                onTap: _selectDateRange,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getDateRangeText(),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: _selectedDates.isEmpty ||
                                        _selectedDates[0] == null
                                    ? Colors.grey[400]
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorTagOption extends StatelessWidget {
  final String? color;
  final String? selectedColor;
  final Function(String?) onTap;

  const _ColorTagOption({
    required this.color,
    required this.selectedColor,
    required this.onTap,
  });

  Color _getColor() {
    switch (color) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      default:
        return Colors.grey[400]!.withOpacity(0.5);
    }
  }

  bool get isSelected => selectedColor == color;

  @override
  Widget build(BuildContext context) {
    final boxColor = _getColor();

    return GestureDetector(
      onTap: () => onTap(color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.onSurface
                : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
        ),
      ),
    );
  }
}
