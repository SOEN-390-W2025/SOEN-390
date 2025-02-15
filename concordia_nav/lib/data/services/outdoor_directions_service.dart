import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsService {
  static const String _baseUrl = "https://routes.googleapis.com/directions/v2:computeRoutes";
  static const String _apiKey = "AIzaSyBgcOdiFFHJuUYxvaL1ooPdv3FnRzc3PjI";
  ///Get the route from Routes API
  Future<List<LatLng>> fetchRoute(String originAddress, String destinationAddress) async {
  try {
    final response = await http.post(
      Uri.parse("$_baseUrl?key=$_apiKey"),
      headers: {
        "Content-Type": "application/json",
        "X-Goog-FieldMask": "routes.distanceMeters,routes.duration,routes.polyline.encodedPolyline",
      },
      body: jsonEncode({
        "origin": {
          "address": originAddress,
        },
        "destination": {
          "address": destinationAddress,
        },
        "travelMode": "DRIVE",
      }),
    );

    print("API Response Status Code: ${response.statusCode}");
    print("API Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final encodedPolyline = data["routes"][0]["polyline"]["encodedPolyline"];
      print("Encoded Polyline: $encodedPolyline");


      List<LatLng> routePoints = _decodePolyline(encodedPolyline);
      print("Decoded Polyline Points: $routePoints");

      return routePoints;
    } else {
      throw Exception("Failed to load directions. Status Code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetching route: $e");
    throw Exception("Failed to load directions: $e");
  }
}
  ///Process polyline information
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }
}