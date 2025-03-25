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
      appBar: customAppBar(context, 'Accessibility'),
      body: Semantics(
        label: 'Explore general accessibility options.',
        child: Container(
          color: backgroundColor,
          child: ListView(
            children: _buildAccessibilityTiles(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAccessibilityTiles(BuildContext context) {
    const accessibilityOptions = <Map<String, dynamic>>[
      {
        'title': 'Visual Accessibility',
        'subOptions': [
          'Color adjustment',
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
        subOptions: (option['subOptions'] as List<String>).map((title) {
          return {
            'title': title,
            'onTap': () => _handleSubOptionTap(context, title),
          };
        }).toList(),
      );
    }).toList();
  }

  void _handleSubOptionTap(BuildContext context, String option) {
    switch (option) {
      case 'Color adjustment':
        Navigator.pushNamed(context, '/ColorAdjustmentView');
        break;

      case 'Text-to-speech':
        dev.log('Text-to-Speech enabled');
        break;

      case 'Subtitles and captions':
        dev.log('Subtitles enabled');
        break;

      case 'Visual alerts':
        dev.log('Flashing alerts activated');
        break;

      case 'Hearing aid compatibility':
        dev.log('Hearing aid compatibility turned on');
        break;

      case 'Mono audio':
        dev.log('Mono audio enabled');
        break;

      case 'Keyboard shortcuts':
        dev.log('Keyboard shortcuts opened');
        break;

      case 'Voice commands':
        dev.log('Voice command settings opened');
        break;

      case 'Customizable gestures':
        dev.log('Gesture settings updated');
        break;

      case 'Assistive touch':
        dev.log('Assistive touch activated');
        break;

      case 'Dwell timing':
        dev.log('Dwell timing adjusted');
        break;

      case 'Simplified interface':
        dev.log('Simplified mode enabled');
        break;

      case 'Reading assistance':
        dev.log('Reading assistance enabled');
        break;

      case 'Context summaries':
        dev.log('Context summaries activated');
        break;

      case 'Time extension':
        dev.log('Extended time granted');
        break;

      case 'Customizable controls':
        dev.log('Control customization opened');
        break;

      case 'On-Screen keyboard':
        dev.log('On-Screen keyboard activated');
        break;

      case 'Real-time translation':
        dev.log('Real-time translation enabled');
        break;

      case 'Feedback':
        dev.log('Feedback form opened');
        break;

      default:
        dev.log('Unknown option selected');
    }
  }
}