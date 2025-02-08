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
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: ListView(
        children: _buildAccessibilityTiles(),
      ),
    );
  }

  List<Widget> _buildAccessibilityTiles() {
    const accessibilityOptions = <Map<String, dynamic>>[
      {
        'title': 'Visual Accessibility',
        'subOptions': [
          'Text size and style',
          'High contrast mode',
          'Color adjustment',
          'Screen magnification',
          'Dark mode',
          'Text-to-speech',
        ],
      },
      {
        'title': 'Hearing Accessibility',
        'subOptions': [
          'Subtitles and captions',
          'Visual alerts',
          'Hearing aid compatibility',
          'Mono audio',
        ],
      },
      {
        'title': 'Physical and Motor Accessibility',
        'subOptions': [
          'Keyboard shortcuts',
          'Voice commands',
          'Customizable gestures',
          'Assistive touch',
          'Dwell timing',
        ],
      },
      {
        'title': 'Cognitive Accessibility',
        'subOptions': [
          'Simplified interface',
          'Reading assistance',
          'Context summaries',
          'Time extension',
        ],
      },
      {
        'title': 'General Accessibility',
        'subOptions': [
          'Customizable controls',
          'On-Screen keyboard',
          'Real-time translation',
          'Feedback',
        ],
      },
    ];

    return accessibilityOptions.map((option) {
      return AccessibilityTile(
        title: option['title'] as String,
        subOptions: (option['subOptions'] as List<String>)
            .map((title) => {'title': title})
            .toList(),
      );
    }).toList();
  }
}
