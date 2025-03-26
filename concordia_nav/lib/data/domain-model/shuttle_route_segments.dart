import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteSegments {
  final Polyline? leg1;
  final Polyline leg2;
  final Polyline? leg3;

  RouteSegments({
    required this.leg1,
    required this.leg2,
    required this.leg3,
  });
}
