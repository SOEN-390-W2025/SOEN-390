// ignore_for_file: avoid_catches_without_on_clauses, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppTheme {
  static ThemeData _currentTheme = _defaultTheme();
  static final _themeChangeNotifier = ValueNotifier<ThemeData>(_currentTheme);

  static ThemeData get theme => _currentTheme;
  static ValueNotifier<ThemeData> get themeChangeNotifier =>
      _themeChangeNotifier;

  static ThemeData _defaultTheme() {
    return ThemeData(
      primaryColor: const Color.fromRGBO(146, 35, 56, 1),
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.grey[100],
      colorScheme: _defaultColorScheme(),
      iconTheme: _defaultIconTheme(),
      textTheme: _defaultTextTheme(),
      cardTheme: _defaultCardTheme(),
      appBarTheme: _defaultAppBarTheme(),
      elevatedButtonTheme: _defaultElevatedButtonTheme(),
      outlinedButtonTheme: _defaultOutlinedButtonTheme(),
    );
  }

  static ColorScheme _defaultColorScheme() {
    return ColorScheme.fromSwatch().copyWith(
      primary: const Color.fromRGBO(146, 35, 56, 1),
      secondary: const Color.fromRGBO(233, 211, 215, 1),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
    );
  }

  static IconThemeData _defaultIconTheme() {
    return const IconThemeData(
      color: Color.fromRGBO(146, 35, 56, 1),
    );
  }

  static TextTheme _defaultTextTheme() {
    return const TextTheme().apply(
      bodyColor: Colors.black,
      displayColor: Colors.black,
    );
  }

  static CardTheme _defaultCardTheme() {
    return CardTheme(
      color: Colors.white,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  static AppBarTheme _defaultAppBarTheme() {
    return const AppBarTheme(
      backgroundColor: Color.fromRGBO(146, 35, 56, 1),
      foregroundColor: Colors.white,
    );
  }

  static ElevatedButtonThemeData _defaultElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(146, 35, 56, 1),
        foregroundColor: Colors.white,
      ),
    );
  }

  static OutlinedButtonThemeData _defaultOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color.fromRGBO(146, 35, 56, 1)),
        foregroundColor: const Color.fromRGBO(146, 35, 56, 1),
      ),
    );
  }

  static Future<void> updateTheme(ThemeData newTheme) async {
    _currentTheme = newTheme;
    _themeChangeNotifier.value = newTheme;
    await saveThemeToPrefs();
  }

  static Future<void> saveThemeToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, String> themeData = {
        'primaryColor': _currentTheme.primaryColor.value.toString(),
        'secondaryColor': _currentTheme.colorScheme.secondary.value.toString(),
        'backgroundColor':
            _currentTheme.scaffoldBackgroundColor.value.toString(),
        'primaryTextColor':
            (_currentTheme.textTheme.bodyLarge?.color ?? Colors.black)
                .value
                .toString(),
        'secondaryTextColor':
            _currentTheme.colorScheme.onPrimary.value.toString(),
        'cardColor': _currentTheme.cardColor.value.toString(),
      };
      await prefs.setString('app_theme', jsonEncode(themeData));
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  static Future<void> loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? themeStr = prefs.getString('app_theme');
      if (themeStr != null) {
        final Map<String, dynamic> themeData = jsonDecode(themeStr);
        final newTheme = createTheme(
          primaryColor: Color(int.parse(themeData['primaryColor'])),
          secondaryColor: Color(int.parse(themeData['secondaryColor'])),
          backgroundColor: Color(int.parse(themeData['backgroundColor'])),
          primaryTextColor: Color(int.parse(themeData['primaryTextColor'])),
          secondaryTextColor: Color(int.parse(themeData['secondaryTextColor'])),
          cardColor: Color(int.parse(themeData['cardColor'])),
        );
        _currentTheme = newTheme;
        _themeChangeNotifier.value = newTheme;
      }
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

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
        onPrimary: secondaryTextColor,
        onSecondary: primaryTextColor,
        onSurface: primaryTextColor,
      ),
      iconTheme: IconThemeData(color: primaryColor),
      textTheme: const TextTheme().apply(
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
        foregroundColor: secondaryTextColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: secondaryTextColor,
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

  static Future<void> resetToDefault() async {
    _currentTheme = _defaultTheme();
    _themeChangeNotifier.value = _currentTheme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('app_theme');
  }
}
