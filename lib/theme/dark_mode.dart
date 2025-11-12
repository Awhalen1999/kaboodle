import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF48224b),
    onPrimary: Colors.white,
    surface: Color.fromARGB(255, 28, 28, 28),
    onSurface: Colors.white,
    secondary: Color(0xFF59365e),
    onSecondary: Colors.white,
    tertiary: Color(0xFFa95db2),
    onTertiary: Colors.white,
    primaryFixedDim: Color(0xFFf8efff),
    onPrimaryFixedVariant: Colors.black,
    inverseSurface: Color(0xFFf8efff),
    onInverseSurface: Colors.black,
    surfaceContainer: Color.fromARGB(255, 28, 28, 28),
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
