import 'package:flutter/material.dart';
import '../../widgets/custom_appbar.dart';

class NavigationStepPage extends StatefulWidget {
  final String journeyName;
  final int pageCount;
  final Widget Function(int index) pageBuilder;

  const NavigationStepPage({
    super.key,
    required this.journeyName,
    required this.pageCount,
    required this.pageBuilder,
  });

  @override
  // ignore: library_private_types_in_public_api
  _NavigationStepPageState createState() => _NavigationStepPageState();
}

class _NavigationStepPageState extends State<NavigationStepPage> {
  int _currentIndex = 0;

  void _handleNext() {
    if (_currentIndex < widget.pageCount - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/HomePage',
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastStep = _currentIndex == widget.pageCount - 1;
    return Scaffold(
      appBar: customAppBar(context, widget.journeyName),
      body: Semantics(
        label: 'Navigation steps for your journey.',
        child: widget.pageBuilder(_currentIndex),
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF962E42),
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF962E42),
          ),
          onPressed: _handleNext,
          child: Text(
            isLastStep
                ? "Complete My Journey"
                : "Proceed to The Next Direction Step",
          ),
        ),
      ),
    );
  }
}
