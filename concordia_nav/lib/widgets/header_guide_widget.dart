import 'package:flutter/material.dart';

class HeaderGuide extends StatelessWidget {
  final String title;
  final String description;
  final String assetPath;

  const HeaderGuide({
    super.key,
    required this.title,
    required this.description,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Center(
          child: Card(
            elevation: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                assetPath,
                width: 150,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "Key Features:",
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
      ],);
  }
}