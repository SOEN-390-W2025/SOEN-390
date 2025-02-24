import 'package:concordia_nav/data/repositories/outdoor_directions_repository.dart';
import 'package:concordia_nav/utils/map_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('outdoor repository tests', () {

    test('loadShuttleRoute', () async {
      var route = await ShuttleRouteRepository().loadShuttleRoute(ShuttleRouteDirection.SGWtoLOY);

      // verify returned route from SGW to LOY
      expect(route, isA<List<LatLng>>());
      expect(route.first, const LatLng(45.49708, -73.5784));

      route = await ShuttleRouteRepository().loadShuttleRoute(ShuttleRouteDirection.LOYtoSGW);

      // verify returned route from LOY to SGW
      expect(route, isA<List<LatLng>>());
      expect(route.first, const LatLng(45.45798, -73.63867));
    });

    test('loadShuttleSchedule returns schedule', () async {
      var schedule = await ShuttleRouteRepository().loadShuttleSchedule('Monday-Thursday');

      // verify receive schedule from Monday-Thursday
      expect(schedule, isA<Map<String, dynamic>>());
      expect(schedule["LOY_departures"][0], "9:15");

      schedule = await ShuttleRouteRepository().loadShuttleSchedule('Friday');

      // verify receive schedule from Monday-Thursday
      expect(schedule, isA<Map<String, dynamic>>());
      expect(schedule["LOY_departures"][0], "9:15");
    });

    test('loadShuttleSchedule throws exception if invalid dayType given', () async {
      // verify it throws an exception
      expect(ShuttleRouteRepository().loadShuttleSchedule('Sunday'), throwsException);
    });

    test('getDayType returns dayType or null if weekend', () {
      var dayType = ShuttleRouteRepository().getDayType(DateTime(2025, 2, 24)); // Monday
      expect(dayType, 'Monday-Thursday');

      dayType = ShuttleRouteRepository().getDayType(DateTime(2025, 2, 28)); // Friday
      expect(dayType, 'Friday');

      dayType = ShuttleRouteRepository().getDayType(DateTime(2025, 2, 23)); // Sunday
      expect(dayType, null);
    });
  });
}