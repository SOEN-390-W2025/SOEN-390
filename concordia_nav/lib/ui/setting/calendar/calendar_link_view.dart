import 'package:flutter/material.dart';
import '../../../widgets/custom_appbar.dart';

class CalendarLinkView extends StatelessWidget {
  const CalendarLinkView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Calendar Link'),
      body: Column(
        children: [
          const Text('There is currently no calendar'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Link'),)
        ],
      ),
    );
  }
}