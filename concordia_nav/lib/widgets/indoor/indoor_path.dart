// ignore_for_file: unused_field

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
  final Paint _routePaint = Paint()
    ..color = Colors.blue
    ..strokeWidth = 4.0
    ..style = PaintingStyle.stroke;

  final Paint _highlightPaint = Paint()
    ..color = Colors.yellow
    ..strokeWidth = 5.0
    ..style = PaintingStyle.stroke;

  final Paint _startPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  final Paint _endPaint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.fill;

  final Paint _connectionPaint = Paint()
    ..color = Colors.purple
    ..style = PaintingStyle.fill;

  final Paint _currentStepPaint = Paint()
    ..color = Colors.orange
    ..strokeWidth = 10.0
    ..style = PaintingStyle.fill;

  final Paint _firstPortionPaint = Paint()
    ..color = Colors.blue
    ..strokeWidth = 5
    ..style = PaintingStyle.stroke;

  final Paint _secondPortionPaint = Paint()
    ..color = Colors.green
    ..strokeWidth = 5
    ..style = PaintingStyle.stroke;

  final Paint _connectionLinePaint = Paint()
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
    
    showStepView ? _drawStepView(canvas) : _drawFullView(canvas);
  }

  void _drawStepView(Canvas canvas) {
    // Draw all path segments
    _drawPath(canvas, route!.firstIndoorPortionToConnection);
    _drawPath(canvas, route!.firstIndoorPortionFromConnection);

    // Draw connections
    if (route!.firstIndoorConnection != null) {
      _drawConnection(canvas, route!.firstIndoorConnection!);
    }

    // Draw second building parts if they exist
    if (route!.secondIndoorPortionToConnection != null) {
      _drawPath(canvas, route!.secondIndoorPortionToConnection);
    }

    if (route!.secondIndoorConnection != null) {
      _drawConnection(canvas, route!.secondIndoorConnection!);
    }

    if (route!.secondIndoorPortionFromConnection != null) {
      _drawPath(canvas, route!.secondIndoorPortionFromConnection);
    }

    // Draw start and end points
    canvas.drawCircle(startLocation, 6.0, _startPaint);
    canvas.drawCircle(endLocation, 6.0, _endPaint);

    // Draw current step indicator if highlighting is enabled
    if (highlightCurrentStep && currentStepPoint != null) {
      canvas.drawCircle(currentStepPoint!, 12.0, _currentStepPaint);
    }
  }

  void _drawFullView(Canvas canvas) {
    _drawComplexRoute(canvas);
    _drawStartEndPoints(canvas);
  }

  void _drawIcon(Canvas canvas, Offset position, IconData iconData, Color color) {
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
      Offset(position.dx - (textPainter.width / 2), position.dy - (textPainter.height / 1.2))
    );
  }

  void _drawPath(Canvas canvas, List<FloorRoutablePoint>? points) {
    if (points == null || points.isEmpty) return;

    final path = Path();
    path.moveTo(points.first.positionX, points.first.positionY);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].positionX, points[i].positionY);
    }

    // If highlighting current step and we have a current step point
    if (highlightCurrentStep && currentStepPoint != null) {
      // First draw normal path
      canvas.drawPath(path, _routePaint);

      // Then draw highlighted segment near current step point
      _drawHighlightedSegmentNearPoint(canvas, points, currentStepPoint!);
    } else {
      // Just draw normal path
      canvas.drawPath(path, _routePaint);
    }
  }

  void _drawHighlightedSegmentNearPoint(
    Canvas canvas, 
    List<FloorRoutablePoint> points, 
    Offset targetPoint
  ) {
    if (points.isEmpty) return;

    // Find the closest segment to the target point
    double minDistance = double.infinity;
    int closestSegmentStart = 0;

    for (int i = 0; i < points.length - 1; i++) {
      final start = Offset(points[i].positionX, points[i].positionY);
      final end = Offset(points[i + 1].positionX, points[i + 1].positionY);
      
      final distance = _distanceToSegment(targetPoint, start, end);
      if (distance < minDistance) {
        minDistance = distance;
        closestSegmentStart = i;
      }
    }

    // Draw the highlighted segment
    final highlightPath = Path();
    final start = points[closestSegmentStart];
    final end = points[closestSegmentStart + 1];
    
    highlightPath.moveTo(start.positionX, start.positionY);
    highlightPath.lineTo(end.positionX, end.positionY);
    
    canvas.drawPath(highlightPath, _highlightPaint);
  }

  double _distanceToSegment(Offset p, Offset v, Offset w) {
    final l2 = (v - w).distanceSquared;
    if (l2 == 0) return (p - v).distance;
    
    var t = ((p.dx - v.dx) * (w.dx - v.dx) + (p.dy - v.dy) * (w.dy - v.dy)) / l2;
    t = t.clamp(0.0, 1.0);
    
    final projection = Offset(
      v.dx + t * (w.dx - v.dx),
      v.dy + t * (w.dy - v.dy)
    );
    
    return (p - projection).distance;
  }

  void _drawConnection(Canvas canvas, Connection connection) {
    for (final entry in connection.floorPoints.entries) {
      for (final point in entry.value) {
        canvas.drawCircle(
          Offset(point.positionX, point.positionY), 
          8.0, 
          _connectionPaint
        );
      }
    }
  }

  void _drawStartEndPoints(Canvas canvas) {
    // Draw start point
    canvas.drawCircle(startLocation, 10, _startPaint);

    // Draw end point with icon
    _drawIcon(canvas, endLocation, Icons.location_on, Colors.red);
  }

  void _drawComplexRoute(Canvas canvas) {
    // Draw first indoor portion (to connection)
    if (route!.firstIndoorPortionToConnection != null) {
      _drawRoutePortion(
        canvas, 
        route!.firstIndoorPortionToConnection!, 
        _firstPortionPaint,
        startLocation
      );
    }

    // Draw connection if exists
    if (route!.firstIndoorConnection != null) {
      _drawConnection(canvas, route!.firstIndoorConnection!);
    }

    // Draw first indoor portion from connection
    if (route!.firstIndoorPortionFromConnection != null) {
      _drawRoutePortion(
        canvas, 
        route!.firstIndoorPortionFromConnection!, 
        _firstPortionPaint,
        null
      );
    }

    // Repeat for second building (if exists)
    if (route!.secondIndoorPortionToConnection != null) {
      _drawRoutePortion(
        canvas, 
        route!.secondIndoorPortionToConnection!, 
        _secondPortionPaint,
        null
      );
    }

    if (route!.secondIndoorConnection != null) {
      _drawConnection(canvas, route!.secondIndoorConnection!);
    }

    if (route!.secondIndoorPortionFromConnection != null) {
      _drawRoutePortion(
        canvas, 
        route!.secondIndoorPortionFromConnection!, 
        _secondPortionPaint,
        endLocation
      );
    }
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