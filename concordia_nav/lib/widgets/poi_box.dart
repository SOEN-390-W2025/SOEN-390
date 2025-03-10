import 'package:flutter/material.dart';

class PoiBox extends StatelessWidget {
  final String title;
  final Icon icon;
  final double iconSize;
  final VoidCallback? onPress;

  const PoiBox({
    required this.title,
    required this.icon,
    required this.onPress,
    this.iconSize = 30.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 165.0,
      height: 85.0,
      child: GestureDetector(
        onTap: onPress,
        child: Card(
          color: const Color.fromARGB(255, 240, 240, 240),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title and Icon
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  icon.icon,
                  size: iconSize,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
