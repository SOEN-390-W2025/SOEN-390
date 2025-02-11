import 'dart:math';

class UnitConversions {
  static const double earthRadiusKm = 6371;

  static double degToRad(double input) {
    return input * pi / 180;
  }

  static double coordinatePairDistanceKm(
      double lat1, double lng1, double lat2, double lng2) {
    final deltaLat = degToRad(lat2 - lat1);
    final deltaLng = degToRad(lng2 - lng1);

    final sideA = pow(sin(deltaLat / 2), 2) +
        pow(sin(deltaLng / 2), 2) * cos(degToRad(lat1)) * cos(degToRad(lat2));
    final hypotenuse = 2 * atan2(sqrt(sideA), sqrt(1 - sideA));
    return hypotenuse * earthRadiusKm;
  }
}
