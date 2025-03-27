import 'package:flutter/material.dart';
import '../../../widgets/accessibility_tile.dart';
import '../../../widgets/custom_appbar.dart';
import 'dart:developer' as dev;

class AccessibilityPage extends StatelessWidget {
  const AccessibilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: customAppBar(context, 'Accessibility'),
      body: Semantics(
        label: 'Accessibility options page',
        hint: 'Explore and configure accessibility settings',
        child: Container(
          color: backgroundColor,
          child: ExcludeSemantics(
            // Exclude default semantics from ListView since we're adding custom ones
            child: ListView(
              children: _buildAccessibilityTiles(context),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAccessibilityTiles(BuildContext context) {
    const accessibilityOptions = <Map<String, dynamic>>[
      {
        'title': 'Visual Accessibility',
        'description': 'isual Accessibility options',
        'subOptions': [
          'Color adjustment',
          'Text-to-speech',
        ],
      },
      {
        'title': 'Cognitive Accessibility',
        'description': 'Cognitive Accessibility options',
        'subOptions': [
          'Context summaries',
        ],
      },
    ];

    return accessibilityOptions.map((option) {
      return Semantics(
        container: true,
        explicitChildNodes: true,
        label: option['title'] as String,
        hint: option['description'] as String,
        child: AccessibilityTile(
          title: option['title'] as String,
          subOptions: (option['subOptions'] as List<String>).map((title) {
            return {
              'title': title,
              'onTap': () => _handleSubOptionTap(context, title),
            };
          }).toList(),
        ),
      );
    }).toList();
  }

  void _handleSubOptionTap(BuildContext context, String option) {
    if (option == 'Color adjustment') {
      Navigator.pushNamed(context, '/ColorAdjustmentView');
      return;
    }
    if (option == 'Text-to-speech') {
      Navigator.pushNamed(context, '/TextToSpeechView');
      return;
    }

    final Map<String, String> logMessages = {
      'Context summaries': 'Context summaries activated',
    };

    dev.log(logMessages[option] ?? 'Unknown option selected');
  }
}
