import 'package:flutter/material.dart';

// Original purple color scheme (saved for reference):
// primary: Color(0xFF48224b)
// secondary: Color(0xFF59365e)
// tertiary: Color(0xFFa95db2)
// primaryFixedDim: Color(0xFFf8efff)

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Color(0xFFFF7F50),
    onPrimary: Colors.white,
    surface: Color.fromARGB(255, 28, 28, 28),
    onSurface: Colors.white,
    onSurfaceVariant: const Color.fromARGB(255, 180, 180, 180),
    secondary: Color(0xFFFFA07A),
    onSecondary: Colors.white,
    tertiary: Color(0xFFFFB347),
    onTertiary: Colors.white,
    primaryFixedDim: Color(0xFFFFE5D4),
    onPrimaryFixedVariant: Colors.black,
    inverseSurface: Color(0xFFf8efff),
    onInverseSurface: Colors.black,
    surfaceContainer: Color.fromARGB(255, 28, 28, 28),
    outline: Color.fromARGB(255, 60, 60, 60),
    outlineVariant: Color.fromARGB(255, 100, 100, 100),
    shadow: Color.fromARGB(15, 0, 0, 0),
    surfaceTint: Color.fromARGB(255, 40, 40, 40),
  ),
  textTheme: ThemeData.dark().textTheme.copyWith(
        headlineLarge: TextStyle(
          fontFamily: 'bagel',
          fontWeight: FontWeight.w400,
          color: Colors.white,
          fontSize: 32,
        ),
        displayLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          color: Colors.white,
          fontSize: 32,
          letterSpacing: 1.5,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          color: Colors.white,
          fontSize: 28,
          letterSpacing: 1.5,
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
          color: Colors.white,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
          color: Colors.white,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
          color: Colors.white,
          fontSize: 12,
        ),
      ),
);
