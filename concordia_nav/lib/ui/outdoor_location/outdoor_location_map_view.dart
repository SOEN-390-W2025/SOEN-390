// ignore_for_file: use_build_context_synchronously, deprecated_member_use, avoid_catches_without_on_clauses

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../../utils/map_viewmodel.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../data/domain-model/concordia_campus.dart';
import '../../data/domain-model/location.dart';
import '../../data/domain-model/place.dart';
import '../../data/services/outdoor_directions_service.dart';
import '../../utils/building_viewmodel.dart';
import '../../utils/settings/preferences_viewmodel.dart';
import '../../widgets/build_info_drawer.dart';
import '../../widgets/compact_location_search_widget.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/map_layout.dart';
import 'package:google_directions_api/google_directions_api.dart' as gda;

class OutdoorLocationMapView extends StatefulWidget {
  final ConcordiaCampus campus;
  final ConcordiaBuilding? building;
  final MapViewModel? mapViewModel;
  final bool hideAppBar;
  final bool hideInputs;
  final Location? providedJourneyStart;
  final Location? providedJourneyDest;
  final Map<String, dynamic>?
      additionalData; // For Place data from NearbyPOIMapView

  const OutdoorLocationMapView({
    super.key,
    required this.campus,
    this.building,
    this.mapViewModel,
    this.hideAppBar = false,
    this.hideInputs = false,
    this.providedJourneyStart,
    this.providedJourneyDest,
    this.additionalData,
  });

  @override
  State<OutdoorLocationMapView> createState() => OutdoorLocationMapViewState();
}

