// ignore_for_file: prefer_final_fields, prefer_final_locals, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_directions_api/google_directions_api.dart' as gda;
import 'package:http/http.dart' as http;
import '../../data/repositories/map_repository.dart';
import '../data/domain-model/concordia_campus.dart';
import '../../data/domain-model/concordia_building.dart';
import '../data/repositories/building_repository.dart';
import '../data/repositories/outdoor_directions_repository.dart';
import '../data/services/building_service.dart';
import '../data/services/map_service.dart';
import '../data/services/helpers/icon_loader.dart';
import 'building_viewmodel.dart';
import 'package:geocoding/geocoding.dart';
import '../data/services/outdoor_directions_service.dart'; // New import

/// A custom enum that includes a shuttle option in addition to those provided
/// by the Google Maps Directions API.
enum CustomTravelMode {
  driving,
  walking,
  bicycling,
  transit,
  shuttle,
}

// ignore: constant_identifier_names
enum ShuttleRouteDirection { LOYtoSGW, SGWtoLOY }

/// Maps a [CustomTravelMode] to the Google Directions API travel mode.
/// For shuttle, we return `null` because it’s handled separately.
gda.TravelMode? toGdaTravelMode(CustomTravelMode mode) {
  switch (mode) {
    case CustomTravelMode.driving:
      return gda.TravelMode.driving;
    case CustomTravelMode.walking:
      return gda.TravelMode.walking;
    case CustomTravelMode.bicycling:
      return gda.TravelMode.bicycling;
    case CustomTravelMode.transit:
      return gda.TravelMode.transit;
    case CustomTravelMode.shuttle:
      return null;
  }
}

class MapViewModel extends ChangeNotifier {
  final MapRepository _mapRepository;
  final MapService _mapService;
  final BuildingService _buildingService = BuildingService();
  final ODSDirectionsService _odsDirectionsService;
  final ShuttleRouteRepository _shuttleRepository;

  List<Marker> _markers = [];
  List<Marker> get markers => _markers;

  List<ConcordiaBuilding> _filteredBuildings = [];

  List<ConcordiaBuilding> get filteredBuildings => _filteredBuildings;

  // ignore: unused_field
  GoogleMapController? _mapController;
  ValueNotifier<ConcordiaBuilding?> selectedBuildingNotifier =
      ValueNotifier<ConcordiaBuilding?>(null);

  ValueNotifier<Set<Marker>> shuttleMarkersNotifier = ValueNotifier({});
  Set<Marker> _staticBusStopMarkers = {};
  Set<Marker> get staticBusStopMarkers => _staticBusStopMarkers;

  Timer? _shuttleBusTimer;
  bool _isDisposed = false;

  // Shuttle availability flag.
  bool _shuttleAvailable = true;
  bool get shuttleAvailable => _shuttleAvailable;

  Marker? _destinationMarker;
  Marker? get destinationMarker => _destinationMarker;

  MapService get mapService => _mapService;

  final Map<CustomTravelMode, Polyline> _multiModeRoutes = {};
  final Map<CustomTravelMode, String> _multiModeTravelTimes = {};
  Set<Polyline> _multiModeActivePolylines = {};
  CustomTravelMode _selectedTravelModeForRoute = CustomTravelMode.driving;

  Set<Polyline> get multiModePolylines => _multiModeActivePolylines;
  Map<CustomTravelMode, String> get multiModeTravelTimes =>
      _multiModeTravelTimes;
  CustomTravelMode get selectedTravelModeForRoute =>
      _selectedTravelModeForRoute;
  Set<Polyline> get activePolylines => _multiModeActivePolylines;
  Map<CustomTravelMode, String> get travelTimes => _multiModeTravelTimes;
  CustomTravelMode get selectedTravelMode => _selectedTravelModeForRoute;

  void setActiveMode(CustomTravelMode mode) => setActiveModeForRoute(mode);

