import 'package:flutter/material.dart';
import '../../../widgets/accessibility_tile.dart';

class AccessibilityPage extends StatelessWidget {
  const AccessibilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Accessibility',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        children: [
          const AccessibilityTile(
            title: 'Visual Accessibility',
            subOptions: [
              {'title': 'Text size and style'},
              {'title': 'High contrast mode'},
              {'title': 'Color adjustment'},
              {'title': 'Screen magnification'},
              {'title': 'Dark mode'},
              {'title': 'Text-to-speech'},
            ],
          ),
          const AccessibilityTile(
            title: 'Hearing Accessibility',
            subOptions: [
              {'title': 'Subtitles and captions'},
              {'title': 'Visual alerts'},
              {'title': 'Hearing aid compatibility'},
              {'title': 'Mono audio'},
            ],
          ),
          const AccessibilityTile(
            title: 'Physical and Motor Accessibility',
            subOptions: [
              {'title': 'Keyboard shortcuts'},
              {'title': 'Voice commands'},
              {'title': 'Customizable gestures'},
              {'title': 'Assistive touch'},
              {'title': 'Dwell timing'},
            ],
          ),
          const AccessibilityTile(
            title: 'Cognitive Accessibility',
            subOptions: [
              {'title': 'Simplified interface'},
              {'title': 'Reading assistance'},
              {'title': 'Context summaries'},
              {'title': 'Time extension'},
            ],
          ),
          const AccessibilityTile(
            title: 'General Accessibility',
            subOptions: [
              {'title': 'Customizable controls'},
              {'title': 'On-Screen keyboard'},
              {'title': 'Real-time translation'},
              {'title': 'Feedback'},
            ],
          ),
        ],
      ),
    );
  }
}
