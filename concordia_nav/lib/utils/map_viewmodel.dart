// ignore_for_file: prefer_final_fields, prefer_final_locals, use_build_context_synchronously

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/repositories/map_repository.dart';
import '../data/domain-model/concordia_campus.dart';
import '../../data/services/map_service.dart';
import '../data/domain-model/concordia_building.dart';
import '../data/repositories/building_repository.dart';
import '../data/services/building_service.dart';
import '../data/services/helpers/icon_loader.dart';
import 'building_viewmodel.dart';

class MapViewModel extends ChangeNotifier {
  MapRepository _mapRepository;
  MapService _mapService;
  BuildingService _buildingService = BuildingService();

  List<Marker> _markers = [];
  List<Marker> get markers => _markers;

  List<ConcordiaBuilding> _filteredBuildings = [];

  List<ConcordiaBuilding> get filteredBuildings => _filteredBuildings;

  // ignore: unused_field
  GoogleMapController? _mapController;
  ValueNotifier<ConcordiaBuilding?> selectedBuildingNotifier =
      ValueNotifier<ConcordiaBuilding?>(null);

  MapViewModel(
      {MapRepository? mapRepository,
      MapService? mapService,
      BuildingService? buildingService})
      : _mapRepository = mapRepository ?? MapRepository(),
        _mapService = mapService ?? MapService(),
        _buildingService = buildingService ?? BuildingService();

  // Holds the current set of polylines to be rendered.
  Set<Polyline> _polylines = {};

  /// Getter for polylines
  Set<Polyline> get polylines => _polylines;

  /// Exposes the MapService.
  MapService get mapService => _mapService;

  /// Returns the initial camera position for the given campus.
  Future<CameraPosition> getInitialCameraPosition(
      ConcordiaCampus campus) async {
    return _mapRepository.getCameraPosition(campus);
  }

  Future<Map<String, dynamic>> fetchMapData(ConcordiaCampus campus, bool? isCampus) async {
    final cameraPosition = await getInitialCameraPosition(campus);
    final mapData = isCampus == true
      ? await getCampusPolygonsAndLabels(campus)
      : await getAllCampusPolygonsAndLabels();

    return {
      'cameraPosition': cameraPosition,
      'polygons': mapData['polygons'],
      'labels': mapData['labels'],
    };
  }

