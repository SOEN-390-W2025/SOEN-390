import 'package:flutter/material.dart';
import '../../data/domain-model/concordia_floor.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../data/domain-model/concordia_campus.dart';
import '../../utils/indoor_map_viewmodel.dart';
import '../../widgets/floor_plan_search_widget.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/zoom_buttons.dart'; // Import the ZoomButton widget

class IndoorMapView extends StatefulWidget {
  const IndoorMapView({super.key});

  @override
  State<IndoorMapView> createState() => _IndoorMapViewState();
}

class _IndoorMapViewState extends State<IndoorMapView> {
  late IndoorMapViewModel _indoorMapViewModel;
  late TextEditingController _originController;
  late TextEditingController _destinationController;
  ConcordiaFloor? _currentFloor;

  final List<String> _searchList = [];

  ConcordiaFloor getDefaultFloor() {
    const defaultBuilding = ConcordiaBuilding(
      45.4972159,
      -73.5790067,
      'Hall Building',
      '1455 Boulevard de Maisonneuve O',
      'Montreal',
      'QC',
      'H3G 1M8',
      'H',
      ConcordiaCampus.sgw,
    );

    return ConcordiaFloor(
      '1',
      defaultBuilding,
    );
  }

  @override
  void initState() {
    super.initState();
    _indoorMapViewModel = IndoorMapViewModel();
    _originController = TextEditingController();
    _destinationController = TextEditingController();
    _currentFloor = getDefaultFloor();

    // Generate search list from floors
    _searchList.addAll(_indoorMapViewModel.floors.map((floor) => floor.floorNumber).toList());
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  ConcordiaFloor _getFloorByName(String floorName) {
    return _indoorMapViewModel.floors.firstWhere(
      (floor) => floor.floorNumber == floorName,
      orElse: () => getDefaultFloor(), // Fallback to default floor
    );
  }

  Widget _buildTopPanel() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloorPlanSearchWidget(
              searchController: _destinationController,
              searchList: _searchList,
              onFloorSelected: (selectedFloor) {
                setState(() {
                  _currentFloor = _getFloorByName(selectedFloor);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
  return Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Shadow color
            blurRadius: 8, // Spread of the shadow
            offset: const Offset(0, -2), // Shadow position (top of the footer)
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _indoorMapViewModel.selectedRoom?.roomNumber ?? 'Select a room',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_indoorMapViewModel.selectedRoom != null) {
                _indoorMapViewModel.calculateDirections();
                setState(() {});
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(146, 35, 56, 1),
            ),
            child: const Text(
              'Directions',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        'Indoor Map - ${_currentFloor?.floorNumber ?? 'Default Floor'}',
      ),
      body: Stack(
        children: [
          Center(
            // Mock image for hall floor plans
            child: Image.asset(
              'assets/maps/indoor/Hall-1.png',
              fit: BoxFit.contain,
            ),
          ),
          _buildTopPanel(),
          _buildFooter(),

          //zoom not implemented for now since map is mocked
          Positioned(
            top: 80,
            right: 16,
            child: Column(
              children: [
                ZoomButton(
                  onTap: () {
                  },
                  icon: Icons.add,
                  isZoomInButton: true,
                ),
                ZoomButton(
                  onTap: () {
                  },
                  icon: Icons.remove,
                  isZoomInButton: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}