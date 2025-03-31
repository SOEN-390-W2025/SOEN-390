// ignore_for_file: avoid_catches_without_on_clauses, prefer_const_declarations

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/domain-model/concordia_room.dart';
import 'map_viewmodel.dart';

import 'dart:developer' as dev;

class IndoorMapViewModel extends MapViewModel {
  final TransformationController transformationController;
  final AnimationController animationController;
  Animation<Matrix4>? _animation;
  bool _disposed = false;

  IndoorMapViewModel({required TickerProvider vsync})
      : transformationController = TransformationController(),
        animationController = AnimationController(
            vsync: vsync, duration: const Duration(milliseconds: 300));

  final ValueNotifier<Set<Marker>> markersNotifier = ValueNotifier({});
  final ValueNotifier<Set<Polyline>> polylinesNotifier = ValueNotifier({});
  ConcordiaRoom? selectedRoom;

  final double _maxScale = 1.5;
  final double _minScale = 0.6;

  /// Sets the initial camera transformation from a given scale and translation.
  void setInitialCameraPosition({
    double scale = 1.0,
    double offsetX = 0.0,
    double offsetY = 0.0,
    Size? viewportSize,
    double? contentWidth,
    double? contentHeight,
  }) {
    // If we have all necessary parameters
    if (viewportSize != null && contentWidth != null && contentHeight != null) {

      // Use the smaller scale to ensure everything fits
      final fitScale = _minScale + 0.05;

      // Clamp scale between min and max values
      final clampedScale = fitScale.clamp(_minScale, _maxScale);

      // Center the content in the viewport
      final centeredOffsetX = (viewportSize.width - (contentWidth * clampedScale)) / 2;
      final centeredOffsetY = (viewportSize.height - (contentHeight * clampedScale)) / 10;

      // Apply the transformation
      final matrix = Matrix4.identity()
        ..translate(centeredOffsetX, centeredOffsetY)
        ..scale(clampedScale);

      transformationController.value = matrix;

      dev.log('Set initial camera position with max zoom out: scale=$clampedScale, offsetX=$centeredOffsetX, offsetY=$centeredOffsetY');
    } else {
      // Original behavior
      final matrix = Matrix4.identity()
        ..translate(offsetX, offsetY)
        ..scale(scale);

      transformationController.value = matrix;
    }
  }

  /// Animates the camera transformation to the provided target matrix.
  void animateTo(Matrix4 targetMatrix) {
    if (_disposed) return;
    _animation = Matrix4Tween(
      begin: transformationController.value,
      end: targetMatrix,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
        if (!_disposed) {
          transformationController.value = _animation!.value;
        }
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

  /// Centers the camera view on a specific point
  void centerOnPoint(Offset point, Size viewportSize, {double padding = 50.0}) {
    final double viewportWidth = viewportSize.width;
    final double viewportHeight = viewportSize.height;

    // Calculate scale and offset to center the point
    final scale = transformationController.value
        .getMaxScaleOnAxis(); // Use the current scale
    final offsetX = -point.dx + viewportWidth / (2.3 * scale);
    final offsetY = -point.dy + viewportHeight / (2.3 * scale);

    dev.log(
        'Centering on point: offsetX=$offsetX, offsetY=$offsetY, scale=$scale');

    // Create the transformation matrix
    final matrix = Matrix4.identity()
      ..translate(offsetX, offsetY)
      ..scale(scale);

    // Animate to the new position and zoom
    animateTo(matrix);
  }

  /// Centers the camera view between start and end points with appropriate zoom
  void centerBetweenPoints(
      Offset startLocation, Offset endLocation, Size viewportSize,
      {double padding = 100.0}) {
    final double viewportWidth = viewportSize.width;
    final double viewportHeight = viewportSize.height;

    if (startLocation == Offset.zero || endLocation == Offset.zero) {
      return; // Don't proceed if points aren't set
    }

    // Calculate the center point between start and end
    final centerX = (startLocation.dx + endLocation.dx) / 2;
    final centerY = (startLocation.dy + endLocation.dy) / 2;
    final centerPoint = Offset(centerX, centerY);
    
    dev.log('Center point: $centerPoint');

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

    // Calculate the offset to center the points
    final offsetX = -(centerX - viewportWidth / (2 * clampedScale));
    final offsetY = -(centerY - viewportHeight / (2 * clampedScale));

    dev.log('Centering between points: startLocation=$startLocation, endLocation=$endLocation');
    dev.log('Scale calculations: horizontalScale=$horizontalScale, verticalScale=$verticalScale');
    dev.log('Final values: offsetX=$offsetX, offsetY=$offsetY, clampedScale=$clampedScale');

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

  String extractFloor(String roomName) {
    if (roomName.trim().toLowerCase() == 'main entrance') return '1';

    if (roomName == 'Your Location') return '1';

    // Remove any building prefix if present (like "H " or "MB ")
    final cleanedRoom = roomName.replaceAll(RegExp(r'^[a-zA-Z]{1,2} '), '');

    // If the first character is alphabetic, get first two characters
    if (cleanedRoom.isNotEmpty && RegExp(r'^[a-zA-Z]').hasMatch(cleanedRoom)) {
      // For alphanumeric floors, take the first two characters
      return cleanedRoom.length >= 2
          ? cleanedRoom.substring(0, 2)
          : cleanedRoom;
    }
    // Otherwise if it starts with a digit, just get the first digit
    else if (cleanedRoom.isNotEmpty &&
        RegExp(r'^[0-9]').hasMatch(cleanedRoom)) {
      return cleanedRoom.substring(0, 1);
    }

    // Fallback
    return '1';
  }

  @override
  void dispose() {
    _disposed = true;
    animationController.stop();
    animationController.dispose();
    transformationController.dispose();
    super.dispose();
  }
}
