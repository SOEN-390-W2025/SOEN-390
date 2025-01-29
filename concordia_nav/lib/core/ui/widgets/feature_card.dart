import 'package:flutter/material.dart';

// Custom FeatureCard Widget with a fixed size
class FeatureCard extends StatelessWidget {
  final String title;
  final Icon icon;
  final double iconSize;
  final VoidCallback? onPress;

  const FeatureCard({
    required this.title,
    required this.icon,
    required this.onPress,
    this.iconSize = 50.0, // Default icon size
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 165.0, // Set a fixed width for the card
      height: 165.0, // Set a fixed height for the card
      child: GestureDetector(
        onTap: onPress,
        child: Card(
          elevation: 4.0, // Add elevation for a shadow effect
          color: const Color.fromARGB(255, 240, 240, 240),
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
      ),
    );
  }
}
