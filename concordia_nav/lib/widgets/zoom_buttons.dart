// map_controller_button.dart

import 'package:flutter/material.dart';

class ZoomButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final bool isZoomInButton;

  const ZoomButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.isZoomInButton,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: isZoomInButton ? const Radius.circular(16) : Radius.zero,
            topRight: isZoomInButton ? const Radius.circular(16) : Radius.zero,
            bottomLeft:
                !isZoomInButton ? const Radius.circular(16) : Radius.zero,
            bottomRight:
                !isZoomInButton ? const Radius.circular(16) : Radius.zero,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 3,
              offset: Offset(0, 1), // Shadow position
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }
}
