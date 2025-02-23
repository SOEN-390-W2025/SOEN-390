import 'package:flutter/material.dart';
import '../../../widgets/custom_appbar.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Calendar'),
      body: const Center(
        child: Text('Calendar'),
      ),
    );
  }
}
