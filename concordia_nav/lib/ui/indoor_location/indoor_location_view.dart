import 'package:flutter/material.dart';
import '../../data/domain-model/concordia_floor.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../data/domain-model/concordia_room.dart';
import '../../data/domain-model/concordia_campus.dart';
import '../../data/domain-model/room_category.dart';
import '../../utils/indoor_map_viewmodel.dart';
import '../../widgets/floor_plan_search_widget.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/zoom_buttons.dart';
import 'indoor_directions_view.dart';


class IndoorLocationView extends StatefulWidget {
  final String? building;
  final String? floor;
  final String? room;

  const IndoorLocationView({super.key, this.building, this.floor, this.room});

  @override
  State<IndoorLocationView> createState() => _IndoorLocationViewState();
}

class _IndoorLocationViewState extends State<IndoorLocationView> {
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

  // Hardcoding a default selected room for testing
  // Will be change when backend is implemented
  _indoorMapViewModel.selectedRoom = ConcordiaRoom(
    'H-120',
    RoomCategory.classroom,
    _currentFloor!,
    null,
  );

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
      orElse: () => getDefaultFloor(),
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
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IndoorDirectionsView(
                        currentLocation: 'Your Location',
                        destination: _indoorMapViewModel.selectedRoom!.roomNumber,
                      ),
                    ),
                  );
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
        'Indoor Map',
      ),
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/maps/indoor/Hall-1.png',
              fit: BoxFit.contain,
            ),
          ),
          _buildTopPanel(),
          _buildFooter(),

          Positioned(
            top: 80,
            right: 16,
            child: Column(
              children: [
                ZoomButton(
                  onTap: () {
                    // Handle zoom in
                  },
                  icon: Icons.add,
                  isZoomInButton: true,
                ),
                ZoomButton(
                  onTap: () {
                    // Handle zoom out
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
