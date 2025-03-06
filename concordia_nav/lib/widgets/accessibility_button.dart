import 'package:flutter/material.dart';

class AccessibilityButton extends StatefulWidget {
  final String sourceRoom;
  final String endRoom;
  final bool disability;
  final Function(bool) onDisabilityChanged;

  const AccessibilityButton({
    super.key,
    required this.sourceRoom,
    required this.endRoom,
    required this.disability,
    required this.onDisabilityChanged,
  });

  @override
  State<AccessibilityButton> createState() => _AccessibilityButtonState();
}

class _AccessibilityButtonState extends State<AccessibilityButton> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      child: InkWell(
        onTap: () {
          widget.onDisabilityChanged(!widget.disability); // Change the state when tapped
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 45,
          height: 45,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.disability ? Theme.of(context).primaryColor : Colors.white, // Color changes based on state
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            Icons.accessible,
            color: widget.disability ? Colors.white : Theme.of(context).primaryColor // Icon color to maintain visibility
          ),
        ),
      ),
    );
  }
}
