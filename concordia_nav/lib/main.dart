import 'package:flutter/material.dart';
import 'package:concordia_nav/core/ui/themes/app_theme.dart';
import 'package:concordia_nav/core/ui/widgets/homepage_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.theme,
      home: HomePage(),
    );
  }
}
