import 'package:flutter/material.dart';

// Original purple color scheme (saved for reference):
// primary: Color(0xFF48224b)
// secondary: Color(0xFF59365e)
// tertiary: Color(0xFFa95db2)
// primaryFixedDim: Color(0xFFf8efff)

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: Color(0xFFFF7F50),
    onPrimary: Colors.white,
    surface: Color.fromARGB(255, 250, 249, 250),
    onSurface: Colors.black,
    onSurfaceVariant: const Color.fromARGB(255, 65, 65, 65),
    secondary: Color(0xFFFFA07A),
    onSecondary: Colors.white,
    tertiary: Color(0xFFFFB347),
    onTertiary: Colors.white,
    surfaceContainer: Colors.white,
    surfaceContainerHigh: Color.fromARGB(255, 245, 245, 245),
    primaryFixedDim: Color(0xFFFFE5D4),
    onPrimaryFixedVariant: Colors.black,
    inverseSurface: Color(0xFF000000),
    onInverseSurface: Colors.white,
    outline: Color.fromARGB(255, 230, 230, 230),
    outlineVariant: Color.fromARGB(255, 195, 195, 195),
    shadow: Color.fromARGB(15, 0, 0, 0),
    surfaceTint: Color.fromARGB(255, 225, 225, 225),
  ),
  textTheme: ThemeData.light().textTheme.copyWith(
        headlineLarge: TextStyle(
          fontFamily: 'bagel',
          fontWeight: FontWeight.w400,
          color: Colors.black,
          fontSize: 32,
        ),
        displayLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
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
          color: Colors.black,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
          color: Colors.black,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
          color: Colors.black,
          fontSize: 12,
        ),
      ),
);
