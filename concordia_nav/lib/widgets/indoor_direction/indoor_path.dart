import 'package:flutter/material.dart';

class IndoorMapPainter extends CustomPainter {
  final Offset startLocation;
  final Offset endLocation;

  IndoorMapPainter({
    required this.startLocation,
    required this.endLocation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the line
    final path = Path();
    path.moveTo(startLocation.dx, startLocation.dy);
    path.lineTo(endLocation.dx, endLocation.dy);

    final pathPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;
    canvas.drawPath(path, pathPaint);

    // Draw start marker
    final startPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(startLocation, 10, startPaint); // Adjust radius as needed

    // Draw end marker
     _drawIcon(canvas, endLocation, Icons.location_on, Colors.red);
  }

  // Helper method to draw an icon on the canvas
  void _drawIcon(Canvas canvas, Offset position, IconData iconData, Color color) {
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        color: color,
        fontSize: 30.0,
        fontFamily: iconData.fontFamily,
      ),
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset(position.dx - (textPainter.width / 2), position.dy - (textPainter.height / 2)));
  }

  @override
  bool shouldRepaint(IndoorMapPainter oldDelegate) {
    return oldDelegate.startLocation != startLocation ||
        oldDelegate.endLocation != endLocation;
  }
}