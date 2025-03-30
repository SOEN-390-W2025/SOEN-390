import 'package:flutter/material.dart';

class GuideSegment extends StatelessWidget {
  final String title;
  final String description;
  final String? assetPath;
  
  const GuideSegment({
    super.key,
    required this.title,
    required this.description,
    this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.circle, size: 8, color: Colors.black),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
        if (assetPath != null) ...[
          Center(
            child: Card(
              elevation: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  assetPath!,
                  width: 200,
                ),
              ),
            ),
          ), 
        ],
        const SizedBox(height: 20),
      ],
    );
  }
}