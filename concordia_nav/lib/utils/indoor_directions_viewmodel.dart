import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/domain-model/concordia_floor.dart';
import '../data/domain-model/concordia_room.dart';
import '../data/domain-model/concordia_building.dart';
import '../data/domain-model/concordia_campus.dart';
import 'map_viewmodel.dart';

class IndoorDirectionsViewModel extends MapViewModel {
  final ValueNotifier<Set<Marker>> markersNotifier = ValueNotifier({});
  final ValueNotifier<Set<Polyline>> polylinesNotifier = ValueNotifier({});
  ConcordiaRoom? selectedRoom;

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

  Future<CameraPosition> getInitialCameraPositionFloor(ConcordiaFloor floor) async {
    return CameraPosition(
      target: LatLng(floor.lat, floor.lng),
      zoom: 18.0,
    );
  }

  @override
  Future<void> fetchRoutesForAllModes(String originAddress, String destinationAddress) async {
    
  }

  void calculateDirections() {
    // directions logic

  }

  void updateMarkers() {
    // marker logic
  }
}