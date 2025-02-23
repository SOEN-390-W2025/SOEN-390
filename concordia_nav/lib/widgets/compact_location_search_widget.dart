import 'package:flutter/material.dart';

class CompactSearchCardWidget extends StatelessWidget {
  final TextEditingController originController;
  final TextEditingController destinationController;

  const CompactSearchCardWidget({
    super.key,
    required this.originController,
    required this.destinationController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.radio_button_checked,
                  color: Color.fromRGBO(146, 35, 56, 1),
                ),
                VerticalDottedLine(
                  height: 20,
                  color: Colors.grey,
                  dashHeight: 3,
                  dashSpace: 3,
                  strokeWidth: 2,
                ),
                Icon(
                  Icons.location_on,
                  color: Color(0xFFDA3A16),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: originController,
                      style: const TextStyle(fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: 'Your Location',
                        border: InputBorder.none,
                        isDense: true,
                        hintStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Colors.grey[300],
                    ),
                    TextField(
                      controller: destinationController,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Destination',
                        border: InputBorder.none,
                        isDense: true,
                        hintStyle: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  final Color color;
  final double dashHeight;
  final double dashSpace;
  final double strokeWidth;

  DottedLinePainter({
    required this.color,
    this.dashHeight = 4,
    this.dashSpace = 4,
    this.strokeWidth = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(DottedLinePainter oldDelegate) => false;
}

class VerticalDottedLine extends StatelessWidget {
  final double height;
  final Color color;
  final double dashHeight;
  final double dashSpace;
  final double strokeWidth;

  const VerticalDottedLine({
    super.key,
    required this.height,
    this.color = Colors.grey,
    this.dashHeight = 4,
    this.dashSpace = 4,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(1, height),
      painter: DottedLinePainter(
        color: color,
        dashHeight: dashHeight,
        dashSpace: dashSpace,
        strokeWidth: strokeWidth,
      ),
    );
  }
}
