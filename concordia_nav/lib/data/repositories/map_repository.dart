import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../domain-model/campus.dart';

class MapRepository {
  /// Returns the initial camera position for the given [campus].
  CameraPosition getCameraPosition(Campus campus) {
    return CameraPosition(
      target: LatLng(campus.lat, campus.lng),
      zoom: 17.0,
    );
  }
}
