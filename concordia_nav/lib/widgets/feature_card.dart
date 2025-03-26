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
    // Get theme colors
    final cardColor = Theme.of(context).cardColor;
    final primaryColor = Theme.of(context).primaryColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    
    return Semantics(
      button: true,
      label: '$title feature. Double tap to activate.',
      child: SizedBox(
        width: 165.0,
        height: 165.0,
        child: GestureDetector(
          onTap: onPress,
          child: Card(
            elevation: 4.0,
            color: cardColor,
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
                      color: primaryColor,
                      semanticLabel: title,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}