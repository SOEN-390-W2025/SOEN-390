import 'package:google_maps_flutter/google_maps_flutter.dart';

enum ShuttleRouteDirection { campusLOYtoSGW, campusSGWtoLOY }

class ShuttleRouteDetails {
  final LatLng? originCoords;
  final LatLng? destinationCoords;
  final bool originNearLOY;
  final bool originNearSGW;
  final bool destNearLOY;
  final bool destNearSGW;
  final ShuttleRouteDirection? direction;
  final LatLng boardingStop;
  final LatLng disembarkStop;
  final String polylineIdSuffix;

  ShuttleRouteDetails({
    required this.originCoords,
    required this.destinationCoords,
    required this.originNearLOY,
    required this.originNearSGW,
    required this.destNearLOY,
    required this.destNearSGW,
    required this.direction,
    required this.boardingStop,
    required this.disembarkStop,
    required this.polylineIdSuffix,
  });
}
