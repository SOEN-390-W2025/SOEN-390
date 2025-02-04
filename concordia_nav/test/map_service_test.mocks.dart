// Mocks generated by Mockito 5.4.5 from annotations
// in concordia_nav/test/map_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;
import 'dart:typed_data' as _i5;

import 'package:google_maps_flutter/google_maps_flutter.dart' as _i3;
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

/// A class which mocks [GoogleMapController].
///
/// See the documentation for Mockito's code generation for more information.
class MockGoogleMapController extends _i1.Mock
    implements _i3.GoogleMapController {
  MockGoogleMapController() {
    _i1.throwOnMissingStub(this);
  }

  @override
  int get mapId =>
      (super.noSuchMethod(Invocation.getter(#mapId), returnValue: 0) as int);

  @override
  _i4.Future<void> clearTileCache(_i2.TileOverlayId? tileOverlayId) =>
      (super.noSuchMethod(
            Invocation.method(#clearTileCache, [tileOverlayId]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> animateCamera(_i2.CameraUpdate? cameraUpdate) =>
      (super.noSuchMethod(
            Invocation.method(#animateCamera, [cameraUpdate]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> moveCamera(_i2.CameraUpdate? cameraUpdate) =>
      (super.noSuchMethod(
            Invocation.method(#moveCamera, [cameraUpdate]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> setMapStyle(String? mapStyle) =>
      (super.noSuchMethod(
            Invocation.method(#setMapStyle, [mapStyle]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<String?> getStyleError() =>
      (super.noSuchMethod(
            Invocation.method(#getStyleError, []),
            returnValue: _i4.Future<String?>.value(),
          )
          as _i4.Future<String?>);

  @override
  _i4.Future<_i2.LatLngBounds> getVisibleRegion() =>
      (super.noSuchMethod(
            Invocation.method(#getVisibleRegion, []),
            returnValue: _i4.Future<_i2.LatLngBounds>.value(
              _FakeLatLngBounds_0(
                this,
                Invocation.method(#getVisibleRegion, []),
              ),
            ),
          )
          as _i4.Future<_i2.LatLngBounds>);

  @override
  _i4.Future<_i2.ScreenCoordinate> getScreenCoordinate(_i2.LatLng? latLng) =>
      (super.noSuchMethod(
            Invocation.method(#getScreenCoordinate, [latLng]),
            returnValue: _i4.Future<_i2.ScreenCoordinate>.value(
              _FakeScreenCoordinate_1(
                this,
                Invocation.method(#getScreenCoordinate, [latLng]),
              ),
            ),
          )
          as _i4.Future<_i2.ScreenCoordinate>);

  @override
  _i4.Future<_i2.LatLng> getLatLng(_i2.ScreenCoordinate? screenCoordinate) =>
      (super.noSuchMethod(
            Invocation.method(#getLatLng, [screenCoordinate]),
            returnValue: _i4.Future<_i2.LatLng>.value(
              _FakeLatLng_2(
                this,
                Invocation.method(#getLatLng, [screenCoordinate]),
              ),
            ),
          )
          as _i4.Future<_i2.LatLng>);

  @override
  _i4.Future<void> showMarkerInfoWindow(_i2.MarkerId? markerId) =>
      (super.noSuchMethod(
            Invocation.method(#showMarkerInfoWindow, [markerId]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> hideMarkerInfoWindow(_i2.MarkerId? markerId) =>
      (super.noSuchMethod(
            Invocation.method(#hideMarkerInfoWindow, [markerId]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<bool> isMarkerInfoWindowShown(_i2.MarkerId? markerId) =>
      (super.noSuchMethod(
            Invocation.method(#isMarkerInfoWindowShown, [markerId]),
            returnValue: _i4.Future<bool>.value(false),
          )
          as _i4.Future<bool>);

  @override
  _i4.Future<double> getZoomLevel() =>
      (super.noSuchMethod(
            Invocation.method(#getZoomLevel, []),
            returnValue: _i4.Future<double>.value(0.0),
          )
          as _i4.Future<double>);

  @override
  _i4.Future<_i5.Uint8List?> takeSnapshot() =>
      (super.noSuchMethod(
            Invocation.method(#takeSnapshot, []),
            returnValue: _i4.Future<_i5.Uint8List?>.value(),
          )
          as _i4.Future<_i5.Uint8List?>);

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );
}
