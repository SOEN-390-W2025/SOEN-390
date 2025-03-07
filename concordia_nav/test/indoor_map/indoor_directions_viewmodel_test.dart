import 'package:concordia_nav/data/domain-model/concordia_floor_point.dart';
import 'package:concordia_nav/utils/indoor_directions_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  late IndoorDirectionsViewModel indoorDirectionsViewModel;

  setUp(() {
    indoorDirectionsViewModel = IndoorDirectionsViewModel();
  });

  test('Getter for isAccessibilityMode', () {
    expect(indoorDirectionsViewModel.isAccessibilityMode, false);
  });

  test('Toggling accessibility mode updates value', () {
    indoorDirectionsViewModel.toggleAccessibilityMode(true);
    expect(indoorDirectionsViewModel.isAccessibilityMode, true);
  });

  test('getPositionPoint should return a valid point for a known room',
      () async {
    final point = await indoorDirectionsViewModel.getPositionPoint(
        'Hall Building', '8', '827');
    expect(point, isA<ConcordiaFloorPoint>());
  });

  test('getPositionPoint should handle leading zeros in room number', () async {
    final point = await indoorDirectionsViewModel.getPositionPoint(
        'John Molson School of Business', 'S2', '0001');
    expect(point, isA<ConcordiaFloorPoint>());
  });
}
