import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/domain-model/concordia_campus.dart';
import '../../data/domain-model/place.dart';
import '../../data/services/places_service.dart';
import '../../utils/map_viewmodel.dart';
import '../../utils/poi/poi_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/poi_info_drawer.dart';
import '../outdoor_location/outdoor_location_map_view.dart';

class NearbyPOIMapView extends StatefulWidget {
  final POIViewModel poiViewModel;
  final PlaceType category;

  const NearbyPOIMapView({
    super.key,
    required this.poiViewModel,
    required this.category,
  });

  @override
  State<NearbyPOIMapView> createState() => _NearbyPOIMapViewState();
}

class _NearbyPOIMapViewState extends State<NearbyPOIMapView> {
  late POIViewModel _viewModel;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  Place? _selectedPlace;
  bool _isDrawerVisible = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.poiViewModel;
    
    // Schedule the initialization for after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    if (_initialized) return;
    
    setState(() {
      _isLoading = true;
    });

    await _viewModel.loadOutdoorPOIs(widget.category);
    await _createMarkers();

    setState(() {
      _isLoading = false;
      _initialized = true;
    });
  }

  Future<void> _createMarkers() async {
    final places = _viewModel.filteredOutdoorPOIs;
    final Set<Marker> markers = {};

    // Add POI markers
    for (var i = 0; i < places.length; i++) {
      final place = places[i];
      markers.add(
        Marker(
          markerId: MarkerId(place.id),
          position: place.location,
          infoWindow: InfoWindow(
            title: place.name,
            snippet: place.address ?? 'No address available',
          ),
          onTap: () {
            setState(() {
              _selectedPlace = place;
              _isDrawerVisible = true;
            });
          },
        ),
      );
    }

    // Only update state if the widget is still mounted
    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _centerCameraOnPOIs();
  }

  void _centerCameraOnPOIs() {
    if (_markers.isEmpty || _mapController == null) return;

    // Include all markers and the user's location
    final List<LatLng> points = _markers.map((marker) => marker.position).toList();

    // Calculate bounds
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    // Add some padding to the bounds
    const double padding = 0.01; // Approximately 1 km
    final LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat - padding, minLng - padding),
      northeast: LatLng(maxLat + padding, maxLng + padding),
    );

    // Animate camera to show all markers with padding
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  void _closeDrawer() {
    setState(() {
      _isDrawerVisible = false;
    });
  }

  // Modified to use OutdoorLocationMapView instead of POIDirectionView
  void _navigateToDirections(Place place) {
    // Create a MapViewModel instance for the location view
    final MapViewModel mapViewModel = MapViewModel();
    
    // Navigate to OutdoorLocationMapView
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OutdoorLocationMapView(
          campus: ConcordiaCampus.sgw, // Default to SGW campus
          mapViewModel: mapViewModel,
          // Pass additional data needed for directions
          additionalData: {
            'place': place,
            'destinationLatLng': place.location,
          },
        ),
      ),
    );
  }

  String _getCategoryTitle() {
    switch (widget.category) {
      case PlaceType.foodDrink:
        return 'Nearby Restaurants';
      case PlaceType.coffeeShop:
        return 'Nearby Coffee Shops';
      case PlaceType.healthCenter:
        return 'Nearby Health Centers';
      case PlaceType.studyPlace:
        return 'Nearby Study Places';
      case PlaceType.gym:
        return 'Nearby Gyms';
      case PlaceType.grocery:
        return 'Nearby Grocery Stores';
      // ignore: unreachable_switch_default
      default:
        return 'Nearby Places';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, _getCategoryTitle()),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _viewModel.currentLocation,
                    zoom: 15.0,
                  ),
                  markers: _markers,
                  zoomControlsEnabled: false,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                ),
          // Search radius control
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search Radius: ${_viewModel.searchRadius / 1000} km',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Slider(
                      value: _viewModel.searchRadius,
                      min: 500,
                      max: 2000,
                      divisions: 6,
                      label: '${_viewModel.searchRadius / 1000} km',
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (value) async {
                        await _viewModel.setSearchRadius(value);
                        if (mounted) {
                          await _createMarkers();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // List toggle button
          Positioned(
            top: 80,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'list_view',
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.list),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
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
            ),
          ),
          // Location button
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'my_location',
              backgroundColor: Colors.white,
              child: Icon(Icons.my_location, color: Theme.of(context).primaryColor),
              onPressed: () {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    _viewModel.currentLocation,
                    16,
                  ),
                );
              },
            ),
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
        ],
      ),
    );
  }

  Widget _buildPOIList(ScrollController scrollController) {
    final places = _viewModel.filteredOutdoorPOIs;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(2.5)),
              ),
            ),
          ),
          
          // Header
          Text(
            'Nearby ${_getCategoryTitle()}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Results count
          Text(
            '${places.length} results found',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          
          // List of places
          Expanded(
            child: places.isEmpty
                ? const Center(child: Text('No places found'))
                : ListView.builder(
                    controller: scrollController,
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      final place = places[index];
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // POI Icon
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 16.0, top: 8.0),
                                  child: CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Theme.of(context).primaryColor.withAlpha(26),
                                    child: Icon(
                                      _getIconForPlaceType(widget.category),
                                      color: Theme.of(context).primaryColor,
                                      size: 28,
                                    ),
                                  ),
                                ),
                                
                                // POI Information
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        place.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        place.address ?? 'No address available',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          if (place.isOpen != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: place.isOpen!
                                                    ? Colors.green[50]
                                                    : Colors.red[50],
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(
                                                  color: place.isOpen!
                                                      ? Colors.green
                                                      : Colors.red,
                                                  width: 0.5,
                                                ),
                                              ),
                                              child: Text(
                                                place.isOpen! ? 'Open' : 'Closed',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: place.isOpen!
                                                      ? Colors.green[800]
                                                      : Colors.red[800],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          if (place.isOpen != null)
                                            const SizedBox(width: 8),
                                          if (place.rating != null)
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  size: 14,
                                                  color: Colors.amber,
                                                ),
                                                const SizedBox(width: 2),
                                                Text(
                                                  place.rating!.toStringAsFixed(1),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                if (place.userRatingCount != null)
                                                  Text(
                                                    ' (${place.userRatingCount})',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Action Buttons Column
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Info button
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                        setState(() {
                                          _selectedPlace = place;
                                          _isDrawerVisible = true;
                                        });
                                      },
                                      child: Container(
                                        width: 38,
                                        height: 38,
                                        margin: const EdgeInsets.only(bottom: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withAlpha(25),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.info_outline,
                                          color: Colors.blue,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                    
                                    // Directions button
                                    InkWell(
                                      onTap: () => _navigateToDirections(place),
                                      child: Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor.withAlpha(25),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.directions,
                                          color: Theme.of(context).primaryColor,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                          if (index < places.length - 1)
                            Divider(
                              color: Colors.grey[300],
                              height: 1,
                              thickness: 1,
                              indent: 70,
                              endIndent: 16,
                            ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Gets the icon for a specific PlaceType
  IconData _getIconForPlaceType(PlaceType type) {
    switch (type) {
      case PlaceType.foodDrink:
        return Icons.restaurant;
      case PlaceType.coffeeShop:
        return Icons.coffee;
      case PlaceType.healthCenter:
        return Icons.local_hospital;
      case PlaceType.studyPlace:
        return Icons.book;
      case PlaceType.gym:
        return Icons.fitness_center;
      case PlaceType.grocery:
        return Icons.shopping_cart;
      // ignore: unreachable_switch_default
      default:
        return Icons.place;
    }
  }
}