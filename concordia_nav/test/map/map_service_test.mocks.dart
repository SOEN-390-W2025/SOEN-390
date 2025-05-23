// Mocks generated by Mockito 5.4.5 from annotations
// in concordia_nav/test/map/map_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;
import 'dart:typed_data' as _i6;

import 'package:concordia_nav/data/domain-model/concordia_campus.dart' as _i9;
import 'package:concordia_nav/data/services/map_service.dart' as _i7;
import 'package:concordia_nav/data/services/outdoor_directions_service.dart'
    as _i8;
import 'package:geolocator/geolocator.dart' as _i3;
import 'package:google_maps_flutter/google_maps_flutter.dart' as _i4;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart'
    as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeLatLngBounds_0 extends _i1.SmartFake implements _i2.LatLngBounds {
  _FakeLatLngBounds_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeScreenCoordinate_1 extends _i1.SmartFake
    implements _i2.ScreenCoordinate {
  _FakeScreenCoordinate_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeLatLng_2 extends _i1.SmartFake implements _i2.LatLng {
  _FakeLatLng_2(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeCameraPosition_3 extends _i1.SmartFake
    implements _i2.CameraPosition {
  _FakeCameraPosition_3(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeBitmapDescriptor_4 extends _i1.SmartFake
    implements _i2.BitmapDescriptor {
  _FakeBitmapDescriptor_4(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakePosition_5 extends _i1.SmartFake implements _i3.Position {
  _FakePosition_5(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [GoogleMapController].
///
/// See the documentation for Mockito's code generation for more information.
class MockGoogleMapController extends _i1.Mock
    implements _i4.GoogleMapController {
  MockGoogleMapController() {
    _i1.throwOnMissingStub(this);
  }

  @override
  int get mapId =>
      (super.noSuchMethod(Invocation.getter(#mapId), returnValue: 0) as int);

  @override
  _i5.Future<void> clearTileCache(_i2.TileOverlayId? tileOverlayId) =>
      (super.noSuchMethod(
            Invocation.method(#clearTileCache, [tileOverlayId]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> animateCamera(_i2.CameraUpdate? cameraUpdate) =>
      (super.noSuchMethod(
            Invocation.method(#animateCamera, [cameraUpdate]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> moveCamera(_i2.CameraUpdate? cameraUpdate) =>
      (super.noSuchMethod(
            Invocation.method(#moveCamera, [cameraUpdate]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> setMapStyle(String? mapStyle) =>
      (super.noSuchMethod(
            Invocation.method(#setMapStyle, [mapStyle]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<String?> getStyleError() =>
      (super.noSuchMethod(
            Invocation.method(#getStyleError, []),
            returnValue: _i5.Future<String?>.value(),
          )
          as _i5.Future<String?>);

  @override
  _i5.Future<_i2.LatLngBounds> getVisibleRegion() =>
      (super.noSuchMethod(
            Invocation.method(#getVisibleRegion, []),
            returnValue: _i5.Future<_i2.LatLngBounds>.value(
              _FakeLatLngBounds_0(
                this,
                Invocation.method(#getVisibleRegion, []),
              ),
            ),
          )
          as _i5.Future<_i2.LatLngBounds>);

  @override
  _i5.Future<_i2.ScreenCoordinate> getScreenCoordinate(_i2.LatLng? latLng) =>
      (super.noSuchMethod(
            Invocation.method(#getScreenCoordinate, [latLng]),
            returnValue: _i5.Future<_i2.ScreenCoordinate>.value(
              _FakeScreenCoordinate_1(
                this,
                Invocation.method(#getScreenCoordinate, [latLng]),
              ),
            ),
          )
          as _i5.Future<_i2.ScreenCoordinate>);

  @override
  _i5.Future<_i2.LatLng> getLatLng(_i2.ScreenCoordinate? screenCoordinate) =>
      (super.noSuchMethod(
            Invocation.method(#getLatLng, [screenCoordinate]),
            returnValue: _i5.Future<_i2.LatLng>.value(
              _FakeLatLng_2(
                this,
                Invocation.method(#getLatLng, [screenCoordinate]),
              ),
            ),
          )
          as _i5.Future<_i2.LatLng>);

  @override
  _i5.Future<void> showMarkerInfoWindow(_i2.MarkerId? markerId) =>
      (super.noSuchMethod(
            Invocation.method(#showMarkerInfoWindow, [markerId]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> hideMarkerInfoWindow(_i2.MarkerId? markerId) =>
      (super.noSuchMethod(
            Invocation.method(#hideMarkerInfoWindow, [markerId]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<bool> isMarkerInfoWindowShown(_i2.MarkerId? markerId) =>
      (super.noSuchMethod(
            Invocation.method(#isMarkerInfoWindowShown, [markerId]),
            returnValue: _i5.Future<bool>.value(false),
          )
          as _i5.Future<bool>);

  @override
  _i5.Future<double> getZoomLevel() =>
      (super.noSuchMethod(
            Invocation.method(#getZoomLevel, []),
            returnValue: _i5.Future<double>.value(0.0),
          )
          as _i5.Future<double>);

  @override
  _i5.Future<_i6.Uint8List?> takeSnapshot() =>
      (super.noSuchMethod(
            Invocation.method(#takeSnapshot, []),
            returnValue: _i5.Future<_i6.Uint8List?>.value(),
          )
          as _i5.Future<_i6.Uint8List?>);

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );
}

/// A class which mocks [MapService].
///
/// See the documentation for Mockito's code generation for more information.
class MockMapService extends _i1.Mock implements _i7.MapService {
  MockMapService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void setMapController(_i4.GoogleMapController? controller) =>
      super.noSuchMethod(
        Invocation.method(#setMapController, [controller]),
        returnValueForMissingStub: null,
      );

  @override
  void setDirectionsService(_i8.ODSDirectionsService? directionsService) =>
      super.noSuchMethod(
        Invocation.method(#setDirectionsService, [directionsService]),
        returnValueForMissingStub: null,
      );

  @override
  _i2.CameraPosition getInitialCameraPosition(_i9.ConcordiaCampus? campus) =>
      (super.noSuchMethod(
            Invocation.method(#getInitialCameraPosition, [campus]),
            returnValue: _FakeCameraPosition_3(
              this,
              Invocation.method(#getInitialCameraPosition, [campus]),
            ),
          )
          as _i2.CameraPosition);

  @override
  void moveCamera(_i2.LatLng? position, {double? zoom = 17.0}) =>
      super.noSuchMethod(
        Invocation.method(#moveCamera, [position], {#zoom: zoom}),
        returnValueForMissingStub: null,
      );

  @override
  void adjustCameraForPath(List<_i2.LatLng>? points) => super.noSuchMethod(
    Invocation.method(#adjustCameraForPath, [points]),
    returnValueForMissingStub: null,
  );

  @override
  _i5.Future<_i2.BitmapDescriptor> getCustomIcon(String? name) =>
      (super.noSuchMethod(
            Invocation.method(#getCustomIcon, [name]),
            returnValue: _i5.Future<_i2.BitmapDescriptor>.value(
              _FakeBitmapDescriptor_4(
                this,
                Invocation.method(#getCustomIcon, [name]),
              ),
            ),
          )
          as _i5.Future<_i2.BitmapDescriptor>);

  @override
  _i5.Future<bool> isLocationServiceEnabled() =>
      (super.noSuchMethod(
            Invocation.method(#isLocationServiceEnabled, []),
            returnValue: _i5.Future<bool>.value(false),
          )
          as _i5.Future<bool>);

  @override
  _i5.Future<bool> checkAndRequestLocationPermission() =>
      (super.noSuchMethod(
            Invocation.method(#checkAndRequestLocationPermission, []),
            returnValue: _i5.Future<bool>.value(false),
          )
          as _i5.Future<bool>);

  @override
  _i5.Future<_i2.LatLng?> getCurrentLocation() =>
      (super.noSuchMethod(
            Invocation.method(#getCurrentLocation, []),
            returnValue: _i5.Future<_i2.LatLng?>.value(),
          )
          as _i5.Future<_i2.LatLng?>);

  @override
  double calculateDistance(_i2.LatLng? point1, _i2.LatLng? point2) =>
      (super.noSuchMethod(
            Invocation.method(#calculateDistance, [point1, point2]),
            returnValue: 0.0,
          )
          as double);

  @override
  _i5.Future<List<_i2.LatLng>> getRoutePath(
    String? originAddress,
    String? destinationAddress,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#getRoutePath, [
              originAddress,
              destinationAddress,
            ]),
            returnValue: _i5.Future<List<_i2.LatLng>>.value(<_i2.LatLng>[]),
          )
          as _i5.Future<List<_i2.LatLng>>);
}

/// A class which mocks [GeolocatorPlatform].
///
/// See the documentation for Mockito's code generation for more information.
class MockGeolocatorPlatform extends _i1.Mock
    implements _i3.GeolocatorPlatform {
  MockGeolocatorPlatform() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<_i3.LocationPermission> checkPermission() =>
      (super.noSuchMethod(
            Invocation.method(#checkPermission, []),
            returnValue: _i5.Future<_i3.LocationPermission>.value(
              _i3.LocationPermission.denied,
            ),
          )
          as _i5.Future<_i3.LocationPermission>);

  @override
  _i5.Future<_i3.LocationPermission> requestPermission() =>
      (super.noSuchMethod(
            Invocation.method(#requestPermission, []),
            returnValue: _i5.Future<_i3.LocationPermission>.value(
              _i3.LocationPermission.denied,
            ),
          )
          as _i5.Future<_i3.LocationPermission>);

  @override
  _i5.Future<bool> isLocationServiceEnabled() =>
      (super.noSuchMethod(
            Invocation.method(#isLocationServiceEnabled, []),
            returnValue: _i5.Future<bool>.value(false),
          )
          as _i5.Future<bool>);

  @override
  _i5.Future<_i3.Position?> getLastKnownPosition({
    bool? forceLocationManager = false,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#getLastKnownPosition, [], {
              #forceLocationManager: forceLocationManager,
            }),
            returnValue: _i5.Future<_i3.Position?>.value(),
          )
          as _i5.Future<_i3.Position?>);

  @override
  _i5.Future<_i3.Position> getCurrentPosition({
    _i3.LocationSettings? locationSettings,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#getCurrentPosition, [], {
              #locationSettings: locationSettings,
            }),
            returnValue: _i5.Future<_i3.Position>.value(
              _FakePosition_5(
                this,
                Invocation.method(#getCurrentPosition, [], {
                  #locationSettings: locationSettings,
                }),
              ),
            ),
          )
          as _i5.Future<_i3.Position>);

  @override
  _i5.Stream<_i3.ServiceStatus> getServiceStatusStream() =>
      (super.noSuchMethod(
            Invocation.method(#getServiceStatusStream, []),
            returnValue: _i5.Stream<_i3.ServiceStatus>.empty(),
          )
          as _i5.Stream<_i3.ServiceStatus>);

  @override
  _i5.Stream<_i3.Position> getPositionStream({
    _i3.LocationSettings? locationSettings,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#getPositionStream, [], {
              #locationSettings: locationSettings,
            }),
            returnValue: _i5.Stream<_i3.Position>.empty(),
          )
          as _i5.Stream<_i3.Position>);

  @override
  _i5.Future<_i3.LocationAccuracyStatus> requestTemporaryFullAccuracy({
    required String? purposeKey,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#requestTemporaryFullAccuracy, [], {
              #purposeKey: purposeKey,
            }),
            returnValue: _i5.Future<_i3.LocationAccuracyStatus>.value(
              _i3.LocationAccuracyStatus.reduced,
            ),
          )
          as _i5.Future<_i3.LocationAccuracyStatus>);

  @override
  _i5.Future<_i3.LocationAccuracyStatus> getLocationAccuracy() =>
      (super.noSuchMethod(
            Invocation.method(#getLocationAccuracy, []),
            returnValue: _i5.Future<_i3.LocationAccuracyStatus>.value(
              _i3.LocationAccuracyStatus.reduced,
            ),
          )
          as _i5.Future<_i3.LocationAccuracyStatus>);

  @override
  _i5.Future<bool> openAppSettings() =>
      (super.noSuchMethod(
            Invocation.method(#openAppSettings, []),
            returnValue: _i5.Future<bool>.value(false),
          )
          as _i5.Future<bool>);

  @override
  _i5.Future<bool> openLocationSettings() =>
      (super.noSuchMethod(
            Invocation.method(#openLocationSettings, []),
            returnValue: _i5.Future<bool>.value(false),
          )
          as _i5.Future<bool>);

  @override
  double distanceBetween(
    double? startLatitude,
    double? startLongitude,
    double? endLatitude,
    double? endLongitude,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#distanceBetween, [
              startLatitude,
              startLongitude,
              endLatitude,
              endLongitude,
            ]),
            returnValue: 0.0,
          )
          as double);

  @override
  double bearingBetween(
    double? startLatitude,
    double? startLongitude,
    double? endLatitude,
    double? endLongitude,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#bearingBetween, [
              startLatitude,
              startLongitude,
              endLatitude,
              endLongitude,
            ]),
            returnValue: 0.0,
          )
          as double);
}
