// ignore_for_file: avoid_catches_without_on_clauses, prefer_const_declarations

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/domain-model/concordia_floor.dart';
import '../data/domain-model/concordia_room.dart';
import '../data/domain-model/room_category.dart';
import '../data/domain-model/concordia_floor_point.dart';
import '../data/domain-model/concordia_building.dart';
import '../data/domain-model/concordia_campus.dart';
import 'map_viewmodel.dart';

import 'dart:developer' as dev;

class IndoorMapViewModel extends MapViewModel {
  final TransformationController transformationController;
  final AnimationController animationController;
  Animation<Matrix4>? _animation;

  IndoorMapViewModel({required TickerProvider vsync})
      : transformationController = TransformationController(),
        animationController = AnimationController(
            vsync: vsync, duration: const Duration(milliseconds: 300));

  final ValueNotifier<Set<Marker>> markersNotifier = ValueNotifier({});
  final ValueNotifier<Set<Polyline>> polylinesNotifier = ValueNotifier({});
  ConcordiaRoom? selectedRoom;

  final double _maxScale = 1.5;
  final double _minScale = 0.6;
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

  Future<CameraPosition> getInitialCameraPositionFloor(
      ConcordiaFloor floor) async {
    return CameraPosition(
      target: LatLng(floor.lat, floor.lng),
      zoom: 18.0,
    );
  }

  @override
  Future<void> fetchRoutesForAllModes(
      String originAddress, String destinationAddress) async {
    final floor = floors.firstWhere(
      (floor) =>
          floor.floorNumber == originAddress ||
          floor.floorNumber == destinationAddress,
      orElse: () => floors.first,
    );

    selectedRoom = ConcordiaRoom(
      destinationAddress,
      RoomCategory.classroom,
      floor,
      ConcordiaFloorPoint(
        floor,
        0.5,
        0.5,
      ),
    );

    updateMarkers();
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

  void updateMarkers() {
    if (selectedRoom != null && selectedRoom!.entrancePoint != null) {
      markersNotifier.value = {
        Marker(
          markerId: const MarkerId('selected_room'),
          position: LatLng(
            selectedRoom!.floor.lat +
                selectedRoom!.entrancePoint!.positionX * 0.0001,
            selectedRoom!.floor.lng +
                selectedRoom!.entrancePoint!.positionY * 0.0001,
          ),
          infoWindow: InfoWindow(title: selectedRoom!.roomNumber),
        ),
      };
    } else {
      markersNotifier.value = {};
    }
    notifyListeners();
  }

  /// Sets the initial camera transformation from a given scale and translation.
  void setInitialCameraPosition({
    double scale = 1.0,
    double offsetX = 0.0,
    double offsetY = 0.0,
  }) {
    final matrix = Matrix4.identity()
      ..scale(scale)
      ..translate(offsetX, offsetY);
    transformationController.value = matrix;
  }

  /// Animates the camera transformation to the provided target matrix.
  void animateTo(Matrix4 targetMatrix) {
    _animation = Matrix4Tween(
      begin: transformationController.value,
      end: targetMatrix,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
        transformationController.value = _animation!.value;
      });
    animationController.forward(from: 0);
  }

  /// Pans the view to a new region by calculating a target transformation.
  void panToRegion({
    required double offsetX,
    required double offsetY,
  }) {
    // When moving the camera, preserving the current zoom scale is required:
    final double currentScale =
        transformationController.value.getMaxScaleOnAxis();
    final targetMatrix = Matrix4.identity()
      ..scale(currentScale)
      ..translate(offsetX, offsetY);
    animateTo(targetMatrix);
  }

  /// Centers the camera view between start and end points with appropriate zoom
  void centerBetweenPoints(
      Offset startLocation, Offset endLocation, Size viewportSize,
      {double padding = 100.0}) {
    final double width = viewportSize.width;
    final double height = viewportSize.height;

    if (startLocation == Offset.zero || endLocation == Offset.zero) {
      return; // Don't proceed if points aren't set
    }

    // Calculate the center point between start and end
    final centerX = (startLocation.dx + endLocation.dx) / 2;
    final centerY = (startLocation.dy + endLocation.dy) / 2;

    // Calculate viewport dimensions (assuming we have access to MediaQuery info)
    final viewportWidth = width / 2;
    final viewportHeight = height / 2;

    // Calculate scale needed to fit the route with padding
    // For horizontal distance
    final horizontalDistance =
        (endLocation.dx - startLocation.dx).abs() + padding * 2;
    final horizontalScale = viewportWidth / horizontalDistance;

    // For vertical distance
    final verticalDistance =
        (endLocation.dy - startLocation.dy).abs() + padding * 2;
    final verticalScale = viewportHeight / verticalDistance;

    // Use the smaller scale to ensure both points are visible
    final scale =
        horizontalScale < verticalScale ? horizontalScale : verticalScale;

    // Clamp scale between min and max allowable values
    final clampedScale = scale.clamp(_minScale, _maxScale);

    // Calculate the offset to center the route
    final offsetX = -centerX + viewportWidth / (2.3 * clampedScale);
    final offsetY = -centerY + viewportHeight / (2.3 * clampedScale);

    dev.log(
        'Centering between points: offsetX=$offsetX, offsetY=$offsetY, clampedScale=$clampedScale');

    // Create the transformation matrix
    final matrix = Matrix4.identity()
      ..translate(offsetX, offsetY)
      ..scale(clampedScale);

    // Animate to the new position and zoom
    animateTo(matrix);
  }

  Future<bool> doesAssetExist(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    transformationController.dispose();
    super.dispose();
  }
}
