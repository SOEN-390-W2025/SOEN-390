import 'package:flutter/material.dart';
import 'core/ui/themes/app_theme.dart';
import 'core/ui/widgets/homepage_view.dart';

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
