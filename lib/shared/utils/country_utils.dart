import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

// Utility class for country-related operations
class CountryUtils {
  // Common country codes for backwards compatibility lookup
  static const List<String> commonCountryCodes = [
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
    'RU',
  ];

  // Get country flag widget from country value (code or name)
  // Returns a Text widget with the flag emoji, or SizedBox.shrink() if not found
  static Widget getCountryFlag(String countryValue) {
    try {
      Country? country;

      // If it's a country code (2 letters), parse it directly
      if (countryValue.length == 2) {
        country = Country.parse(countryValue.toUpperCase());
      } else {
        // Try to find by name (for backwards compatibility)
        country = _findCountryByName(countryValue);
      }

      if (country != null) {
        return Text(
          country.flagEmoji,
          style: const TextStyle(fontSize: 16),
        );
      }
    } catch (e) {
      // If parsing fails, return empty widget
    }
    return const SizedBox.shrink();
  }

  // Find country by name from common country codes
  // Returns Country if found, null otherwise
  static Country? _findCountryByName(String countryName) {
    for (final code in commonCountryCodes) {
      try {
        final country = Country.parse(code);
        if (country.name.toLowerCase() == countryName.toLowerCase()) {
          return country;
        }
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  // Get country code from country value (code or name)
  // Returns the 2-letter country code if found, null otherwise
  static String? getCountryCode(String countryValue) {
    try {
      Country? country;

      if (countryValue.length == 2) {
        country = Country.parse(countryValue.toUpperCase());
        return country.countryCode;
      } else {
        country = _findCountryByName(countryValue);
        return country?.countryCode;
      }
    } catch (e) {
      return null;
    }
  }
}
