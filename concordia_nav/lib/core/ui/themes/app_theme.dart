import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: const Color.fromRGBO(146, 35, 56, 1),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: const Color.fromRGBO(233, 211, 215, 1),
      ),
      iconTheme: IconThemeData(
        color: const Color.fromRGBO(146, 35, 56, 1),
      ),
    );
  }
}