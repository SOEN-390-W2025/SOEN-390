import 'package:flutter/material.dart';
import '../../data/domain-model/indoor_route.dart';
import '../../data/domain-model/floor_routable_point.dart';
import '../../data/domain-model/connection.dart';

class IndoorMapPainter extends CustomPainter {
  final IndoorRoute? route;
  final Offset startLocation;
  final Offset endLocation;

  IndoorMapPainter({
    this.route,
    required this.startLocation,
    required this.endLocation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // If no route is provided, just draw start and end points
    if (route == null) {
      _drawStartEndPoints(canvas);
      return;
    }

    // Draw full route with different portions
    _drawComplexRoute(canvas);
  }

  void _drawStartEndPoints(Canvas canvas) {
    // Paint for start point (green circle)
    final startPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw start point
    canvas.drawCircle(startLocation, 10, startPaint);


    // Draw end point
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
        fontSize: 40.0,
        fontFamily: iconData.fontFamily,
      ),
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset(position.dx - (textPainter.width / 2), position.dy - (textPainter.height/ 1.2)));
  }

  void _drawComplexRoute(Canvas canvas) {
    // Route line paints with different colors
    final firstPortionPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final connectionPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final secondPortionPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    // Draw first indoor portion (to connection)
    if (route!.firstIndoorPortionToConnection != null) {
      _drawRoutePortion(
        canvas, 
        route!.firstIndoorPortionToConnection!, 
        firstPortionPaint,
        startLocation
      );
    }

    // Draw connection if exists
    if (route!.firstIndoorConnection != null) {
      _drawConnection(
        canvas, 
        route!.firstIndoorConnection!, 
        connectionPaint
      );
    }

    // Draw first indoor portion from connection
    if (route!.firstIndoorPortionFromConnection != null) {
      _drawRoutePortion(
        canvas, 
        route!.firstIndoorPortionFromConnection!, 
        firstPortionPaint,
        null
      );
    }

    // Repeat for second building (if exists)
    if (route!.secondIndoorPortionToConnection != null) {
      _drawRoutePortion(
        canvas, 
        route!.secondIndoorPortionToConnection!, 
        secondPortionPaint,
        null
      );
    }

    if (route!.secondIndoorConnection != null) {
      _drawConnection(
        canvas, 
        route!.secondIndoorConnection!, 
        connectionPaint
      );
    }

    if (route!.secondIndoorPortionFromConnection != null) {
      _drawRoutePortion(
        canvas, 
        route!.secondIndoorPortionFromConnection!, 
        secondPortionPaint,
        endLocation
      );
    }

    // Always draw start and end points
    _drawStartEndPoints(canvas);
  }

  void _drawRoutePortion(
    Canvas canvas, 
    List<FloorRoutablePoint> routePoints, 
    Paint paint,
    Offset? startPoint
  ) {
    if (routePoints.isEmpty) return;

    final path = Path();
    
    // Start from provided start point or first route point
    final firstRouteOffset = Offset(
      routePoints.first.positionX, 
      routePoints.first.positionY
    );
    
    path.moveTo(
      startPoint?.dx ?? firstRouteOffset.dx, 
      startPoint?.dy ?? firstRouteOffset.dy
    );

    // Draw route points
    for (var point in routePoints) {
      path.lineTo(point.positionX, point.positionY);
    }

    canvas.drawPath(path, paint);
  }

  void _drawConnection(
    Canvas canvas, 
    Connection connection, 
    Paint paint
  ) {
    // Implement connection drawing logic
    // This might involve drawing elevator or staircase routes
    // You'll need to implement specific logic based on your Connection class
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint to ensure updates
  }
}