  /// ViewModel for managing map-related state and logic including travel routes, markers, and shuttle tracking.
  MapViewModel({
    MapRepository? mapRepository,
    MapService? mapService,
    BuildingService? buildingService,
    ODSDirectionsService? odsDirectionsService,
    ShuttleRouteRepository? shuttleRepository,
  })  : _mapRepository = mapRepository ?? MapRepository(),
        _mapService = mapService ?? MapService(),
        _odsDirectionsService = odsDirectionsService ?? ODSDirectionsService(),
        _shuttleRepository = shuttleRepository ?? ShuttleRouteRepository(),
        super() {
    // Fetch shuttle bus data, start periodic updates, and bus stop markers.
    fetchShuttleBusData();
    startShuttleBusTimer();
    loadStaticBusStopMarkers();
  }

  /// Fetches the initial camera position for the provided [campus].
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

  Future<String> _getOriginAddress (String? originAddress) async {
    if (originAddress == null || originAddress == 'Your Location') {
      final currentLocation = await _mapService.getCurrentLocation();
      if (currentLocation == null) {
        throw Exception("Current location is not available.");
      }
      return "${currentLocation.latitude},${currentLocation.longitude}";
    } else {
      final buildingAddress = BuildingViewModel().getBuildingLocationByName(originAddress);
      return "${buildingAddress?.latitude},${buildingAddress?.longitude}";
    }
  }

  Future<void> _scheduleIfRoute(String origin, String destination) async {
    // Only if at least one Google Maps route is available, check the shuttle schedule.
    if (_multiModeRoutes.isNotEmpty) {
      final ShuttleRouteRepository shuttleRepo = ShuttleRouteRepository();
      _shuttleAvailable = await shuttleRepo.isShuttleAvailable();
      if (_shuttleAvailable) {
        await fetchShuttleRoute(origin, destination);
      }
    } else {
      // No Google Maps modes available; refrain from checking shuttle.
      _shuttleAvailable = false;
    }
  }

  /// Fetches routes for all supported travel modes from [originAddress] to [destinationAddress].
  ///
  /// Throws an exception if the current location is unavailable.
  Future<void> fetchRoutesForAllModes(
      String originAddress, String destinationAddress) async {
    _multiModeRoutes.clear();
    _multiModeTravelTimes.clear();
    _multiModeActivePolylines.clear();

    // List of Google Maps transport modes.
    List<CustomTravelMode> googleModes = [
      CustomTravelMode.driving,
      CustomTravelMode.walking,
      CustomTravelMode.bicycling,
      CustomTravelMode.transit,
    ];

    // For each Google Maps mode, fetch the route using ODSDirectionsService.
    for (var mode in googleModes) {
      final gda.TravelMode? gdaMode = toGdaTravelMode(mode);
      if (gdaMode != null) {
        String originStr = await _getOriginAddress(originAddress);
        final destinationBuilding = BuildingViewModel().getBuildingLocationByName(destinationAddress);
        String destinationStr = "${destinationBuilding?.latitude},${destinationBuilding?.longitude}";
        final result = await _odsDirectionsService.fetchRouteResult(
          originAddress: originStr,
          destinationAddress: destinationStr,
          travelMode: gdaMode,
          polylineId: mode.toString(),
        );
        if (result.polyline != null) {
          _multiModeRoutes[mode] = result.polyline!;
          _multiModeTravelTimes[mode] = result.travelTime;
        } else {
          _multiModeTravelTimes[mode] = "--";
        }
      }
    }

    await _scheduleIfRoute(originAddress, destinationAddress);

    if (_multiModeRoutes.containsKey(_selectedTravelModeForRoute)) {
      _multiModeActivePolylines = {
        _multiModeRoutes[_selectedTravelModeForRoute]!
      };
      final activePolyline = _multiModeRoutes[_selectedTravelModeForRoute]!;
      if (activePolyline.points.isNotEmpty) {
        _destinationMarker = Marker(
          markerId: const MarkerId('destination'),
          position: activePolyline.points.last,
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: await IconLoader.loadBitmapDescriptor(
              'assets/icons/destination.png'),
        );
      }
      Future.delayed(const Duration(seconds: 1),
          () => adjustCamera(activePolyline.points));
    }

    notifyListeners();
  }

