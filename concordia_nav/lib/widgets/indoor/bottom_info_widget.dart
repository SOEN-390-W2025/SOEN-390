import 'package:flutter/material.dart';

class BottomInfoWidget extends StatelessWidget {
  final String eta;
  final VoidCallback? onNextFloor;
  final VoidCallback? onPrevFloor;

  const BottomInfoWidget({
    super.key,
    required this.eta,
    this.onNextFloor,
    this.onPrevFloor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                eta,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          Row(
            children: [
              if (onPrevFloor != null) // Show button only if available
                ElevatedButton(
                  onPressed: onPrevFloor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(146, 35, 56, 1),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                  ),
                  child: const Text(
                    'Prev',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: onNextFloor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(146, 35, 56, 1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                ),
                child: Text(
                  onNextFloor == null ? 'Start' : 'Next',
                  style: const TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(26),
          blurRadius: 8,
          offset: const Offset(0, -2),
        ),
      ],
    );
  }
}
