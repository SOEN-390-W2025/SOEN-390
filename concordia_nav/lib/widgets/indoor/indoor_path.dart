// ignoreforfile: unusedfield

import 'package:flutter/material.dart';
import '../../data/domain-model/connection.dart';
import '../../data/domain-model/floor_routable_point.dart';
import '../../data/domain-model/indoor_route.dart';

class IndoorMapPainter extends CustomPainter {
  final IndoorRoute? route;
  final Offset startLocation;
  final Offset endLocation;
  final bool highlightCurrentStep;
  final Offset? currentStepPoint;
  final bool showStepView;

  // Paint objects defined once to avoid recreation on each paint call
  final Paint routePaint = Paint()
    ..color = Colors.blue
    ..strokeWidth = 4.0
    ..style = PaintingStyle.stroke;

  final Paint highlightPaint = Paint()
    ..color = Colors.yellow
    ..strokeWidth = 5.0
    ..style = PaintingStyle.stroke;

  final Paint startPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  final Paint endPaint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.fill;

  final Paint connectionPaint = Paint()
    ..color = Colors.purple
    ..style = PaintingStyle.fill;

  final Paint currentStepPaint = Paint()
    ..color = Colors.orange
    ..strokeWidth = 10.0
    ..style = PaintingStyle.fill;

  final Paint firstPortionPaint = Paint()
    ..color = Colors.blue
    ..strokeWidth = 5
    ..style = PaintingStyle.stroke;

  final Paint secondPortionPaint = Paint()
    ..color = Colors.green
    ..strokeWidth = 5
    ..style = PaintingStyle.stroke;

  final Paint connectionLinePaint = Paint()
    ..color = Colors.orange
    ..strokeWidth = 5
    ..style = PaintingStyle.stroke;

