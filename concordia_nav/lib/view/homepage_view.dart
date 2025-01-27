import 'package:flutter/material.dart';
import 'package:concordia_nav/widgets/custom_appbar.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Home'),
      body: Center(
        child: Text('HomePage'),
      ),
    );
  }
}