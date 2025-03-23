import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/domain-model/concordia_campus.dart';
import '../../data/domain-model/place.dart';
import '../../data/services/places_service.dart';
import '../../utils/map_viewmodel.dart';
import '../../utils/poi/poi_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/map_control_buttons.dart';
import '../../widgets/poi_info_drawer.dart';
import '../../widgets/radius_bar.dart';
import '../outdoor_location/outdoor_location_map_view.dart';

class NearbyPOIMapView extends StatefulWidget {
  final POIViewModel poiViewModel;
  final PlaceType category;
  final Set<Marker>? markers; // Specifically for tests

  const NearbyPOIMapView({
    super.key,
    required this.poiViewModel,
    required this.category,
    this.markers,
  });

  @override
  State<NearbyPOIMapView> createState() => _NearbyPOIMapViewState();
}

class _NearbyPOIMapViewState extends State<NearbyPOIMapView> {
  late POIViewModel _viewModel;
  late MapViewModel _mapViewModel;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  Place? _selectedPlace;
  bool _isDrawerVisible = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.poiViewModel;
    _mapViewModel = MapViewModel();

    // Add listener to ViewModel to update UI when data changes
    _viewModel.addListener(_onViewModelChanged);

    // Schedule the initialization for after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _mapViewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      _updateMarkersFromViewModel();
    }
  }

  Future<void> _initialize() async {
    if (_initialized) return;

    setState(() {
      _isLoading = true;
    });

    await _viewModel.loadOutdoorPOIs(widget.category);
    await _updateMarkersFromViewModel();

    setState(() {
      _isLoading = false;
      _initialized = true;
    });
  }

  Future<void> _updateMarkersFromViewModel() async {
    if (!mounted) return;

    Set<Marker> markers;
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      // Use the ViewModel's marker creation method
      markers = await _viewModel.createMarkersForOutdoorPOIs((place) {
        setState(() {
          _selectedPlace = place;
          _isDrawerVisible = true;
        });
      });
    } else {
      markers = widget.markers!;
    }
    // Only update state if the widget is still mounted
    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapViewModel.onMapCreated(controller);
    _centerCameraOnPOIs();
  }

  void _centerCameraOnPOIs() {
    if (_markers.isEmpty) return;

    // Include all markers and the user's location
    final List<LatLng> points =
        _markers.map((marker) => marker.position).toList();

    // Add current location if available
    if (_viewModel.currentLocation != null) {
      points.add(_viewModel.currentLocation!);
    }

    // skip for tests
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      _mapViewModel.adjustCamera(points);
    }
  }

  void _closeDrawer() {
    setState(() {
      _isDrawerVisible = false;
    });
  }

  void _navigateToDirections(Place place) {
    final MapViewModel mapViewModel = MapViewModel();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OutdoorLocationMapView(
          campus: ConcordiaCampus.sgw,
          mapViewModel: mapViewModel,
          additionalData: {
            'place': place,
            'destinationLatLng': place.location,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            customAppBar(context, _viewModel.getCategoryTitle(widget.category)),
        body: Stack(children: [
          Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    _isLoading || _viewModel.isLoadingOutdoor
                        ? const Center(child: CircularProgressIndicator())
                        : GoogleMap(
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: _viewModel.currentLocation ??
                                  const LatLng(45.495,
                                      -73.578), // Default to Montreal if no location
                              zoom: 15.0,
                            ),
                            markers: _markers,
                            zoomControlsEnabled: false,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                          ),

                    // List toggle button
                    Positioned(
                      top: 80,
                      right: 16,
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16.0)),
                            ),
                            builder: (context) => DraggableScrollableSheet(
                              initialChildSize: 0.5,
                              minChildSize: 0.25,
                              maxChildSize: 0.75,
                              expand: false,
                              builder: (context, scrollController) {
                                return _buildPOIList(scrollController);
                              },
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100)),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 3,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.list, color: Colors.white),
                        ),
                      ),
                    ),

                    // Location button
                    MapControllerButtons(
                      mapViewModel: _mapViewModel,
                      style: 3,
                    ),
                  ],
                ),
              ),

              // Radius bar at the bottom
              _buildSearchControls(),
            ],
          ),

          // POI Info Drawer
          if (_isDrawerVisible && _selectedPlace != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: POIInfoDrawer(
                place: _selectedPlace!,
                onClose: _closeDrawer,
                onDirections: () => _navigateToDirections(_selectedPlace!),
              ),
            ),
        ]));
  }

  Widget _buildPOIList(ScrollController scrollController) {
    final places = _viewModel.filteredOutdoorPOIs;
    return Container(
      decoration: _listContainerDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHandleBar(),
          _buildHeader(),
          _buildResultsCount(places.length),
          _buildPlacesList(scrollController, places),
        ],
      ),
    );
  }

  BoxDecoration _listContainerDecoration() {
    return const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
    );
  }

  Widget _buildHandleBar() {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(2.5),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nearby ${_viewModel.getCategoryTitle(widget.category)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildResultsCount(int count) {
    return Column(
      children: [
        Text(
          '$count results found',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPlacesList(
      ScrollController scrollController, List<Place> places) {
    return Expanded(
      child: places.isEmpty
          ? const Center(child: Text('No places found'))
          : ListView.builder(
              controller: scrollController,
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];
                return Column(
                  children: [
                    _buildPlaceItem(place, index, places.length),
                    if (index < places.length - 1) _buildDivider(),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildPlaceItem(Place place, int index, int totalPlaces) {
    return InkWell(
      onTap: () => _onPlaceTap(place),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildPOIIcon(),
            _buildPOIInfo(place),
            _buildDirectionsButton(place),
          ],
        ),
      ),
    );
  }

  void _onPlaceTap(Place place) {
    Navigator.pop(context);
    _mapViewModel.moveToLocation(place.location);

    setState(() {
      _selectedPlace = place;
      _isDrawerVisible = true;
    });
  }

  Widget _buildPOIIcon() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 16.0),
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Theme.of(context).primaryColor.withAlpha(26),
        child: Icon(
          _viewModel.getIconForPlaceType(widget.category),
          color: Theme.of(context).primaryColor,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildPOIInfo(Place place) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(place.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(place.address ?? 'No address available',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          if (place.formattedDistance != null ||
              place.formattedDuration != null)
            _buildTravelInfo(place),
          _buildStatusAndRating(place),
        ],
      ),
    );
  }

  Widget _buildTravelInfo(Place place) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          Icon(_viewModel.getIconForTravelMode(_viewModel.travelMode),
              size: 14, color: Theme.of(context).primaryColor),
          const SizedBox(width: 4),
          if (place.formattedDistance != null)
            Text(place.formattedDistance!,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500)),
          if (place.formattedDistance != null &&
              place.formattedDuration != null)
            const SizedBox(width: 4),
          if (place.formattedDuration != null)
            Text(place.formattedDuration!,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStatusAndRating(Place place) {
    return Row(
      children: [
        if (place.isOpen != null) _buildOpenStatus(place.isOpen!),
        if (place.rating != null)
          _buildRating(place.rating!, place.userRatingCount),
      ],
    );
  }

  Widget _buildOpenStatus(bool isOpen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isOpen ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(4),
        border:
            Border.all(color: isOpen ? Colors.green : Colors.red, width: 0.5),
      ),
      child: Text(isOpen ? 'Open' : 'Closed',
          style: TextStyle(
              fontSize: 10,
              color: isOpen ? Colors.green[800] : Colors.red[800],
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRating(double rating, int? userRatingCount) {
    return Row(
      children: [
        const Icon(Icons.star, size: 14, color: Colors.amber),
        const SizedBox(width: 2),
        Text(rating.toStringAsFixed(1),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        if (userRatingCount != null)
          Text(' ($userRatingCount)',
              style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildDirectionsButton(Place place) {
    return InkWell(
      onTap: () => _navigateToDirections(place),
      child: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(25),
        radius: 19,
        child: Icon(Icons.directions,
            color: Theme.of(context).primaryColor, size: 28),
      ),
    );
  }

  Widget _buildDivider() => Divider(
      color: Colors.grey[300],
      height: 1,
      thickness: 1,
      indent: 70,
      endIndent: 16);

  void _showTravelModeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Select Travel Mode',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.directions_car,
                  color: _viewModel.travelMode == TravelMode.DRIVE
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                title: const Text('Driving'),
                selected: _viewModel.travelMode == TravelMode.DRIVE,
                onTap: () async {
                  Navigator.pop(context);
                  await _viewModel.setTravelMode(TravelMode.DRIVE);
                  _centerCameraOnPOIs();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.directions_walk,
                  color: _viewModel.travelMode == TravelMode.WALK
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                title: const Text('Walking'),
                selected: _viewModel.travelMode == TravelMode.WALK,
                onTap: () async {
                  Navigator.pop(context);
                  await _viewModel.setTravelMode(TravelMode.WALK);
                  _centerCameraOnPOIs();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.directions_bike,
                  color: _viewModel.travelMode == TravelMode.BICYCLE
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                title: const Text('Cycling'),
                selected: _viewModel.travelMode == TravelMode.BICYCLE,
                onTap: () async {
                  Navigator.pop(context);
                  await _viewModel.setTravelMode(TravelMode.BICYCLE);
                  _centerCameraOnPOIs();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchControls() {
    return RadiusBar(
      initialValue: _viewModel.searchRadius,
      minValue: 500,
      maxValue: 2000,
      showMeters: false,
      onRadiusChanged: (value) async {
        // Only set the radius value without reloading POIs
        await _viewModel.setSearchRadius(value);
        // Don't call any method that triggers data reloading
      },
      onRadiusChangeEnd: (value) async {
        // Optionally add this callback to RadiusBar to apply changes
        // when the user has finished adjusting the radius
        await _viewModel.applyRadiusChange();
      },
      travelModeSelector: _buildTravelModeButton(),
    );
  }

  Widget _buildTravelModeButton() {
    return InkWell(
      onTap: () => _showTravelModeSelector(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withAlpha(25),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _viewModel.getIconForTravelMode(_viewModel.travelMode),
              size: 18,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              _viewModel.travelMode.name.toLowerCase().capitalize(),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
