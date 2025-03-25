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
    ),
    iconTheme: const IconThemeData(
      color: Color.fromRGBO(146, 35, 56, 1),
    ),
    textTheme: const TextTheme().apply(
      bodyColor: Colors.black,
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
    required Color textColor,
  }) {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: backgroundColor,
      ),
      iconTheme: IconThemeData(
        color: primaryColor,
      ),
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: textColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: backgroundColor,
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
      ),
      iconTheme: const IconThemeData(
        color: Color.fromRGBO(146, 35, 56, 1),
      ),
      textTheme: const TextTheme().apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
    );
    _themeChangeNotifier.value = _currentTheme;
  }
}