  /// Fetches the route and updates the polyline and destination marker.
  Future<void> fetchRoute(
      String? originAddress, String destinationAddress) async {
    try {
      // Get the route as a list of LatLng coordinates.
      final List<LatLng> routePoints =
          await _mapService.getRoutePath(originAddress, destinationAddress);

      // Create a new polyline with a dashed pattern.
      final Polyline polyline = Polyline(
        polylineId:
            PolylineId('${originAddress ?? "current"}_$destinationAddress'),
        color: const Color(0xFF0c79fe),
        width: 5,
        points: routePoints,
        patterns: [PatternItem.dot, PatternItem.gap(10)],
      );

      _polylines = {polyline};

      // Create a marker for the end user to visualize the destination coords.
      if (routePoints.isNotEmpty) {
        removeMarker( const MarkerId('source'));
        removeMarker( const MarkerId('destination'));
        addMarker( Marker(
          markerId: const MarkerId('source'),
          position: routePoints.first,
          infoWindow: const InfoWindow(title: 'Source'),
          icon: await IconLoader.loadBitmapDescriptor(
              'assets/icons/source.png',),
          anchor: const Offset(0.5, 0.5),
        ));
        addMarker( Marker(
          markerId: const MarkerId('destination'),
          position: routePoints.last,
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: await IconLoader.loadBitmapDescriptor(
              'assets/icons/destination.png'),
        ));
      }
    } catch (e) {
      throw Exception("Failed to load directions: $e");
    }
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

  /// Fetches polygons and campus markers from BuildingRepository for a specific campus or all campuses.
  Future<Map<String, dynamic>> _getPolygonsAndLabels(
      {String? campusName}) async {
    Map<String, dynamic> data;

    // If campusName is provided, load data for that specific campus, else load data for all campuses.
    if (campusName != null) {
      data = await BuildingRepository.loadBuildingPolygonsAndLabels(campusName);
    } else {
      data = await BuildingRepository.loadAllBuildingPolygonsAndLabels();
    }

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
          // Handle onTap if needed
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
            ConcordiaBuilding? building =
                _buildingService.getBuildingByAbbreviation(entry.key);
            selectBuilding(building!);
          },
        ),
      );
    }

    return {"polygons": polygonSet, "labels": labelMarkers};
  }

  /// Fetches polygons and campus markers for a specific campus.
  Future<Map<String, dynamic>> getCampusPolygonsAndLabels(
      ConcordiaCampus campus) async {
    final String campusName = (campus.name == "Loyola Campus") ? "loy" : "sgw";
    return await _getPolygonsAndLabels(campusName: campusName);
  }

  /// Fetches polygons and campus markers for all campuses.
  Future<Map<String, dynamic>> getAllCampusPolygonsAndLabels() async {
    return await _getPolygonsAndLabels();
  }

  /// Sets the selected building and notifies listeners.
  void selectBuilding(ConcordiaBuilding building) {
    selectedBuildingNotifier.value = building;
    notifyListeners();
  }

  void unselectBuilding() {
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

  // Helper function to check if a point is inside a polygon
  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int i, j = polygon.length - 1;
    bool inside = false;

    for (i = 0; i < polygon.length; j = i++) {
      final LatLng pi = polygon[i];
      final LatLng pj = polygon[j];

      if ((pi.longitude > point.longitude) !=
              (pj.longitude > point.longitude) &&
          (point.latitude <
              (pj.latitude - pi.latitude) *
                      (point.longitude - pi.longitude) /
                      (pj.longitude - pi.longitude) +
                  pi.latitude)) {
        inside = !inside;
      }
    }
    return inside;
  }

  Future<void> checkBuildingAtCurrentLocation(BuildContext? context) async {
    final LatLng? currentLocation = await fetchCurrentLocation();
    if (currentLocation == null) {
      // Handle case where location is not available
      return;
    }

    // Load the polygons and labels
    final Map<String, dynamic> data =
        await BuildingRepository.loadAllBuildingPolygonsAndLabels();
    final Map<String, List<LatLng>> polygons = data['polygons'];

    // Check each polygon to see if the current location is inside any of them
    for (var entry in polygons.entries) {
      final String buildingAbbr = entry.key;
      final List<LatLng> polygon = entry.value;
      if (_isPointInPolygon(currentLocation, polygon)) {
        // If inside the polygon, get the building details and show the drawer
        final ConcordiaBuilding? building =
            _buildingService.getBuildingByAbbreviation(buildingAbbr);
        selectBuilding(building!);
        return;
      }
    }

    // If not inside any building polygon, unselect building or show a default message
    unselectBuilding();
  }

  /// Fetches current location and moves the camera.
  Future<bool> moveToCurrentLocation(BuildContext? context) async {
    final bool hasAccess = await checkLocationAccess();
    if (!hasAccess) {
      if (context!.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Location services or permissions are not available. Please enable them in settings.",
            ),
          ),
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

  /// Calculates the distance between two points using the service.
  double getDistance(LatLng point1, LatLng point2) {
    return _mapService.calculateDistance(point1, point2);
  }

  /// Handles the search selection of a building.
  Future<void> handleSelection(
    String selectedBuilding,
    LatLng? currentLocation
  ) async {
    final buildingViewModel = BuildingViewModel();

    // If the selected building is "Your Location", wait for fetchCurrentLocation to complete
    LatLng? location;

    if (selectedBuilding == 'Your Location') {
      location = currentLocation;
    } else {
      location = buildingViewModel.getBuildingLocationByName(selectedBuilding);
    }

    if (location == null) return;

    moveToLocation(location);
  }

  // Add a new marker to the map
  void addMarker(Marker marker) {
    _markers.add(marker);
  }

  // Remove a marker from the map
  void removeMarker(MarkerId markerId) {
    _markers.removeWhere((marker) => marker.markerId == markerId);
  }
}
