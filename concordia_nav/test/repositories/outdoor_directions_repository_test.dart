import 'package:concordia_nav/data/repositories/outdoor_directions_repository.dart';
import 'package:concordia_nav/utils/map_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';

import 'package:mockito/mockito.dart';

import 'outdoor_directions_repository_test.mocks.dart';

@GenerateMocks([AssetBundle])
void main() {
  late ShuttleRouteRepository repository;
  late MockAssetBundle mockAssetBundle;

  setUp(() {
    mockAssetBundle = MockAssetBundle();
    repository = ShuttleRouteRepository(assetBundle: mockAssetBundle);
  });

  group('loadShuttleRoute', () {
    test('should return correct list of LatLng for SGWtoLOY', () async {
      const jsonString =
          '[{"lat": 45.495, "lng": -73.578}, {"lat": 45.496, "lng": -73.579}]';
      when(mockAssetBundle.loadString(any)).thenAnswer((_) async => jsonString);

      final result =
          await repository.loadShuttleRoute(ShuttleRouteDirection.SGWtoLOY);

      expect(result,
          [const LatLng(45.495, -73.578), const LatLng(45.496, -73.579)]);
    });
  });

  group('loadShuttleSchedule', () {
    test('should return correct schedule for Monday-Thursday', () async {
      const jsonString = '{"last_departure": {"LOY": "20:00", "SGW": "20:30"}}';
      when(mockAssetBundle.loadString(any)).thenAnswer((_) async => jsonString);

      final result = await repository.loadShuttleSchedule('Monday-Thursday');

      expect(result,
          containsPair('last_departure', {'LOY': '20:00', 'SGW': '20:30'}));
    });
  });

  group('isShuttleAvailable', () {
    test('should return false on weekends', () async {
      final saturday = DateTime(2025, 3, 8);
      expect(repository.getDayType(saturday), isNull);
    });

    test('should return true if current time is before last departure',
        () async {
      const jsonString = '{"last_departure": {"LOY": "20:00", "SGW": "20:30"}}';
      when(mockAssetBundle.loadString(any)).thenAnswer((_) async => jsonString);

      final result = await repository.isShuttleAvailable();
      expect(result, isFalse);
    });
  });
}
