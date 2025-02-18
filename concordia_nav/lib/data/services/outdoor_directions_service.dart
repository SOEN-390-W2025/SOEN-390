import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsService {
  static const String _baseUrl = "https://routes.googleapis.com/directions/v2:computeRoutes";
  static const String _apiKey = "AIzaSyBgcOdiFFHJuUYxvaL1ooPdv3FnRzc3PjI";

  /// Fetch route using addresses
  Future<List<LatLng>> fetchRoute(String originAddress, String destinationAddress) async {
    return _fetchRouteFromAPI(
      {"address": originAddress,},
      {"address": destinationAddress,},
    );
  }

  /// Fetch route using LatLng for origin and address for destination
  Future<List<LatLng>> fetchRouteFromCoords(LatLng origin, String destinationAddress) async {
    return _fetchRouteFromAPI(
      {
        "location": {
          "latLng": {
            "latitude": origin.latitude,
            "longitude": origin.longitude,
          },
        },
      },
      {"address": destinationAddress,},
    );
  }

  /// Internal method to fetch route from the API
  Future<List<LatLng>> _fetchRouteFromAPI(Map<String, dynamic> origin, Map<String, dynamic> destination) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl?key=$_apiKey"),
        headers: {
          "Content-Type": "application/json",
          "X-Goog-FieldMask": "routes.distanceMeters,routes.duration,routes.polyline.encodedPolyline",
        },
        body: jsonEncode({
          "origin": origin,
          "destination": destination,
          "travelMode": "DRIVE",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final encodedPolyline = data["routes"][0]["polyline"]["encodedPolyline"];

        final List<LatLng> routePoints = _decodePolyline(encodedPolyline);

        return routePoints;
      } else {
        throw Exception("Failed to load directions. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to load directions: $e");
    }
  }

  /// Decode polyline information
  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }
}