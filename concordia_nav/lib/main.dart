import 'package:flutter/material.dart';
import 'ui/themes/app_theme.dart';
import 'ui/home/homepage_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.theme,
      home: const HomePage(),
    );
  }
}
