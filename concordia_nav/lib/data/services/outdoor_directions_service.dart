import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_directions_api/google_directions_api.dart' as gda;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OutdoorRouteResult {
  final Polyline? polyline;
  final String travelTime;
  OutdoorRouteResult({this.polyline, required this.travelTime});
}

/// This service leverages the google_directions_api package to communicate with the
/// Google Directions API, retrieving route information which includes an encoded polyline.
class ODSDirectionsService {
  static final ODSDirectionsService _instance =
      ODSDirectionsService._internal();
  gda.DirectionsService directionsService = gda.DirectionsService();

  // Flag to ensure the DirectionsService is initialized only once.
  static bool _initialized = false;

  factory ODSDirectionsService() {
    if (!_initialized) {
      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
      if (apiKey == null) {
        throw Exception("API_KEY not found in environment variables.");
      }
      gda.DirectionsService.init(apiKey);
      _initialized = true;
    }
    return _instance;
  }

  // Private constructor for singleton pattern.
  ODSDirectionsService._internal();

  /// Fetches a route between the given origin and destination addresses.
  ///
  /// This method builds a [gda.DirectionsRequest] with the given parameters,
  /// sends the request using the Directions API, and decodes the returned
  /// polyline into a Flutter [Polyline]. It also extracts the travel duration
  /// (if available) from the route leg.
  ///
  /// [travelMode] allows the mode (driving, walking, etc.) to be specified.
  /// The polyline's [color] and [width] can be customized, if need be.
  Future<OutdoorRouteResult> fetchRouteResult({
    required String originAddress,
    required String destinationAddress,
    required gda.TravelMode travelMode,
    String polylineId = "route",
    Color color = const Color(0xFF2196F3),
    int width = 5,
  }) async {
    final Completer<OutdoorRouteResult> completer = Completer();
    final request = gda.DirectionsRequest(
      origin: originAddress,
      destination: destinationAddress,
      travelMode: travelMode,
    );
    await directionsService.route(request,
        (gda.DirectionsResult result, gda.DirectionsStatus? status) {
      if (status == gda.DirectionsStatus.ok &&
          result.routes != null &&
          result.routes!.isNotEmpty) {
        final route = result.routes!.first;
        final encodedPolyline = route.overviewPolyline?.points;
        // Extract the first leg to obtain the duration string.
        final leg =
            (route.legs?.isNotEmpty ?? false) ? route.legs!.first : null;
        final travelTime = leg?.duration?.text ?? "--";
        if (encodedPolyline != null) {
          final polylinePoints = PolylinePoints();
          final decodedPoints = polylinePoints.decodePolyline(encodedPolyline);
          final polylineCoordinates = decodedPoints
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList();
          final polyline = Polyline(
            polylineId: PolylineId(polylineId),
            points: polylineCoordinates,
            color: color,
            patterns: [PatternItem.dot, PatternItem.gap(10)],
            width: width,
          );
          completer.complete(
              OutdoorRouteResult(polyline: polyline, travelTime: travelTime));
        } else {
          completer.complete(
              OutdoorRouteResult(polyline: null, travelTime: travelTime));
        }
      } else {
        completer
            .complete(OutdoorRouteResult(polyline: null, travelTime: "--"));
      }
    });
    return completer.future;
  }

  /// Helper method to fetch a walking route as a [Polyline].
  Future<Polyline?> fetchWalkingPolyline({
    required String originAddress,
    required String destinationAddress,
    String polylineId = "walking_route",
    Color color = const Color(0xFF0c79fe),
    int width = 5,
  }) async {
    final result = await fetchRouteResult(
      originAddress: originAddress,
      destinationAddress: destinationAddress,
      travelMode: gda.TravelMode.walking,
      polylineId: polylineId,
      color: color,
      width: width,
    );
    return result.polyline;
  }

  /// A helper method to fetch a driving route as a list of [LatLng] points.
  /// This is maintained for backward compatibility with `fetchRouteFromCoords()`.
  Future<List<LatLng>> fetchRoute(
      String originAddress, String destinationAddress) async {
    final routeResult = await fetchRouteResult(
      originAddress: originAddress,
      destinationAddress: destinationAddress,
      travelMode: gda.TravelMode.driving, // default to driving
    );
    if (routeResult.polyline != null) {
      return routeResult.polyline!.points;
    } else {
      throw Exception("No route found or polyline is missing.");
    }
  }

  /// Fetches a route using origin coordinates and a destination address.
  Future<List<LatLng>> fetchRouteFromCoords(
      LatLng origin, LatLng destination) async {
    final originString = "${origin.latitude},${origin.longitude}";
    final destinationString =
        "${destination.latitude},${destination.longitude}";
    return fetchRoute(originString, destinationString);
  }

  /// Fetches a static map URL based on the origin and destination addresses.
  Future<String?> fetchStaticMapUrl({
    required String originAddress,
    required String destinationAddress,
    required int width,
    required int height,
    String sourceLabel = 'S',
    String destinationLabel = 'D',
  }) async {
    final request = gda.DirectionsRequest(
      origin: originAddress,
      destination: destinationAddress,
      travelMode: gda.TravelMode.driving,
    );
    final Completer<String?> completer = Completer();
    await directionsService.route(request,
        (gda.DirectionsResult result, gda.DirectionsStatus? status) {
      if (status == gda.DirectionsStatus.ok &&
          result.routes != null &&
          result.routes!.isNotEmpty) {
        final route = result.routes!.first;
        final encodedPolyline = route.overviewPolyline?.points;
        if (encodedPolyline != null) {
          const String baseUrl =
              "https://maps.googleapis.com/maps/api/staticmap";
          final String sizeParam = "${width}x$height";
          final String markers =
              "markers=color:green|label:$sourceLabel|$originAddress"
              "&markers=color:red|label:$destinationLabel|$destinationAddress";
          final String path = "path=color:2c99f3|weight:5|enc:$encodedPolyline";
          final String? apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
          final staticMapUrl =
              "$baseUrl?size=$sizeParam&$markers&$path&key=$apiKey";
          completer.complete(staticMapUrl);
          return;
        }
      }
      completer.complete(null);
    });
    return completer.future;
  }
}
