// ignore_for_file: avoid_catches_without_on_clauses

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
    cardTheme: const CardTheme(
      color: Colors.white,
    ),
    cardColor: Colors.grey[100],
  );

  // Stream controller to notify about theme changes
  static final _themeChangeNotifier = ValueNotifier<ThemeData>(_currentTheme);

  // Getter for the current theme
  static ThemeData get theme => _currentTheme;

  // Getter for the theme change stream
  static ValueNotifier<ThemeData> get themeChangeNotifier => _themeChangeNotifier;

  // Method to update the theme and save to preferences
  static Future<void> updateTheme(ThemeData newTheme) async {
    _currentTheme = newTheme;
    _themeChangeNotifier.value = newTheme;

    // Save theme settings
    await saveThemeToPrefs();
  }

  // Save theme settings to SharedPreferences
  static Future<void> saveThemeToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert theme colors to a map for storage
      final Map<String, String> themeData = {
        'primaryColor': _currentTheme.primaryColor.toString(),
        'secondaryColor': _currentTheme.colorScheme.secondary.toString(),
        'backgroundColor': _currentTheme.scaffoldBackgroundColor.toString(),
        'primaryTextColor': (_currentTheme.textTheme.bodyLarge?.color ?? Colors.black).toString(),
        'secondaryTextColor': _currentTheme.colorScheme.onPrimary.toString(),
        'cardColor': _currentTheme.cardColor.toString(),
      };

      // Save as JSON string
      await prefs.setString('app_theme', jsonEncode(themeData));
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  // Load theme settings from SharedPreferences
  static Future<void> loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? themeStr = prefs.getString('app_theme');

      if (themeStr != null) {
        final Map<String, dynamic> themeData = jsonDecode(themeStr);

        // Create theme from saved values
        final newTheme = createTheme(
          primaryColor: Color(int.parse(themeData['primaryColor'])),
          secondaryColor: Color(int.parse(themeData['secondaryColor'])),
          backgroundColor: Color(int.parse(themeData['backgroundColor'])),
          primaryTextColor: Color(int.parse(themeData['primaryTextColor'])),
          secondaryTextColor: Color(int.parse(themeData['secondaryTextColor'])),
          cardColor: Color(int.parse(themeData['cardColor'])),
        );

        // Update theme without saving (to avoid recursion)
        _currentTheme = newTheme;
        _themeChangeNotifier.value = newTheme;
      }
    } catch (e) {
      debugPrint('Error loading theme: $e');
      // If there's an error, use default theme
    }
  }

  // Helper method to get a theme with specific colors
  static ThemeData createTheme({
    required Color primaryColor,
    required Color secondaryColor,
    required Color backgroundColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Color cardColor,
  }) {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
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
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
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
  static Future<void> resetToDefault() async {
    _currentTheme = ThemeData(
      primaryColor: const Color.fromRGBO(146, 35, 56, 1),
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.grey[100],
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
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
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
    
    // Clear saved preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('app_theme');
  }
}