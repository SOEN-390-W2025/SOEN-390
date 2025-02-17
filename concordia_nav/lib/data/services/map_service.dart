import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../domain-model/concordia_campus.dart';
import '../repositories/building_repository.dart';
import 'helpers/icon_loader.dart';

class MapService {
  late GoogleMapController _mapController;

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  /// Returns the camera position for the given [campus].
  CameraPosition getInitialCameraPosition(ConcordiaCampus campus) {
    return CameraPosition(
      target: LatLng(campus.lat, campus.lng),
      zoom: 17.0,
    );
  }

  void moveCamera(LatLng position, {double zoom = 17.0}) {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: zoom),
      ),
    );
  }

  /// Fetches polygons and campus markers from BuildingRepository.
  Future<Map<String, dynamic>> getCampusPolygonsAndLabels(
      ConcordiaCampus campus) async {
    final String campusName = (campus.name == "Loyola Campus") ? "loy" : "sgw";

    // Load polygons and label positions (markers should be placed at label positions)
    final Map<String, dynamic> data =
        await BuildingRepository.loadBuildingPolygonsAndLabels(campusName);

    final Map<String, List<LatLng>> polygonsData = data["polygons"];
    final Map<String, LatLng> labelPositions = data["labels"];

    final Set<Polygon> polygonSet = polygonsData.entries.map((entry) {
      return Polygon(
        polygonId: PolygonId(entry.key),
        points: entry.value,
        strokeWidth: 3,
        strokeColor: const Color(0xFFB48107),
        fillColor: const Color(0xFFe5a712),
      );
    }).toSet();

    // Load campus markers (placed at centroid of each building polygon)
    final Set<Marker> labelMarkers = {};
    for (var entry in labelPositions.entries) {
      final BitmapDescriptor icon = await _getCustomIcon(entry.key);
      labelMarkers.add(
        Marker(
          markerId: MarkerId(entry.key),
          position: entry.value, // Use centroid as position
          icon: icon,
        ),
      );
    }

    return {"polygons": polygonSet, "labels": labelMarkers};
  }

  /// Loads a custom icon for each label from /assets/icons/{name}.png.
  Future<BitmapDescriptor> _getCustomIcon(String name) async {
    final String iconPath = 'assets/icons/$name.png';
    return IconLoader.loadBitmapDescriptor(iconPath);
  }
}