  /// Helper method to retrieve LatLng coordinates from a given address using
  /// Dart's geocoding package.
  Future<LatLng?> geocodeAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return LatLng(location.latitude, location.longitude);
      }
    } on Error {
      return null;
    }
    return null;
  }

  // get origin coordinates for shuttle route
  Future<LatLng?> _getOriginCoords(String originAddress, LatLng loyolaStop, LatLng sgwStop) async {
    if (originAddress == 'Your Location') {
      // If no origin is provided, assume the current location was used.
      return await _mapService.getCurrentLocation();
    } else {
      return BuildingViewModel().getBuildingLocationByName(originAddress);
    }
  }

  Future<LatLng?> _getDestinationCoords(String destinationAddress, LatLng loyolaStop, LatLng sgwStop) async {
    if (destinationAddress == 'Your Location') {
      return await _mapService.getCurrentLocation();
    } 
    return BuildingViewModel().getBuildingLocationByName(destinationAddress);
  }

  bool _isValidShuttleRoute(bool originNearLOY, bool originNearSGW,
      bool destNearLOY, bool destNearSGW) {
    if ((!originNearLOY && !originNearSGW) || (!destNearLOY && !destNearSGW)) {
      if (kDebugMode) {
        print(
            "Shuttle route not available: One or both addresses are not within 1km of a campus shuttle stop.");
      }
      return false;
    }
    // If both addresses are near the same campus, there's no shuttle route.
    if ((originNearLOY && destNearLOY) || (originNearSGW && destNearSGW)) {
      if (kDebugMode) {
        print(
            "Shuttle route not available: Both addresses are near the same campus shuttle stop.");
      }
      return false;
    }
    return true;
  }

  ShuttleRouteDirection? _validShuttleRoute(bool originNearLOY,
      bool originNearSGW, bool destNearLOY, bool destNearSGW) {
    if (_isValidShuttleRoute(
        originNearLOY, originNearSGW, destNearLOY, destNearSGW)) {
      if (originNearSGW && destNearLOY) {
        return ShuttleRouteDirection.SGWtoLOY;
      } else if (originNearLOY && destNearSGW) {
        return ShuttleRouteDirection.LOYtoSGW;
      } else {
        if (kDebugMode) {
          print(
              "Shuttle route not available: Addresses do not meet valid shuttle range criteria.");
        }
        return null;
      }
    } else {
      return null;
    }
  }

  List<LatLng> _getCompositePoints(
      Polyline? leg1, Polyline leg2, Polyline? leg3) {
    List<LatLng> compositePoints = [];
    if (leg1 != null) compositePoints.addAll(leg1.points);
    compositePoints.addAll(leg2.points);
    if (leg3 != null) compositePoints.addAll(leg3.points);
    return compositePoints;
  }

  Future<void> fetchShuttleRoute(
      String originAddress, String destinationAddress) async {
    // Campus shuttle stops.
    const LatLng loyolaStop = LatLng(45.45825, -73.63914);
    const LatLng sgwStop = LatLng(45.49713, -73.57852);

    LatLng? originCoords =
        await _getOriginCoords(originAddress, loyolaStop, sgwStop);

    LatLng? destinationCoords =
        await _getDestinationCoords(destinationAddress, loyolaStop, sgwStop);

    if (originCoords == null || destinationCoords == null) {
      if (kDebugMode) {
        print("Shuttle route not available: Cannot determine coordinates.");
      }
      return;
    }

    const double radius = 1000.0; // 1 km threshold

    // Determine which campus each coordinate is near.
    bool originNearLOY = _mapService.calculateDistance(originCoords,
            LatLng(ConcordiaCampus.loy.lat, ConcordiaCampus.loy.lng)) <
        radius;
    bool originNearSGW = _mapService.calculateDistance(originCoords,
            LatLng(ConcordiaCampus.sgw.lat, ConcordiaCampus.sgw.lng)) <
        radius;
    bool destNearLOY = _mapService.calculateDistance(destinationCoords,
            LatLng(ConcordiaCampus.loy.lat, ConcordiaCampus.loy.lng)) <
        radius;
    bool destNearSGW = _mapService.calculateDistance(destinationCoords,
            LatLng(ConcordiaCampus.sgw.lat, ConcordiaCampus.sgw.lng)) <
        radius;

    // Determine the shuttle route direction.
    ShuttleRouteDirection? computedDirection = _validShuttleRoute(
        originNearLOY, originNearSGW, destNearLOY, destNearSGW);
    if (computedDirection == null) return;

    // Set boarding/disembark stops based on the computed direction.
    late LatLng boardingStop;
    late LatLng disembarkStop;
    late String polylineIdSuffix;
    if (computedDirection == ShuttleRouteDirection.LOYtoSGW) {
      boardingStop = loyolaStop;
      disembarkStop = sgwStop;
      polylineIdSuffix = "LOYtoSGW";
    } else {
      boardingStop = sgwStop;
      disembarkStop = loyolaStop;
      polylineIdSuffix = "SGWtoLOY";
    }

    // Load shuttle coordinates from the repository.
    //final ShuttleRouteRepository repository = ShuttleRouteRepository();
    List<LatLng> shuttleCoordinates =
        await _shuttleRepository.loadShuttleRoute(computedDirection);

    // Get walking routes using ODSDirectionsService:
    final String boardingStr =
        "${boardingStop.latitude},${boardingStop.longitude}";
    final String disembarkStr =
        "${disembarkStop.latitude},${disembarkStop.longitude}";
    final String originStr =
        "${originCoords.latitude},${originCoords.longitude}";
    final String destStr =
        "${destinationCoords.latitude},${destinationCoords.longitude}";

    final Polyline? leg1 = await _odsDirectionsService.fetchWalkingPolyline(
      originAddress: originStr,
      destinationAddress: boardingStr,
      polylineId: "walking_leg1_$polylineIdSuffix",
    );
    final Polyline? leg3 = await _odsDirectionsService.fetchWalkingPolyline(
      originAddress: disembarkStr,
      destinationAddress: destStr,
      polylineId: "walking_leg3_$polylineIdSuffix",
    );

    // Create the shuttle segment polyline.
    final Polyline leg2 = Polyline(
      polylineId: PolylineId("shuttleSegment_$polylineIdSuffix"),
      points: shuttleCoordinates,
      color: const Color(0xFF2196F3),
      patterns: [PatternItem.dot, PatternItem.gap(10)],
      width: 5,
    );

    // Merge walking segments with the shuttle segment.
    List<LatLng> compositePoints = _getCompositePoints(leg1, leg2, leg3);

    final Polyline shuttleComposite = Polyline(
      polylineId: PolylineId("shuttleComposite_$polylineIdSuffix"),
      points: compositePoints,
      color: const Color(0xFF2196F3),
      patterns: [PatternItem.dot, PatternItem.gap(10)],
      width: 5,
    );

    _multiModeRoutes[CustomTravelMode.shuttle] = shuttleComposite;

    // Calculate walking durations (in minutes) based on polyline distances.
    int walkingTimeToShuttle = 0;
    if (leg1 != null && leg1.points.isNotEmpty) {
      walkingTimeToShuttle =
          (_calculatePolylineDistance(leg1) / 1.4 / 60).round();
    }
    int walkingTimeFromShuttle = 0;
    if (leg3 != null && leg3.points.isNotEmpty) {
      walkingTimeFromShuttle =
          (_calculatePolylineDistance(leg3) / 1.4 / 60).round();
    }
    int shuttleRideTime = 30; // Fixed shuttle ride time provided by Concordia.
    int totalShuttleTime =
        walkingTimeToShuttle + shuttleRideTime + walkingTimeFromShuttle;
    _multiModeTravelTimes[CustomTravelMode.shuttle] = "$totalShuttleTime min";

    if (_selectedTravelModeForRoute == CustomTravelMode.shuttle) {
      _multiModeActivePolylines = {shuttleComposite};
      _destinationMarker = Marker(
        markerId: const MarkerId('destination'),
        position:
            compositePoints.isNotEmpty ? compositePoints.last : boardingStop,
        infoWindow: const InfoWindow(title: 'Destination'),
      );
    }
    notifyListeners();
  }

  double _calculatePolylineDistance(Polyline polyline) {
    double totalDistance = 0.0;
    for (int i = 0; i < polyline.points.length - 1; i++) {
      totalDistance += _mapService.calculateDistance(
          polyline.points[i], polyline.points[i + 1]);
    }
    return totalDistance;
  }

  Future<void> setActiveModeForRoute(CustomTravelMode mode) async {
    _selectedTravelModeForRoute = mode;
    if (_multiModeRoutes.containsKey(mode)) {
      _multiModeActivePolylines = {_multiModeRoutes[mode]!};
      final polyline = _multiModeRoutes[mode]!;
      if (polyline.points.isNotEmpty) {
        _destinationMarker = Marker(
          markerId: const MarkerId('destination'),
          position: polyline.points.last,
          infoWindow: const InfoWindow(title: 'Your Destination'),
          icon: await IconLoader.loadBitmapDescriptor(
              'assets/icons/destination.png'),
          zIndex: 2,
        );
        Future.delayed(
            const Duration(seconds: 1), () => adjustCamera(polyline.points));
      }
    } else {
      _multiModeActivePolylines.clear();
    }
    notifyListeners();
  }

  void adjustCamera(List<LatLng> points) {
    _mapService.adjustCameraForPath(points);
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapService.setMapController(controller);
  }

  void moveToLocation(LatLng location) {
    _mapService.moveCamera(location);
  }

  Future<Map<String, dynamic>> _getPolygonsAndLabels(
      {String? campusName}) async {
    Map<String, dynamic> data;
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
          // Handle onTap if needed.
        },
      );
    }).toSet();

    final Set<Marker> labelMarkers = {};
    for (var entry in labelPositions.entries) {
      final BitmapDescriptor icon = await _mapService.getCustomIcon(entry.key);
      labelMarkers.add(
        Marker(
          markerId: MarkerId(entry.key),
          position: entry.value,
          icon: icon,
          onTap: () {
            ConcordiaBuilding? building =
                _buildingService.getBuildingByAbbreviation(entry.key);
            selectBuilding(building!);
          },
          zIndex: 1,
        ),
      );
    }

    return {"polygons": polygonSet, "labels": labelMarkers};
  }

  Future<Map<String, dynamic>> getCampusPolygonsAndLabels(
      ConcordiaCampus campus) async {
    final String campusName = (campus.name == "Loyola Campus") ? "loy" : "sgw";
    return await _getPolygonsAndLabels(campusName: campusName);
  }

  Future<Map<String, dynamic>> getAllCampusPolygonsAndLabels() async {
    return await _getPolygonsAndLabels();
  }

  void selectBuilding(ConcordiaBuilding building) {
    selectedBuildingNotifier.value = building;
    notifyListeners();
  }

  void unselectBuilding() {
    selectedBuildingNotifier.value = null;
    notifyListeners();
  }

  Future<LatLng?> fetchCurrentLocation() async {
    return await _mapService.getCurrentLocation();
  }

  Future<bool> checkLocationAccess() async {
    final bool serviceEnabled = await _mapService.isLocationServiceEnabled();
    if (!serviceEnabled) return false;
    final bool hasPermission =
        await _mapService.checkAndRequestLocationPermission();
    return hasPermission;
  }

  Future<void> zoomIn() async {
    await _mapService.zoomIn();
  }

  Future<void> zoomOut() async {
    await _mapService.zoomOut();
  }

  double getDistance(LatLng point1, LatLng point2) {
    return _mapService.calculateDistance(point1, point2);
  }

  void startShuttleBusTimer() {
    _shuttleBusTimer?.cancel();
    _shuttleBusTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!_isDisposed) {
        fetchShuttleBusData();
      }
    });
  }

  void stopShuttleBusTimer() {
    _shuttleBusTimer?.cancel();
  }

  Future<void> fetchShuttleBusData() async {
    try {
      final getResponse = await http.get(
        Uri.parse('https://shuttle.concordia.ca/concordiabusmap/Map.aspx'),
        headers: {'Host': 'shuttle.concordia.ca'},
      );
      String? cookies = getResponse.headers['set-cookie'];

      final postResponse = await http.post(
        Uri.parse(
            'https://shuttle.concordia.ca/concordiabusmap/WebService/GService.asmx/GetGoogleObject'),
        headers: {
          'Host': 'shuttle.concordia.ca',
          'Content-Length': '0',
          'Content-Type': 'application/json; charset=UTF-8',
          if (cookies != null) 'Cookie': cookies,
        },
        body: '',
      );

      if (postResponse.statusCode == 200) {
        final data = json.decode(postResponse.body);
        final List<dynamic> points = data["d"]["Points"];

        Set<Marker> newMarkers = {};
        for (var point in points) {
          if (point["ID"].toString().startsWith("BUS")) {
            newMarkers.add(
              Marker(
                markerId: MarkerId(point["ID"]),
                position: LatLng(point["Latitude"], point["Longitude"]),
                infoWindow: const InfoWindow(title: "Concordia Shuttle Bus"),
                icon: await IconLoader.loadBitmapDescriptor(
                    'assets/icons/shuttle_bus.png'),
              ),
            );
          }
        }
        shuttleMarkersNotifier.value = newMarkers;
      } else {
        if (kDebugMode) {
          print(
              "Error fetching shuttle bus data: POST status ${postResponse.statusCode}");
        }
      }
    } on Error catch (e) {
      if (kDebugMode) {
        print("Error fetching shuttle bus data: $e");
      }
    }
  }

  Future<void> loadStaticBusStopMarkers() async {
    final BitmapDescriptor busStopIcon = await IconLoader.loadBitmapDescriptor(
        'assets/icons/shuttle_bus_station.png');
    const LatLng loyolaStop = LatLng(45.45825, -73.63914);
    const LatLng sgwStop = LatLng(45.49713, -73.57852);

    Marker loyolaBusStopMarker = Marker(
      markerId: const MarkerId('loyola_bus_stop'),
      position: loyolaStop,
      infoWindow: const InfoWindow(
          title: 'LOY Shuttle Bus Stop',
          snippet: 'See the schedule for next arrival.'),
      icon: busStopIcon,
    );

    Marker sgwBusStopMarker = Marker(
      markerId: const MarkerId('sgw_bus_stop'),
      position: sgwStop,
      infoWindow: const InfoWindow(
          title: 'SGW Shuttle Bus Stop',
          snippet: 'See the schedule for next arrival.'),
      icon: busStopIcon,
    );

    _staticBusStopMarkers = {loyolaBusStopMarker, sgwBusStopMarker};
    notifyListeners();
  }

  Future<void> checkBuildingAtCurrentLocation(BuildContext? context) async {
    final LatLng? currentLocation = await fetchCurrentLocation();
    if (currentLocation == null) {
      return;
    }
    final Map<String, dynamic> data =
        await BuildingRepository.loadAllBuildingPolygonsAndLabels();
    final Map<String, List<LatLng>> polygons = data['polygons'];
    for (var entry in polygons.entries) {
      final String buildingAbbr = entry.key;
      final List<LatLng> polygon = entry.value;
      if (_isPointInPolygon(currentLocation, polygon)) {
        final ConcordiaBuilding? building =
            _buildingService.getBuildingByAbbreviation(buildingAbbr);
        selectBuilding(building!);
        return;
      }
    }
    unselectBuilding();
  }

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

  Future<bool> moveToCurrentLocation(BuildContext? context) async {
    final bool hasAccess = await checkLocationAccess();
    if (!hasAccess) {
      if (context!.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Location services or permissions are not available. Please enable them in settings."),
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

  @override
  void dispose() {
    _isDisposed = true;
    _shuttleBusTimer?.cancel();
    shuttleMarkersNotifier.dispose();
    super.dispose();
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