  IndoorMapPainter({
    required this.route,
    required this.startLocation,
    required this.endLocation,
    this.highlightCurrentStep = false,
    this.currentStepPoint,
    this.showStepView = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (showStepView) {
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    }

    if (route == null) return;

    showStepView ? drawStepView(canvas) : drawFullView(canvas);
  }

  void drawStepView(Canvas canvas) {
    // Draw all path segments
    drawPath(canvas, route!.firstIndoorPortionToConnection);
    drawPath(canvas, route!.firstIndoorPortionFromConnection);

    // Draw connections
    if (route!.firstIndoorConnection != null) {
      drawConnection(canvas, route!.firstIndoorConnection!);
    }

    // Draw second building parts if they exist
    if (route!.secondIndoorPortionToConnection != null) {
      drawPath(canvas, route!.secondIndoorPortionToConnection);
    }

    if (route!.secondIndoorConnection != null) {
      drawConnection(canvas, route!.secondIndoorConnection!);
    }

    if (route!.secondIndoorPortionFromConnection != null) {
      drawPath(canvas, route!.secondIndoorPortionFromConnection);
    }

    // Draw start and end points
    canvas.drawCircle(startLocation, 6.0, startPaint);
    canvas.drawCircle(endLocation, 6.0, endPaint);

    // Draw current step indicator if highlighting is enabled
    if (highlightCurrentStep && currentStepPoint != null) {
      canvas.drawCircle(currentStepPoint!, 12.0, currentStepPaint);
    }
  }

  void drawFullView(Canvas canvas) {
    drawComplexRoute(canvas);
    drawStartEndPoints(canvas);
  }

  void drawIcon(
      Canvas canvas, Offset position, IconData iconData, Color color) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          color: color,
          fontSize: 40.0,
          fontFamily: iconData.fontFamily,
        ),
      ),
    );

    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(position.dx - (textPainter.width / 2),
            position.dy - (textPainter.height / 1.2)));
  }

  void drawPath(Canvas canvas, List<FloorRoutablePoint>? points) {
    if (points == null || points.isEmpty) return;

    final path = Path();
    path.moveTo(points.first.positionX, points.first.positionY);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].positionX, points[i].positionY);
    }

    // If highlighting current step and we have a current step point
    if (highlightCurrentStep && currentStepPoint != null) {
      // First draw normal path
      canvas.drawPath(path, routePaint);

      // Then draw highlighted segment near current step point
      drawHighlightedSegmentNearPoint(canvas, points, currentStepPoint!);
    } else {
      // Just draw normal path
      canvas.drawPath(path, routePaint);
    }
  }

  void drawHighlightedSegmentNearPoint(
      Canvas canvas, List<FloorRoutablePoint> points, Offset targetPoint) {
    if (points.isEmpty || points.length < 3) return;

    // Find the closest segment to the target point
    double minDistance = double.infinity;
    int closestSegmentStart = 0;

    for (int i = 0; i < points.length - 1; i++) {
      final start = Offset(points[i].positionX, points[i].positionY);
      final end = Offset(points[i + 1].positionX, points[i + 1].positionY);

      final distance = distanceToSegment(targetPoint, start, end);
      if (distance < minDistance) {
        minDistance = distance;
        closestSegmentStart = i;
      }
    }

    // Draw two highlighted segments
    if (closestSegmentStart != 0 && closestSegmentStart != points.length - 2) {
      final highlightPath = Path();

      // First segment
      final start1 = points[closestSegmentStart + 1];
      final end1 = points[closestSegmentStart + 2];

      highlightPath.moveTo(start1.positionX, start1.positionY);
      highlightPath.lineTo(end1.positionX, end1.positionY);

      // Second segment
      final start2 = points[closestSegmentStart + 2];
      final end2 = points[closestSegmentStart + 3];

      // Create a separate path movement for the second line to ensure both are drawn
      highlightPath.moveTo(start2.positionX, start2.positionY);
      highlightPath.lineTo(end2.positionX, end2.positionY);

      canvas.drawPath(highlightPath, highlightPaint);
    }
  }

  double distanceToSegment(Offset p, Offset v, Offset w) {
    final l2 = (v - w).distanceSquared;
    if (l2 == 0) return (p - v).distance;

    var t =
        ((p.dx - v.dx) * (w.dx - v.dx) + (p.dy - v.dy) * (w.dy - v.dy)) / l2;
    t = t.clamp(0.0, 1.0);

    final projection =
        Offset(v.dx + t * (w.dx - v.dx), v.dy + t * (w.dy - v.dy));

    return (p - projection).distance;
  }

  void drawConnection(Canvas canvas, Connection connection) {
    for (final entry in connection.floorPoints.entries) {
      for (final point in entry.value) {
        canvas.drawCircle(
            Offset(point.positionX, point.positionY), 8.0, connectionPaint);
      }
    }
  }

  void drawStartEndPoints(Canvas canvas) {
    // Draw start point
    canvas.drawCircle(startLocation, 10, startPaint);

    // Draw end point with icon
    drawIcon(canvas, endLocation, Icons.location_on, Colors.red);
  }

  void drawComplexRoute(Canvas canvas) {
    // Draw first indoor portion (to connection)
    if (route!.firstIndoorPortionToConnection != null) {
      drawRoutePortion(canvas, route!.firstIndoorPortionToConnection!,
          firstPortionPaint, startLocation);
    }

    // Draw connection if exists
    if (route!.firstIndoorConnection != null) {
      drawConnection(canvas, route!.firstIndoorConnection!);
    }

    // Draw first indoor portion from connection
    if (route!.firstIndoorPortionFromConnection != null) {
      drawRoutePortion(canvas, route!.firstIndoorPortionFromConnection!,
          firstPortionPaint, null);
    }

    // Repeat for second building (if exists)
    if (route!.secondIndoorPortionToConnection != null) {
      drawRoutePortion(canvas, route!.secondIndoorPortionToConnection!,
          secondPortionPaint, null);
    }

    if (route!.secondIndoorConnection != null) {
      drawConnection(canvas, route!.secondIndoorConnection!);
    }

    if (route!.secondIndoorPortionFromConnection != null) {
      drawRoutePortion(canvas, route!.secondIndoorPortionFromConnection!,
          secondPortionPaint, endLocation);
    }
  }

  void drawRoutePortion(Canvas canvas, List<FloorRoutablePoint> routePoints,
      Paint paint, Offset? startPoint) {
    if (routePoints.isEmpty) return;

    final path = Path();

    // Start from provided start point or first route point
    final firstRouteOffset =
        Offset(routePoints.first.positionX, routePoints.first.positionY);

    path.moveTo(startPoint?.dx ?? firstRouteOffset.dx,
        startPoint?.dy ?? firstRouteOffset.dy);

    // Draw route points
    for (var point in routePoints) {
      path.lineTo(point.positionX, point.positionY);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant IndoorMapPainter oldDelegate) {
    return oldDelegate.route != route ||
        oldDelegate.startLocation != startLocation ||
        oldDelegate.endLocation != endLocation ||
        oldDelegate.highlightCurrentStep != highlightCurrentStep ||
        oldDelegate.currentStepPoint != currentStepPoint ||
        oldDelegate.showStepView != showStepView;
  }
}
