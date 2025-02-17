import 'package:flutter/material.dart';

class BuildingInfoDrawerViewModel extends ChangeNotifier {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  Animation<Offset> get slideAnimation => _slideAnimation;

  void initializeAnimation(TickerProvider vsync) {
    _animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start off-screen (bottom)
      end: Offset.zero, // Slide up to visible position
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _animationController.forward(); // Start the animation when the widget initializes
  }

  void closeDrawer(VoidCallback onClose) {
    _animationController.reverse().then((_) {
      onClose(); // Notify the parent after animation completes
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
