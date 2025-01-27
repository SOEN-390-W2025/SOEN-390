import 'package:flutter/material.dart';
import 'package:concordia_nav/view/homepage_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromRGBO(146, 35, 56, 1),
      ),
      home: HomePage(),
    );
  }
}
