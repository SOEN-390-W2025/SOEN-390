import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_directions_api/google_directions_api.dart' as gda;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../domain-model/location.dart';

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
    String originAddress,
    String destinationAddress, {
    gda.TravelMode? transport,
  }) async {
    final routeResult = await fetchRouteResult(
      originAddress: originAddress,
      destinationAddress: destinationAddress,
      travelMode: transport ?? gda.TravelMode.driving, // default to driving
    );

    if (routeResult.polyline != null) {
      return routeResult.polyline!.points;
    } else {
      throw Exception("No route found or polyline is missing.");
    }
  }

  /// Fetches a route using origin coordinates and a destination address.
  Future<List<LatLng>> fetchRouteFromCoords(
    LatLng origin,
    LatLng destination, {
    gda.TravelMode? transport,
  }) async {
    final originString = "${origin.latitude},${origin.longitude}";
    final destinationString =
        "${destination.latitude},${destination.longitude}";
    return fetchRoute(originString, destinationString, transport: transport);
  }

  /// Fetches a static map URL based on the origin and destination addresses.
  Future<String?> fetchStaticMapUrl({
    required String originAddress,
    required String destinationAddress,
    required int width,
    required int height,
  }) async {
    const String baseUrl = "https://maps.googleapis.com/maps/api/staticmap";
    final String sizeParam = "${width}x$height";
    final String markers =
        "markers=icon:http://maps.google.com/mapfiles/kml/shapes/man.png|$originAddress"
        "&markers=icon:http://maps.google.com/mapfiles/kml/paddle/red-stars.png|$destinationAddress";

    final request = gda.DirectionsRequest(
      origin: originAddress,
      destination: destinationAddress,
    );

    final Completer<String?> completer = Completer();

    await directionsService.route(request,
        (gda.DirectionsResult result, gda.DirectionsStatus? status) {
      if (status == gda.DirectionsStatus.ok &&
          result.routes != null &&
          result.routes!.isNotEmpty) {
        final route = result.routes!.first;
        final encodedPolyline = route.overviewPolyline?.points;

        if (encodedPolyline != null && encodedPolyline.isNotEmpty) {
          final String path =
              "path=color:0xDE3355|weight:5|enc:$encodedPolyline";
          completer.complete(
              "$baseUrl?size=$sizeParam&$markers&$path&key=${dotenv.env['GOOGLE_MAPS_API_KEY']}");
          return;
        }
      }

      // Fallback: No route available, show markers only
      completer.complete(
          "$baseUrl?size=$sizeParam&$markers&key=${dotenv.env['GOOGLE_MAPS_API_KEY']}");
    });

    return completer.future;
  }

  /// Returns a travel time (in seconds) between two [Location] objects.
  /// If no [travelMode] is specified, then the default is "walking".
  ///
  /// In case of an error, the duration time gets returned as 0 seconds.
  // Future<int> getTravelTimeInSeconds(
  //   Location origin,
  //   Location destination, {
  //   gda.TravelMode? travelMode,
  // }) async {
  //   try {
  //     final request = gda.DirectionsRequest(
  //       origin: "${origin.lat},${origin.lng}",
  //       destination: "${destination.lat},${destination.lng}",
  //       travelMode: travelMode ?? gda.TravelMode.walking,
  //     );

  //     final Completer<int> completer = Completer();
  //     await directionsService.route(request,
  //         (gda.DirectionsResult result, gda.DirectionsStatus? status) {
  //       if (status == gda.DirectionsStatus.ok &&
  //           result.routes != null &&
  //           result.routes!.isNotEmpty) {
  //         final route = result.routes!.first;
  //         final leg =
  //             route.legs?.isNotEmpty ?? false ? route.legs!.first : null;
  //         final durationInSeconds = leg?.duration?.value;
  //         completer.complete(durationInSeconds as FutureOr<int>?);
  //       } else {
  //         completer.complete(0);
  //       }
  //     });

  //     return completer.future;
  //   } on Error catch (e, stackTrace) {
  //     debugPrint("Error fetching travel time: $e");
  //     debugPrint("Stack trace: $stackTrace");
  //     return 0;
  //   }
  // }
}
