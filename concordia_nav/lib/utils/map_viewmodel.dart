// ignore_for_file: prefer_final_fields, prefer_final_locals

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/repositories/map_repository.dart';
import '../data/domain-model/concordia_campus.dart';
import '../../data/services/map_service.dart';
import '../data/domain-model/concordia_building.dart';
import '../data/repositories/building_repository.dart';
import '../data/services/building_service.dart ';
class MapViewModel extends ChangeNotifier{
  MapRepository _mapRepository = MapRepository();
  MapService _mapService = MapService();
  BuildingService _buildingService = BuildingService();

  // ignore: unused_field
  GoogleMapController? _mapController;
  ValueNotifier<ConcordiaBuilding?> selectedBuildingNotifier = ValueNotifier<ConcordiaBuilding?>(null);

  MapViewModel({MapRepository? mapRepository, MapService? mapService, BuildingService? buildingService})
      : _mapRepository = mapRepository ?? MapRepository(),
        _mapService = mapService ?? MapService(),
        _buildingService = buildingService ?? BuildingService();

  /// Fetches the initial camera position for the given campus.
  Future<CameraPosition> getInitialCameraPosition(
      ConcordiaCampus campus) async {
    return _mapRepository.getCameraPosition(campus);
  }

  /// Handles map creation and initializes the map service.
  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapService.setMapController(controller);
  }

  /// Moves the map to the given location.
  void moveToLocation(LatLng location) {
    _mapService.moveCamera(location);
  }

  /// Switches the map camera to a new campus.
  void switchCampus(ConcordiaCampus campus) {
    _mapService.moveCamera(LatLng(campus.lat, campus.lng));
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
        onTap: () {
          // ConcordiaBuilding? building = _buildingService.getBuildingByAbbreviation(entry.key.toLowerCase());
          // // Ensure building is not null before selecting it
          // if (building != null) {
          //   _mapViewModel.selectBuilding(building);
          // } else {
          //   print("Building not found for abbreviation: ${entry.key}");
          // }
        },
      );
    }).toSet();

    // Load campus markers (placed at centroid of each building polygon)
    final Set<Marker> labelMarkers = {};
    for (var entry in labelPositions.entries) {
      final BitmapDescriptor icon = await _mapService.getCustomIcon(entry.key);
      labelMarkers.add(
        Marker(
          markerId: MarkerId(entry.key),
          position: entry.value, // Use centroid as position
          icon: icon,
          onTap: () {
            ConcordiaBuilding? building = _buildingService.getBuildingByAbbreviation(entry.key);
            selectBuilding(building!);
          },
        ),
      );
    }

    return {"polygons": polygonSet, "labels": labelMarkers};
  }

  /// Sets the selected building and notifies listeners.
  void selectBuilding(ConcordiaBuilding building) {
    selectedBuildingNotifier.value = building;
    notifyListeners();
  }

  void unselectBuilding() {
    print('Unselecting building');
    selectedBuildingNotifier.value = null;
    notifyListeners();
  }

  /// Fetches the current location without moving the map.
  Future<LatLng?> fetchCurrentLocation() async {
    return await _mapService.getCurrentLocation();
  }

  /// Checks if location services are enabled and requests permission.
  Future<bool> checkLocationAccess() async {
    final bool serviceEnabled = await _mapService.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    final bool hasPermission =
        await _mapService.checkAndRequestLocationPermission();
    return hasPermission;
  }

  /// Fetches current location and moves the camera.
  Future<bool> moveToCurrentLocation(BuildContext? context) async {
    final bool hasAccess = await checkLocationAccess();
    if (!hasAccess) {
      if (context!.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "Location services or permissions are not available. Please enable them in settings.")),
        );
      }
      return false;
    }

    final LatLng? currentLocation = await fetchCurrentLocation();
    if (currentLocation != null) {
      _mapService.moveCamera(currentLocation);
      return true;
    }
    return false;
  }

  /// Zoom in function
  Future<void> zoomIn() async {
    await _mapService.zoomIn();
  }

  /// Zoom out function
  Future<void> zoomOut() async {
    await _mapService.zoomOut();
  }
}
