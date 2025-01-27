import 'package:flutter/material.dart';

// Custom FeatureCard Widget with a fixed size
class FeatureCard extends StatelessWidget {
  final String title;
  final Icon icon;
  final double iconSize;

  const FeatureCard({
    required this.title,
    required this.icon,
    this.iconSize = 50.0, // Default icon size
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 165.0, // Set a fixed width for the card
      height: 165.0, // Set a fixed height for the card
      child: Card(
        elevation: 4.0, // Add elevation for a shadow effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 16.0
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon.icon,
                size: iconSize,
                color: Theme.of(context).primaryColor,
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

          ),
        ),
      ),
    );
  }
}
