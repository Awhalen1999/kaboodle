import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF3B82F6),
    onPrimary: Colors.white,
    surface: Color(0xFF000000),
    onSurface: Colors.white,
  ),
  textTheme: ThemeData.dark().textTheme.copyWith(
        headlineLarge: TextStyle(
          fontFamily: 'bagel',
          fontWeight: FontWeight.w400,
          color: Colors.white,
          fontSize: 32,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          color: Colors.white,
          fontSize: 24,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
          color: Colors.grey[300],
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w300,
          color: Colors.grey[300],
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w200,
          color: Colors.grey[300],
          fontSize: 12,
        ),
      ),
);
