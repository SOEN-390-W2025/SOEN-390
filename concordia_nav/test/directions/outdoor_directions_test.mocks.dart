// Mocks generated by Mockito 5.4.5 from annotations
// in concordia_nav/test/directions/outdoor_directions_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;
import 'dart:ui' as _i5;

import 'package:concordia_nav/data/services/outdoor_directions_service.dart'
    as _i3;
import 'package:google_directions_api/google_directions_api.dart' as _i2;
import 'package:google_maps_flutter/google_maps_flutter.dart' as _i6;
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

class _FakeDirectionsService_0 extends _i1.SmartFake
    implements _i2.DirectionsService {
  _FakeDirectionsService_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeOutdoorRouteResult_1 extends _i1.SmartFake
    implements _i3.OutdoorRouteResult {
  _FakeOutdoorRouteResult_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [DirectionsService].
///
/// See the documentation for Mockito's code generation for more information.
class MockDirectionsService extends _i1.Mock implements _i2.DirectionsService {
  MockDirectionsService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<void> route(
    _i2.DirectionsRequest? request,
    void Function(_i2.DirectionsResult, _i2.DirectionsStatus?)? callback,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#route, [request, callback]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);
}

/// A class which mocks [ODSDirectionsService].
///
/// See the documentation for Mockito's code generation for more information.
class MockODSDirectionsService extends _i1.Mock
    implements _i3.ODSDirectionsService {
  MockODSDirectionsService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.DirectionsService get directionsService =>
      (super.noSuchMethod(
            Invocation.getter(#directionsService),
            returnValue: _FakeDirectionsService_0(
              this,
              Invocation.getter(#directionsService),
            ),
          )
          as _i2.DirectionsService);

  @override
  set directionsService(_i2.DirectionsService? _directionsService) =>
      super.noSuchMethod(
        Invocation.setter(#directionsService, _directionsService),
        returnValueForMissingStub: null,
      );

  @override
  _i4.Future<_i3.OutdoorRouteResult> fetchRouteResult({
    required String? originAddress,
    required String? destinationAddress,
    required _i2.TravelMode? travelMode,
    String? polylineId = 'route',
    _i5.Color? color = const _i5.Color(4280391411),
    int? width = 5,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#fetchRouteResult, [], {
              #originAddress: originAddress,
              #destinationAddress: destinationAddress,
              #travelMode: travelMode,
              #polylineId: polylineId,
              #color: color,
              #width: width,
            }),
            returnValue: _i4.Future<_i3.OutdoorRouteResult>.value(
              _FakeOutdoorRouteResult_1(
                this,
                Invocation.method(#fetchRouteResult, [], {
                  #originAddress: originAddress,
                  #destinationAddress: destinationAddress,
                  #travelMode: travelMode,
                  #polylineId: polylineId,
                  #color: color,
                  #width: width,
                }),
              ),
            ),
          )
          as _i4.Future<_i3.OutdoorRouteResult>);

  @override
  _i4.Future<_i6.Polyline?> fetchWalkingPolyline({
    required String? originAddress,
    required String? destinationAddress,
    String? polylineId = 'walking_route',
    _i5.Color? color = const _i5.Color(4279007742),
    int? width = 5,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#fetchWalkingPolyline, [], {
              #originAddress: originAddress,
              #destinationAddress: destinationAddress,
              #polylineId: polylineId,
              #color: color,
              #width: width,
            }),
            returnValue: _i4.Future<_i6.Polyline?>.value(),
          )
          as _i4.Future<_i6.Polyline?>);

  @override
  _i4.Future<List<_i6.LatLng>> fetchRoute(
    String? originAddress,
    String? destinationAddress, {
    _i2.TravelMode? transport,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #fetchRoute,
              [originAddress, destinationAddress],
              {#transport: transport},
            ),
            returnValue: _i4.Future<List<_i6.LatLng>>.value(<_i6.LatLng>[]),
          )
          as _i4.Future<List<_i6.LatLng>>);

  @override
  _i4.Future<List<_i6.LatLng>> fetchRouteFromCoords(
    _i6.LatLng? origin,
    _i6.LatLng? destination, {
    _i2.TravelMode? transport,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #fetchRouteFromCoords,
              [origin, destination],
              {#transport: transport},
            ),
            returnValue: _i4.Future<List<_i6.LatLng>>.value(<_i6.LatLng>[]),
          )
          as _i4.Future<List<_i6.LatLng>>);

  @override
  _i4.Future<String?> fetchStaticMapUrl({
    required String? originAddress,
    required String? destinationAddress,
    required int? width,
    required int? height,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#fetchStaticMapUrl, [], {
              #originAddress: originAddress,
              #destinationAddress: destinationAddress,
              #width: width,
              #height: height,
            }),
            returnValue: _i4.Future<String?>.value(),
          )
          as _i4.Future<String?>);
}
