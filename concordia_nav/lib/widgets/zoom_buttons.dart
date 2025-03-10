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
    return Material(
      color: Colors.white, // Ensures it looks the same
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: isZoomInButton ? const Radius.circular(16) : Radius.zero,
          topRight: isZoomInButton ? const Radius.circular(16) : Radius.zero,
          bottomLeft: !isZoomInButton ? const Radius.circular(16) : Radius.zero,
          bottomRight:
              !isZoomInButton ? const Radius.circular(16) : Radius.zero,
        ),
      ),
      elevation: 3, // Matches the shadow effect
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.only(
          topLeft: isZoomInButton ? const Radius.circular(16) : Radius.zero,
          topRight: isZoomInButton ? const Radius.circular(16) : Radius.zero,
          bottomLeft: !isZoomInButton ? const Radius.circular(16) : Radius.zero,
          bottomRight:
              !isZoomInButton ? const Radius.circular(16) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Icon(icon, color: Colors.black),
        ),
      ),
    );
  }
}
