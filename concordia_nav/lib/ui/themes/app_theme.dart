import 'package:flutter/material.dart';

class AppTheme {
  // Use a static variable to store the current theme
  static ThemeData _currentTheme = ThemeData(
    primaryColor: const Color.fromRGBO(146, 35, 56, 1),
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: const Color.fromRGBO(146, 35, 56, 1),
      secondary: const Color.fromRGBO(233, 211, 215, 1),
      surface: Colors.white,
      onPrimary: Colors.white, // Text on primary color backgrounds
      onSecondary: Colors.black, // Text on secondary color backgrounds
      onSurface: Colors.black, // Text on surface/background
    ),
    iconTheme: const IconThemeData(
      color: Color.fromRGBO(146, 35, 56, 1),
    ),
    textTheme: const TextTheme().apply(
      bodyColor: Colors.black,  // Primary text color
      displayColor: Colors.black,
    ),
  );

  // Stream controller to notify about theme changes
  static final _themeChangeNotifier = ValueNotifier<ThemeData>(_currentTheme);

  // Getter for the current theme
  static ThemeData get theme => _currentTheme;

  // Getter for the theme change stream
  static ValueNotifier<ThemeData> get themeChangeNotifier => _themeChangeNotifier;

  // Method to update the theme
  static void updateTheme(ThemeData newTheme) {
    _currentTheme = newTheme;
    _themeChangeNotifier.value = newTheme;
  }

  // Helper method to get a theme with specific colors
  static ThemeData createTheme({
    required Color primaryColor,
    required Color secondaryColor,
    required Color backgroundColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: backgroundColor,
        onPrimary: secondaryTextColor, // Text on primary colored elements
        onSecondary: primaryTextColor, // Text on secondary colored elements
        onSurface: primaryTextColor, // Text on surface/background
      ),
      iconTheme: IconThemeData(
        color: primaryColor,
      ),
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: primaryTextColor,
        displayColor: primaryTextColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: secondaryTextColor, // Usually white text on colored app bar
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: secondaryTextColor, // Usually white text on colored button
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: primaryColor),
          foregroundColor: primaryColor,
        ),
      ),
    );
  }

  // Method to reset to default theme
  static void resetToDefault() {
    _currentTheme = ThemeData(
      primaryColor: const Color.fromRGBO(146, 35, 56, 1),
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: const Color.fromRGBO(146, 35, 56, 1),
        secondary: const Color.fromRGBO(233, 211, 215, 1),
        surface: Colors.white,
        onPrimary: Colors.white, // Text on primary color (white text on burgundy)
        onSecondary: Colors.black, // Text on secondary color (black text on light pink)
        onSurface: Colors.black, // Text on surface (black text on white background)
      ),
      iconTheme: const IconThemeData(
        color: Color.fromRGBO(146, 35, 56, 1),
      ),
      textTheme: const TextTheme().apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromRGBO(146, 35, 56, 1),
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(146, 35, 56, 1),
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color.fromRGBO(146, 35, 56, 1)),
          foregroundColor: const Color.fromRGBO(146, 35, 56, 1),
        ),
      ),
    );
    _themeChangeNotifier.value = _currentTheme;
  }
}