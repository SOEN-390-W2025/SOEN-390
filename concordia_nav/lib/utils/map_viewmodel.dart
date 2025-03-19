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
import '../data/domain-model/place.dart';
import '../data/repositories/building_repository.dart';
import '../data/repositories/outdoor_directions_repository.dart';
import '../data/services/building_service.dart';
import '../data/services/map_service.dart';
import '../data/services/helpers/icon_loader.dart';
import '../data/services/places_service.dart';
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

  final yourLocationString = 'Your Location';

  List<ConcordiaBuilding> filteredBuildings = [];

  // ignore: unused_field
  GoogleMapController? _mapController;
  ValueNotifier<ConcordiaBuilding?> selectedBuildingNotifier =
      ValueNotifier<ConcordiaBuilding?>(null);

  ValueNotifier<Set<Marker>> shuttleMarkersNotifier = ValueNotifier({});
  Set<Marker> _staticBusStopMarkers = {};
  Set<Marker> get staticBusStopMarkers => _staticBusStopMarkers;

  Timer? shuttleBusTimer;
  bool _isDisposed = false;

  // Shuttle availability flag.
  bool _shuttleAvailable = true;
  bool get shuttleAvailable => _shuttleAvailable;

  Marker? _originMarker;
  Marker? get originMarker => _originMarker;

  Marker? _destinationMarker;
  Marker? get destinationMarker => _destinationMarker;

  MapService get mapService => _mapService;

  final Map<CustomTravelMode, Polyline> multiModeRoutes = {};
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

  Future<String> _getOriginAddress(String? originAddress) async {
    if (originAddress == null || originAddress == yourLocationString) {
      final currentLocation = await _mapService.getCurrentLocation();
      if (currentLocation == null) {
        throw Exception("Current location is not available.");
      }
      return "${currentLocation.latitude},${currentLocation.longitude}";
    } else {
      final buildingAddress =
          BuildingViewModel().getBuildingLocationByName(originAddress);
      return "${buildingAddress?.latitude},${buildingAddress?.longitude}";
    }
  }

  Future<void> _scheduleIfRoute(String origin, String destination) async {
    // Only if at least one Google Maps route is available, check the shuttle schedule.
    if (multiModeRoutes.isNotEmpty) {
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
    multiModeRoutes.clear();
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
        final destinationBuilding =
            BuildingViewModel().getBuildingLocationByName(destinationAddress);
        String destinationStr =
            "${destinationBuilding?.latitude},${destinationBuilding?.longitude}";
        final result = await _odsDirectionsService.fetchRouteResult(
          originAddress: originStr,
          destinationAddress: destinationStr,
          travelMode: gdaMode,
          polylineId: mode.toString(),
        );
        if (result.polyline != null) {
          multiModeRoutes[mode] = result.polyline!;
          _multiModeTravelTimes[mode] = result.travelTime;
        } else {
          _multiModeTravelTimes[mode] = "--";
        }
      }
    }

    await _scheduleIfRoute(originAddress, destinationAddress);

    if (multiModeRoutes.containsKey(_selectedTravelModeForRoute)) {
      _multiModeActivePolylines = {
        multiModeRoutes[_selectedTravelModeForRoute]!
      };
      final activePolyline = multiModeRoutes[_selectedTravelModeForRoute]!;
      if (activePolyline.points.isNotEmpty) {
        _originMarker = Marker(
          markerId: const MarkerId('origin'),
          position: activePolyline.points.first,
          infoWindow: const InfoWindow(title: 'Origin'),
          icon:
              await IconLoader.loadBitmapDescriptor('assets/icons/origin.png'),
          anchor: const Offset(0.5, 0.5),
        );
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
  Future<LatLng?> _getOriginCoords(
      String originAddress, LatLng loyolaStop, LatLng sgwStop) async {
    if (originAddress == yourLocationString) {
      // If no origin is provided, assume the current location was used.
      return await _mapService.getCurrentLocation();
    } else {
      return BuildingViewModel().getBuildingLocationByName(originAddress);
    }
  }

  Future<LatLng?> _getDestinationCoords(
      String destinationAddress, LatLng loyolaStop, LatLng sgwStop) async {
    if (destinationAddress == yourLocationString) {
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

    // Validate and get route coordinates
    final ShuttleRouteDetails routeDetails = await _prepareShuttleRouteDetails(
        originAddress, destinationAddress, loyolaStop, sgwStop);

    // If no valid route, exit early
    if (routeDetails.direction == null) return;

    // Prepare route segments
    final RouteSegments routeSegments = await _prepareRouteSegments(
        routeDetails, originAddress, destinationAddress);

    // Create and process shuttle route
    _processShuttleRoute(routeDetails, routeSegments);
  }

  Future<ShuttleRouteDetails> _prepareShuttleRouteDetails(String originAddress,
      String destinationAddress, LatLng loyolaStop, LatLng sgwStop) async {
    const double radius = 1000.0; // 1 km threshold

    LatLng? originCoords =
        await _getOriginCoords(originAddress, loyolaStop, sgwStop);
    LatLng? destinationCoords =
        await _getDestinationCoords(destinationAddress, loyolaStop, sgwStop);

    if (originCoords == null || destinationCoords == null) {
      if (kDebugMode) {
        print("Shuttle route not available: Cannot determine coordinates.");
      }
      return ShuttleRouteDetails(
        originCoords: null,
        destinationCoords: null,
        originNearLOY: false,
        originNearSGW: false,
        destNearLOY: false,
        destNearSGW: false,
        direction: null,
        boardingStop: loyolaStop,
        disembarkStop: sgwStop,
        polylineIdSuffix: '',
      );
    }

    // Determine which campus each coordinate is near
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

    ShuttleRouteDirection? computedDirection = _validShuttleRoute(
        originNearLOY, originNearSGW, destNearLOY, destNearSGW);

    // Set boarding/disembark stops based on the computed direction
    late LatLng boardingStop;
    late LatLng disembarkStop;
    late String polylineIdSuffix;

    if (computedDirection == ShuttleRouteDirection.LOYtoSGW) {
      boardingStop = loyolaStop;
      disembarkStop = sgwStop;
      polylineIdSuffix = "LOYtoSGW";
    } else if (computedDirection == ShuttleRouteDirection.SGWtoLOY) {
      boardingStop = sgwStop;
      disembarkStop = loyolaStop;
      polylineIdSuffix = "SGWtoLOY";
    } else {
      boardingStop = loyolaStop;
      disembarkStop = sgwStop;
      polylineIdSuffix = '';
    }

    return ShuttleRouteDetails(
      originCoords: originCoords,
      destinationCoords: destinationCoords,
      originNearLOY: originNearLOY,
      originNearSGW: originNearSGW,
      destNearLOY: destNearLOY,
      destNearSGW: destNearSGW,
      direction: computedDirection,
      boardingStop: boardingStop,
      disembarkStop: disembarkStop,
      polylineIdSuffix: polylineIdSuffix,
    );
  }

  Future<RouteSegments> _prepareRouteSegments(ShuttleRouteDetails routeDetails,
      String originAddress, String destinationAddress) async {
    // Early return if no valid route direction
    if (routeDetails.direction == null) {
      return RouteSegments(
          leg1: null,
          leg2: const Polyline(polylineId: PolylineId('empty')),
          leg3: null);
    }

    // Load shuttle coordinates from the repository
    List<LatLng> shuttleCoordinates =
        await _shuttleRepository.loadShuttleRoute(routeDetails.direction!);

    // Prepare coordinate strings
    final String boardingStr =
        "${routeDetails.boardingStop.latitude},${routeDetails.boardingStop.longitude}";
    final String disembarkStr =
        "${routeDetails.disembarkStop.latitude},${routeDetails.disembarkStop.longitude}";
    final String originStr =
        "${routeDetails.originCoords!.latitude},${routeDetails.originCoords!.longitude}";
    final String destStr =
        "${routeDetails.destinationCoords!.latitude},${routeDetails.destinationCoords!.longitude}";

    // Fetch walking segments
    final Polyline? leg1 = await _odsDirectionsService.fetchWalkingPolyline(
      originAddress: originStr,
      destinationAddress: boardingStr,
      polylineId: "walking_leg1_${routeDetails.polylineIdSuffix}",
    );

    final Polyline? leg3 = await _odsDirectionsService.fetchWalkingPolyline(
      originAddress: disembarkStr,
      destinationAddress: destStr,
      polylineId: "walking_leg3_${routeDetails.polylineIdSuffix}",
    );

    // Create the shuttle segment polyline
    final Polyline leg2 = Polyline(
      polylineId: PolylineId("shuttleSegment_${routeDetails.polylineIdSuffix}"),
      points: shuttleCoordinates,
      color: const Color(0xFF2196F3),
      patterns: [PatternItem.dot, PatternItem.gap(10)],
      width: 5,
    );

    return RouteSegments(leg1: leg1, leg2: leg2, leg3: leg3);
  }

  void _processShuttleRoute(
      ShuttleRouteDetails routeDetails, RouteSegments routeSegments) {
    // Early return if no valid route direction
    if (routeDetails.direction == null) return;

    // Merge walking segments with the shuttle segment
    List<LatLng> compositePoints = _getCompositePoints(
        routeSegments.leg1, routeSegments.leg2, routeSegments.leg3);

    final Polyline shuttleComposite = Polyline(
      polylineId:
          PolylineId("shuttleComposite_${routeDetails.polylineIdSuffix}"),
      points: compositePoints,
      color: const Color(0xFF2196F3),
      patterns: [PatternItem.dot, PatternItem.gap(10)],
      width: 5,
    );

    multiModeRoutes[CustomTravelMode.shuttle] = shuttleComposite;

    // Calculate walking and shuttle times
    int walkingTimeToShuttle = _calculateWalkingTime(routeSegments.leg1);
    int walkingTimeFromShuttle = _calculateWalkingTime(routeSegments.leg3);
    int shuttleRideTime = 30; // Fixed shuttle ride time provided by Concordia
    int totalShuttleTime =
        walkingTimeToShuttle + shuttleRideTime + walkingTimeFromShuttle;

    _multiModeTravelTimes[CustomTravelMode.shuttle] = "$totalShuttleTime min";

    // Update markers if shuttle is selected travel mode
    _updateShuttleMarkers(
        routeDetails, compositePoints, routeDetails.boardingStop);

    notifyListeners();
  }

  int _calculateWalkingTime(Polyline? leg) {
    if (leg != null && leg.points.isNotEmpty) {
      return (calculatePolylineDistance(leg) / 1.4 / 60).round();
    }
    return 0;
  }

  void _updateShuttleMarkers(ShuttleRouteDetails routeDetails,
      List<LatLng> compositePoints, LatLng boardingStop) {
    if (_selectedTravelModeForRoute == CustomTravelMode.shuttle) {
      _multiModeActivePolylines = {multiModeRoutes[CustomTravelMode.shuttle]!};

      _originMarker = Marker(
        markerId: const MarkerId('origin'),
        position:
            compositePoints.isNotEmpty ? compositePoints.first : boardingStop,
        infoWindow: const InfoWindow(title: 'origin'),
        anchor: const Offset(0.5, 0.5),
      );

      _destinationMarker = Marker(
        markerId: const MarkerId('destination'),
        position:
            compositePoints.isNotEmpty ? compositePoints.last : boardingStop,
        infoWindow: const InfoWindow(title: 'Destination'),
      );
    }
  }

  double calculatePolylineDistance(Polyline polyline) {
    double totalDistance = 0.0;
    for (int i = 0; i < polyline.points.length - 1; i++) {
      totalDistance += _mapService.calculateDistance(
          polyline.points[i], polyline.points[i + 1]);
    }
    return totalDistance;
  }

  Future<void> setActiveModeForRoute(CustomTravelMode mode) async {
    _selectedTravelModeForRoute = mode;
    if (multiModeRoutes.containsKey(mode)) {
      _multiModeActivePolylines = {multiModeRoutes[mode]!};
      final polyline = multiModeRoutes[mode]!;
      if (polyline.points.isNotEmpty) {
        _originMarker = Marker(
          markerId: const MarkerId('origin'),
          position: polyline.points.first,
          infoWindow: const InfoWindow(title: 'Your Origin'),
          icon:
              await IconLoader.loadBitmapDescriptor('assets/icons/origin.png'),
          anchor: const Offset(0.5, 0.5),
          zIndex: 2,
        );
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

  double getDistance(LatLng point1, LatLng point2) {
    return _mapService.calculateDistance(point1, point2);
  }

  void startShuttleBusTimer() {
    shuttleBusTimer?.cancel();

    if (!kDebugMode) {
      shuttleBusTimer = Timer.periodic(const Duration(seconds: 15), (_) {
        fetchShuttleBusData();
      });
    }
  }

  void stopShuttleBusTimer() {
    shuttleBusTimer?.cancel();
  }

  Future<void> fetchShuttleBusData({http.Client? client}) async {
    final httpClient = client ?? http.Client();
    try {
      final getResponse = await httpClient.get(
        Uri.parse('https://shuttle.concordia.ca/concordiabusmap/Map.aspx'),
        headers: {'Host': 'shuttle.concordia.ca'},
      );
      String? cookies = getResponse.headers['set-cookie'];

      final postResponse = await httpClient.post(
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
    if (!_isDisposed) {
      notifyListeners();
    }
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
    shuttleBusTimer?.cancel();
    shuttleMarkersNotifier.dispose();
    super.dispose();
  }

  /// Handles the search selection of a building.
  Future<void> handleSelection(
      String selectedBuilding, LatLng? currentLocation) async {
    final buildingViewModel = BuildingViewModel();

    // If the selected building is "Your Location", wait for fetchCurrentLocation to complete
    LatLng? location;

    if (selectedBuilding == yourLocationString) {
      location = currentLocation;
    } else {
      location = buildingViewModel.getBuildingLocationByName(selectedBuilding);
    }

    if (location == null) return;

    moveToLocation(location);
  }

  final PlacesService _placesService = PlacesService();

  Future<List<Place>> searchNearbyPlaces(PlaceType category) async {
    final currentLocation = await _mapService.getCurrentLocation();
    if (currentLocation == null) throw Exception("Location unavailable");

    return await _placesService.getNearbyPlaces(
      currentLocation: currentLocation,
      category: category,
    );
  }

  // TODO: Implement this method to show places on the map.
  // void showPlacesOnMap(List<Place> places) {
  //   final markers = places
  //       .map((place) => Marker(
  //             markerId: MarkerId(place.id),
  //             position: place.location,
  //             infoWindow: InfoWindow(title: place.name),
  //           ))
  //       .toSet();

  //   // Update map markers
  //   _markersNotifier.value = markers;
  // }
}

class ShuttleRouteDetails {
  final LatLng? originCoords;
  final LatLng? destinationCoords;
  final bool originNearLOY;
  final bool originNearSGW;
  final bool destNearLOY;
  final bool destNearSGW;
  final ShuttleRouteDirection? direction;
  final LatLng boardingStop;
  final LatLng disembarkStop;
  final String polylineIdSuffix;

  ShuttleRouteDetails({
    required this.originCoords,
    required this.destinationCoords,
    required this.originNearLOY,
    required this.originNearSGW,
    required this.destNearLOY,
    required this.destNearSGW,
    required this.direction,
    required this.boardingStop,
    required this.disembarkStop,
    required this.polylineIdSuffix,
  });
}

class RouteSegments {
  final Polyline? leg1;
  final Polyline leg2;
  final Polyline? leg3;

  RouteSegments({
    required this.leg1,
    required this.leg2,
    required this.leg3,
  });
}
