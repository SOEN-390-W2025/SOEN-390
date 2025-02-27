import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/domain-model/concordia_floor.dart';
import '../data/domain-model/concordia_room.dart';
import '../data/domain-model/room_category.dart';
import '../data/domain-model/concordia_floor_point.dart';
import '../data/domain-model/concordia_building.dart';
import '../data/domain-model/concordia_campus.dart';
import 'map_viewmodel.dart';

class IndoorMapViewModel extends MapViewModel {
  final ValueNotifier<Set<Marker>> markersNotifier = ValueNotifier({});
  final ValueNotifier<Set<Polyline>> polylinesNotifier = ValueNotifier({});
  ConcordiaRoom? selectedRoom;
  GoogleMapController? _mapController;

  //hard code floors for mock
  final List<ConcordiaFloor> floors = [
    ConcordiaFloor(
      '1',
      const ConcordiaBuilding(
        45.4972159,
        -73.5790067,
        'Hall Building',
        '1455 Boulevard de Maisonneuve O',
        'Montreal',
        'QC',
        'H3G 1M8',
        'H',
        ConcordiaCampus.sgw,
      ),
    ),
    ConcordiaFloor(
      '2',
      const ConcordiaBuilding(
        45.4972159,
        -73.5790067,
        'Hall Building',
        '1455 Boulevard de Maisonneuve O',
        'Montreal',
        'QC',
        'H3G 1M8',
        'H',
        ConcordiaCampus.sgw,
      ),
    ),
  ];
  @override
  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }
  Future<CameraPosition> getInitialCameraPositionFloor(ConcordiaFloor floor) async {
    return CameraPosition(
      target: LatLng(floor.lat, floor.lng),
      zoom: 18.0,
    );
  }
  @override
  @override
Future<void> fetchRoutesForAllModes(String start, String end) async {
  final floor = floors.firstWhere(
    (floor) => floor.floorNumber == start || floor.floorNumber == end,
    orElse: () => floors.first,
  );

  selectedRoom = ConcordiaRoom(
    end,
    RoomCategory.classroom,
    floor,
    ConcordiaFloorPoint(
      floor,
      0.5,
      0.5,
    ),
  );

  _updateMarkers();
  notifyListeners();
}

  void calculateDirections() {
    // Mock directions logic
    if (selectedRoom == null || selectedRoom!.entrancePoint == null) return;

    final polyline = Polyline(
      polylineId: const PolylineId('indoor_path'),
      points: [
        LatLng(selectedRoom!.floor.lat, selectedRoom!.floor.lng),
        LatLng(
          selectedRoom!.floor.lat + 0.0001,
          selectedRoom!.floor.lng + 0.0001,
        ),
      ],
      color: Colors.blue,
      width: 5,
    );
    polylinesNotifier.value = {polyline};
    notifyListeners();
  }

  void _updateMarkers() {
    if (selectedRoom != null && selectedRoom!.entrancePoint != null) {
      markersNotifier.value = {
        Marker(
          markerId: const MarkerId('selected_room'),
          position: LatLng(
            selectedRoom!.floor.lat + selectedRoom!.entrancePoint!.positionX * 0.0001,
            selectedRoom!.floor.lng + selectedRoom!.entrancePoint!.positionY * 0.0001,
          ),
          infoWindow: InfoWindow(title: selectedRoom!.roomNumber),
        ),
      };
    } else {
      markersNotifier.value = {};
    }
    notifyListeners();
  }
}