class OutdoorLocationMapViewState extends State<OutdoorLocationMapView>
    with WidgetsBindingObserver {
  late MapViewModel _mapViewModel;
  final BuildingViewModel _buildingViewModel = BuildingViewModel();
  late ConcordiaCampus _currentCampus;
  late Future<CameraPosition>? _initialCameraPosition;
  bool _locationPermissionGranted = false;
  late TextEditingController _sourceController;
  late TextEditingController _destinationController;

  // POI state variables
  Place? _selectedPlace;
  bool _isFromPoi = false;
  LatLng? _poiDestinationLatLng;

  List<String> searchList = [];
  bool isKeyboardVisible = false;
  double? bottomInset = 0;
  bool first = false;

  final _yourLocationString = "Your Location";

  void getSearchList() {
    final buildings = _buildingViewModel.getBuildings();
    for (var building in buildings) {
      if (!searchList.contains(building)) {
        searchList.add(building);
      }
    }

    // Add POI name to search list if coming from POI view
    if (_isFromPoi &&
        _selectedPlace != null &&
        !searchList.contains(_selectedPlace!.name)) {
      searchList.add(_selectedPlace!.name);
    }
  }

  void checkLocationPermission() {
    _mapViewModel.checkLocationAccess().then((hasPermission) {
      if (!mounted) return;
      setState(() {
        _locationPermissionGranted = hasPermission;
        if (_locationPermissionGranted) {
          _sourceController.text = _yourLocationString;
          if (!searchList.contains(_yourLocationString)) {
            searchList.insert(0, _yourLocationString);
          }
        }
        else {
          _sourceController.text = '';
        }
      });
    });
  }

  CustomTravelMode _mapTransportPreferenceToTravelMode(String preference) {
    switch (preference.toLowerCase()) {
      case 'driving':
        return CustomTravelMode.driving;
      case 'walking':
        return CustomTravelMode.walking;
      case 'biking':
        return CustomTravelMode.bicycling;
      case 'transit':
        return CustomTravelMode.transit;
      default:
        return CustomTravelMode.driving;
    }
  }

  Future<void> _useStandardRoute() async {
    await _mapViewModel.fetchRoutesForAllModes(
        _yourLocationString, _destinationController.text);
    if (!mounted) return;
    final preferences = Provider.of<PreferencesModel>(context, listen: false);
    final mode =
        _mapTransportPreferenceToTravelMode(preferences.selectedTransportation);
    if (_mapViewModel.multiModeRoutes.containsKey(mode)) {
      await _mapViewModel.setActiveModeForRoute(mode);
    } else if (_mapViewModel.multiModeRoutes.isNotEmpty) {
      await _mapViewModel
          .setActiveModeForRoute(_mapViewModel.multiModeRoutes.keys.first);
    }
  }

  Future<void> _setPreference(Polyline polyline) async {
    final preferences = Provider.of<PreferencesModel>(context, listen: false);
    final mode =
        _mapTransportPreferenceToTravelMode(preferences.selectedTransportation);

    _mapViewModel.multiModeRoutes[mode] = polyline;
    await _mapViewModel.setActiveModeForRoute(mode);
    if (mounted) setState(() {});
  }

  Future<void> _updatePath() async {
    if (!mounted) return;
    final start = widget.providedJourneyStart;
    final end = widget.providedJourneyDest;

    if (start != null && end != null) {
      // If a providedJourneyStart and providedJourneyDest exist then we'll
      // work with this. It's specifically for the case where an OutdoorMapView
      // is used in the context of Navigation to Next Class or Smart Planner
      // Directions.
      final origin = LatLng(start.lat, start.lng);
      final destination = LatLng(end.lat, end.lng);

      final polylinePoints = await _mapViewModel.odsDirectionsService
          .fetchRouteFromCoords(origin, destination,
              transport: gda.TravelMode.walking);

      final polyline = Polyline(
        polylineId: const PolylineId('direct_coords_polyline'),
        points: polylinePoints,
        color: const Color(0xFF2196F3),
        patterns: [PatternItem.dot, PatternItem.gap(10)],
        width: 5,
      );

      if (!mounted) return;
      await _setPreference(polyline);
      return;
    }

    // If Location objects aren't provided, we work with the default address
    // i.e. the regular "Outdoor Directions" page
    if (_destinationController.text != '') {
      if (_isFromPoi && _poiDestinationLatLng != null) {
        // Use custom route to POI
        await _calculateCustomRouteToPOI();
      } else if (_locationPermissionGranted) {
        // Use standard route to building
        await _useStandardRoute();
      }
      if (!mounted) return;
      setState(() {});
    }
    first = false;
  }

  Future<void> setDefaultTravelMode() async {
    final preferences = Provider.of<PreferencesModel>(context, listen: false);
    final mode =
        _mapTransportPreferenceToTravelMode(preferences.selectedTransportation);
    if (_mapViewModel.multiModeRoutes.containsKey(mode)) {
      await _mapViewModel.setActiveModeForRoute(mode);
    } else if (_mapViewModel.multiModeRoutes.isNotEmpty) {
      await _mapViewModel
          .setActiveModeForRoute(_mapViewModel.multiModeRoutes.keys.first);
    }
  }

  Future<void> _calculateTravelModes(
      CustomTravelMode mode,
      ODSDirectionsService odsDirectionsService,
      String originStr,
      String destStr) async {
    final gdaMode = toGdaTravelMode(mode);
    if (gdaMode != null) {
      final result = await odsDirectionsService.fetchRouteResult(
        originAddress: originStr,
        destinationAddress: destStr,
        travelMode: gdaMode,
        polylineId: mode.toString(),
      );

      if (result.polyline != null) {
        _mapViewModel.multiModeRoutes[mode] = result.polyline!;
        _mapViewModel.travelTimes[mode] = result.travelTime;
      } else {
        _mapViewModel.travelTimes[mode] = "--";
      }
    }
  }

  // New method to calculate a route directly to a POI
  Future<void> _calculateCustomRouteToPOI() async {
    if (!mounted) return;
    if (_poiDestinationLatLng == null) return;

    try {
      // Get the user's current location
      final LatLng? origin = await _mapViewModel.fetchCurrentLocation();
      if (origin == null) {
        throw Exception('Could not determine your location');
      }

      // Prepare strings for direction service
      final originStr = "${origin.latitude},${origin.longitude}";
      final destStr =
          "${_poiDestinationLatLng!.latitude},${_poiDestinationLatLng!.longitude}";

      // Use the outdoor directions service to calculate routes
      final odsDirectionsService = ODSDirectionsService();
      final modes = [
        CustomTravelMode.driving,
        CustomTravelMode.walking,
        CustomTravelMode.bicycling,
        CustomTravelMode.transit,
      ];

      // Clear existing routes
      _mapViewModel.multiModeRoutes.clear();
      _mapViewModel.travelTimes.clear();
      _mapViewModel.activePolylines.clear();

      // Calculate each travel mode
      for (var mode in modes) {
        await _calculateTravelModes(
            mode, odsDirectionsService, originStr, destStr);
      }

      // Set default travel mode
      if (!mounted) return;
      await setDefaultTravelMode();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error calculating route: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _mapViewModel = widget.mapViewModel ?? MapViewModel();
    _sourceController = TextEditingController();

    // Initialize POI-related variables
    if (widget.additionalData != null &&
        widget.additionalData!.containsKey('place')) {
      _isFromPoi = true;
      _selectedPlace = widget.additionalData!['place'] as Place;
      _poiDestinationLatLng =
          widget.additionalData!['destinationLatLng'] as LatLng?;
      _destinationController =
          TextEditingController(text: _selectedPlace!.name);
    } else {
      _destinationController =
          TextEditingController(text: widget.building?.name ?? '');
    }

    _currentCampus = widget.campus;
    _initialCameraPosition =
        _mapViewModel.getInitialCameraPosition(_currentCampus);
    checkLocationPermission();
    getSearchList();
    WidgetsBinding.instance.addObserver(this);

    final preferences = Provider.of<PreferencesModel>(context, listen: false);
    final mode =
        _mapTransportPreferenceToTravelMode(preferences.selectedTransportation);
    _mapViewModel.setActiveModeForRoute(mode);

    if (_destinationController.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updatePath();
        }
      });
    }
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _destinationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _launchGoogleMapsNavigation(LatLng destination) async {
    final url =
        'google.navigation:q=${destination.latitude},${destination.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildModeChip(CustomTravelMode mode) {
    final String time = _mapViewModel.travelTimes[mode] ?? "--";
    final bool isSelected = _mapViewModel.selectedTravelMode == mode;

    Widget iconWidget;
    if (mode == CustomTravelMode.shuttle) {
      iconWidget = SvgPicture.asset(
        'assets/icons/shuttle-bus-transport-icon.svg',
        color: isSelected ? Colors.red : Colors.black,
        width: 24,
        height: 24,
      );
    } else {
      const modeIconMap = {
        CustomTravelMode.driving: Icons.directions_car,
        CustomTravelMode.walking: Icons.directions_walk,
        CustomTravelMode.bicycling: Icons.directions_bike,
        CustomTravelMode.transit: Icons.directions_transit_filled_outlined,
      };
      iconWidget = Icon(
        modeIconMap[mode]!,
        color: isSelected ? Colors.red : Colors.black,
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _mapViewModel.setActiveModeForRoute(mode);
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const SizedBox(width: 6),
            Text(
              time,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPanel() {
    final bool showModeChips = _mapViewModel.travelTimes.isNotEmpty;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.hideInputs)
              CompactSearchCardWidget(
                originController: _sourceController,
                destinationController: _destinationController,
                mapViewModel: _mapViewModel,
                searchList: searchList,
                onDirectionFetched: () {
                  first = false;
                  setState(() {});
                },
                selectedPlace: _selectedPlace,
              ),
            if (showModeChips)
              Container(
                color: Colors.white,
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: CustomTravelMode.values
                        .where((mode) {
                          final String time =
                              _mapViewModel.travelTimes[mode] ?? "--";
                          if (time == "--") return false;
                          if (mode == CustomTravelMode.shuttle) {
                            return _mapViewModel.shuttleAvailable;
                          }
                          return true;
                        })
                        .map((mode) => _buildModeChip(mode))
                        .toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Center _getCamSnapshot(AsyncSnapshot<CameraPosition> camSnapshot) {
    if (camSnapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (camSnapshot.hasError) {
      return const Center(child: Text('Error loading campus map'));
    }
    return const Center(child: Text('Map loaded successfully'));
  }

  Widget _visibleKeyboardWidget() {
    return Positioned(
      bottom: 30,
      left: 15,
      right: 15,
      child: Row(
        children: [
          if (_destinationController.text != 'null')
            Expanded(
              child: ElevatedButton(
                onPressed: _updatePath,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: Text(
                  'Get Directions',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ),
          if (_mapViewModel.destinationMarker != null)
            const SizedBox(width: 16),
          if (_mapViewModel.destinationMarker != null)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.navigation_outlined,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () {
                  final destination = _mapViewModel.destinationMarker!.position;
                  _launchGoogleMapsNavigation(destination);
                },
              ),
            ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    if (_isFromPoi && _selectedPlace != null) {
      return 'Directions to ${_selectedPlace!.name}';
    } else {
      return widget.campus.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (widget.hideAppBar)
          ? null
          : customAppBar(
              context,
              _getAppBarTitle(),
            ),
      body: Semantics(
        label:
            'Outdoor map for Concordia campuses, points of interest, and directions.',
        child: Stack(
          children: [
            _buildMap(),
            _buildTopPanel(),
            _visibleKeyboardWidget(),
            BuildInfoDrawer(mapViewModel: _mapViewModel),
          ],
        ),
      ),
    );
  }

  Set<Marker> _addPOIMarker(Set<Marker> markers) {
    final allMarkers = markers;
    if (_isFromPoi &&
        _poiDestinationLatLng != null &&
        _mapViewModel.destinationMarker == null) {
      allMarkers.add(
        Marker(
          markerId: const MarkerId('poi_destination'),
          position: _poiDestinationLatLng!,
          infoWindow: InfoWindow(
            title: _selectedPlace?.name ?? 'Destination',
            snippet: _selectedPlace?.address ?? '',
          ),
        ),
      );
    }
    return allMarkers;
  }

  Widget _buildMap() {
    return FutureBuilder<CameraPosition>(
      future: _initialCameraPosition,
      builder: (context, camSnapshot) {
        _getCamSnapshot(camSnapshot);
        return FutureBuilder<Map<String, dynamic>>(
          future: _mapViewModel.getAllCampusPolygonsAndLabels(),
          builder: (context, polySnapshot) {
            // skip for tests
            if (!Platform.environment.containsKey('FLUTTER_TEST')) {
              if (polySnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
            }
            final Set<Polygon> polygons = polySnapshot.data?["polygons"] ?? {};
            final Set<Marker> labelMarkers = polySnapshot.data?["labels"] ?? {};

            return ValueListenableBuilder<Set<Marker>>(
              valueListenable: _mapViewModel.shuttleMarkersNotifier,
              builder: (context, shuttleMarkers, _) {
                Set<Marker> allMarkers =
                    _buildAllMarkers(labelMarkers, shuttleMarkers);
                // Add POI marker if coming from POI view and no route is calculated yet
                allMarkers = _addPOIMarker(allMarkers);

                if ((!_locationPermissionGranted &&
                    _sourceController.text == _yourLocationString &&
                    widget.providedJourneyStart == null)) {
                  return const Center(
                      child: Text('Location permission not granted'));
                }
                return _buildGoogleMap(camSnapshot, polygons, allMarkers);
              },
            );
          },
        );
      },
    );
  }

  Set<Marker> _buildAllMarkers(
      Set<Marker> labelMarkers, Set<Marker> shuttleMarkers) {
    final allMarkers = {
      ...labelMarkers,
      ..._mapViewModel.staticBusStopMarkers,
      ...shuttleMarkers,
    };
    if (_mapViewModel.originMarker != null) {
      allMarkers.add(_mapViewModel.originMarker!);
    }
    if (_mapViewModel.destinationMarker != null) {
      allMarkers.add(_mapViewModel.destinationMarker!);
    }
    return allMarkers;
  }

  Widget _buildGoogleMap(AsyncSnapshot<CameraPosition> camSnapshot,
      Set<Polygon> polygons, Set<Marker> allMarkers) {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      // ignore: parameter_assignments
      camSnapshot = const AsyncSnapshot<CameraPosition>.withData(
        ConnectionState.done,
        CameraPosition(target: LatLng(45.4940, -73.5784), zoom: 15),
      );
    }
    return MapLayout(
      mapWidget: Semantics(
        label: 'Google Map',
        child: GoogleMap(
          onMapCreated: _mapViewModel.onMapCreated,
          initialCameraPosition: camSnapshot.data!,
          zoomControlsEnabled: false,
          polylines: _mapViewModel.activePolylines,
          markers: allMarkers,
          polygons: polygons,
          myLocationButtonEnabled: false,
          buildingsEnabled: false,
          myLocationEnabled: _locationPermissionGranted,
        ),
      ),
      mapViewModel: _mapViewModel,
      style: 2,
    );
  }
}
