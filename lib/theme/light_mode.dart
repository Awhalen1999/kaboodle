import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: Color(0xFF7A52F4),
    onPrimary: Colors.white,
    primaryContainer: Color.fromARGB(50, 123, 82, 244),
    secondary: Color(0xFFE91E63),
    onSecondary: Colors.black,
    tertiary: Color(0xFFF2BB98),
    onTertiary: Colors.black,
    surface: Color.fromARGB(255, 245, 245, 245),
    surfaceBright: Colors.white,
    onSurface: Colors.black,
    onSurfaceVariant: Colors.grey[800],
    error: Color(0xFFFF3F3F),
    onError: Colors.white,
    shadow: Color.fromARGB(30, 210, 210, 210),
    surfaceContainer: Color.fromARGB(200, 222, 222, 222),
    surfaceContainerLow: Color.fromARGB(255, 255, 255, 255),
  ),
  textTheme: ThemeData.light().textTheme.copyWith(
        displayLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
          color: Colors.black,
          fontSize: 32,
          letterSpacing: 1.5,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontSize: 28,
          letterSpacing: 1.5,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontSize: 24,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
          color: Colors.grey[900],
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
          color: Colors.grey[800],
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
          color: Colors.grey[800],
          fontSize: 13,
        ),
      ),
);
