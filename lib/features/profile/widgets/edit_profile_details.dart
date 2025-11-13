import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:country_picker/country_picker.dart';
import 'package:kaboodle_app/models/user.dart';
import 'package:kaboodle_app/providers/user_provider.dart';

class EditProfileDetails extends ConsumerStatefulWidget {
  const EditProfileDetails({super.key});

  @override
  ConsumerState<EditProfileDetails> createState() => _EditProfileDetailsState();
}

class _EditProfileDetailsState extends ConsumerState<EditProfileDetails> {
  TextEditingController? _displayNameController;
  Country? _selectedCountry;
  bool _isSaving = false;
  bool _countryInitialized = false;

  void _initializeControllers(User user) {
    _displayNameController ??=
        TextEditingController(text: user.displayName ?? '');

    if (!_countryInitialized &&
        user.country != null &&
        user.country!.isNotEmpty) {
      _selectedCountry = _findCountryByName(user.country!);
      _countryInitialized = true;
    }
  }

  Country? _findCountryByName(String countryValue) {
    try {
      // If countryValue is a country code (2 letters), parse it directly
      if (countryValue.length == 2) {
        return Country.parse(countryValue.toUpperCase());
      }
      // Otherwise, try to find by name (for backwards compatibility)
      // Try common country codes first
      final commonCodes = [
        'US',
        'GB',
        'CA',
        'AU',
        'DE',
        'FR',
        'IT',
        'ES',
        'NL',
        'BE',
        'CH',
        'AT',
        'SE',
        'NO',
        'DK',
        'FI',
        'PL',
        'CZ',
        'IE',
        'PT',
        'GR',
        'NZ',
        'JP',
        'KR',
        'CN',
        'IN',
        'BR',
        'MX',
        'AR',
        'CL',
        'CO',
        'PE',
        'ZA',
        'EG',
        'NG',
        'KE',
        'MA',
        'AE',
        'SA',
        'IL',
        'TR',
        'RU'
      ];

      for (final code in commonCodes) {
        try {
          final country = Country.parse(code);
          if (country.name.toLowerCase() == countryValue.toLowerCase()) {
            return country;
          }
        } catch (e) {
          continue;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _displayNameController?.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() {
      _isSaving = true;
    });

    final success = await ref.read(userProvider.notifier).updateUserProfile(
          displayName: _displayNameController!.text.trim().isEmpty
              ? null
              : _displayNameController!.text.trim(),
          country: _selectedCountry?.countryCode,
        );

    setState(() {
      _isSaving = false;
    });

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          print('⚠️ [EditProfileDetails] User data is null');
          return const Center(child: CircularProgressIndicator());
        }

        print(
            '✅ [EditProfileDetails] User data received: ${user.displayName ?? user.email}');
        _initializeControllers(user);
        return _buildEditForm(context, user);
      },
      loading: () {
        print('⏳ [EditProfileDetails] User loading...');
        return const Center(child: CircularProgressIndicator());
      },
      error: (error, stackTrace) {
        print('❌ [EditProfileDetails] User error: $error');
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load profile',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditForm(BuildContext context, User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Profile picture with camera icon
        Center(
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[300],
                ),
                clipBehavior: Clip.antiAlias,
                child: user.photoUrl != null
                    ? Image.network(
                        user.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey[600],
                          );
                        },
                      )
                    : Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey[600],
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[300]!.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        print('button clicked: edit picture');
                      },
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Email display
        Center(
          child: Text(
            user.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ),
        const SizedBox(height: 32),

        // Display Name field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Display Name',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _displayNameController!,
              decoration: InputDecoration(
                hintText: 'Enter your name',
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
        const SizedBox(height: 20),

        // Country field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Country',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
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
                    ] else if (user.country != null &&
                        user.country!.isNotEmpty) ...[
                      // Show existing country name without flag if not matched
                      Expanded(
                        child: Text(
                          user.country!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ] else
                      Expanded(
                        child: Text(
                          'Select your country',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[400],
                                  ),
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
        const SizedBox(height: 32),

        // Save and Cancel buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : _handleCancel,
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
                  'Cancel',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Save',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
              ),
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }
}
