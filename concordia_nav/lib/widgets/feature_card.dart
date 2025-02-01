import 'package:flutter/material.dart';

class FeatureCard extends StatelessWidget {
  final String title;
  final Icon icon;
  final double iconSize;
  final VoidCallback? onPress;

  const FeatureCard({
    required this.title,
    required this.icon,
    required this.onPress,
    this.iconSize = 40.0, // Reduced default icon size
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 165.0,
      height: 165.0,
      child: GestureDetector(
        onTap: onPress,
        child: Card(
          elevation: 4.0,
          color: const Color.fromARGB(255, 240, 240, 240),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 8.0, // Reduced padding
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Icon(
                    icon.icon,
                    size: iconSize,
                  ),
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
