import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_directions_api/google_directions_api.dart' as gda;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A service for fetching directions between two locations using the Google Directions API.
///
/// This service leverages the google_directions_api package to communicate with the
/// Google Directions API, retrieving route information which includes an encoded polyline.
/// The polyline is then decoded into a list of [LatLng] coordinates using the
/// flutter_polyline_points package. The API key for accessing the Google Directions API
/// is loaded from environment variables via the flutter_dotenv package.
class DirectionsService {
  // Singleton instance of DirectionsService.
  static final DirectionsService _instance = DirectionsService._internal();

  // Flag to ensure the DirectionsService is initialized only once.
  static bool _initialized = false;

  /// Factory constructor to return a singleton instance of [DirectionsService].
  ///
  /// Upon first instantiation, this constructor retrieves the API key from the environment
  /// variables and initializes the google_directions_api package with the provided key.
  /// Throws an [Exception] if the API key is not found.
  factory DirectionsService() {
    if (!_initialized) {
      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
      if (apiKey == null) {
        throw Exception("API_KEY not found in environment variables.");
      }
      // Initialize the Google Directions API with the provided API key.
      gda.DirectionsService.init(apiKey);
      _initialized = true;
    }
    return _instance;
  }

  // Private constructor for singleton pattern.
  DirectionsService._internal();

  /// Fetches a route between the given origin and destination addresses.
  ///
  /// This method constructs a [gda.DirectionsRequest] using the provided [originAddress]
  /// and [destinationAddress]. It sets the travel mode to driving (the default).
  ///
  /// The request is sent to the Google Directions API using the google_directions_api
  /// package. Once a response is received, the method verifies that the status is OK and
  /// that at least one route has been returned. It then extracts the encoded polyline
  /// from the first route's overview, which is subsequently decoded into a list of
  /// [LatLng] coordinates using the [PolylinePoints] class from the
  /// flutter_polyline_points package.
  ///
  /// Returns a [Future] that resolves to a list of [LatLng] coordinates representing the route,
  /// or an error if the route could not be fetched or the polyline is missing.
  Future<List<LatLng>> fetchRoute(
      String originAddress, String destinationAddress) async {
    final completer = Completer<List<LatLng>>();

    // Create a directions request with the specified origin, destination, and travel mode.
    final request = gda.DirectionsRequest(
      origin: originAddress,
      destination: destinationAddress,
      travelMode: gda.TravelMode.driving, // TODO: refactor in TASK-3.3.2
    );

    // Instantiate the directions service from the google_directions_api package.
    final directionsService = gda.DirectionsService();

    // Execute the route request with a callback to process the result.
    await directionsService.route(request,
        (gda.DirectionsResult result, gda.DirectionsStatus? status) {
      // Check if the request was successful and if at least one route was returned.
      if (status == gda.DirectionsStatus.ok &&
          result.routes != null &&
          result.routes!.isNotEmpty) {
        // Extract the encoded polyline from the first route.
        final encodedPolyline = result.routes!.first.overviewPolyline?.points;
        if (encodedPolyline != null) {
          // Decode the encoded polyline into a list of latitude/longitude points.
          final PolylinePoints polylinePoints = PolylinePoints();
          final List<PointLatLng> decodedPoints =
              polylinePoints.decodePolyline(encodedPolyline);
          final List<LatLng> polylineCoordinates = decodedPoints
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();

          // Complete the future with the decoded polyline coordinates.
          completer.complete(polylineCoordinates);
        } else {
          completer.completeError("No encoded polyline found");
        }
      } else {
        // Complete with an error if the API response indicates a failure.
        completer.completeError("Error fetching directions: $status");
      }
    });

    return completer.future;
  }

  /// Fetches a route between the given origin coordinates and destination address.
  ///
  /// This helper method converts the [origin] of type [LatLng] to a string representation
  /// formatted as "latitude,longitude" and then delegates the route fetching to [fetchRoute].
  ///
  /// Returns a [Future] that resolves to a list of [LatLng] coordinates representing the route,
  /// or an error if the route could not be fetched.
  Future<List<LatLng>> fetchRouteFromCoords(
      LatLng origin, String destinationAddress) async {
    final originString = "${origin.latitude},${origin.longitude}";
    return fetchRoute(originString, destinationAddress);
  }
}
