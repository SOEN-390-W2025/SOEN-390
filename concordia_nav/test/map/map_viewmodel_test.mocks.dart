// Mocks generated by Mockito 5.4.5 from annotations
// in concordia_nav/test/map/map_viewmodel_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i10;
import 'dart:convert' as _i15;
import 'dart:typed_data' as _i16;
import 'dart:ui' as _i14;

import 'package:concordia_nav/data/domain-model/concordia_building.dart'
    as _i13;
import 'package:concordia_nav/data/domain-model/concordia_campus.dart' as _i9;
import 'package:concordia_nav/data/repositories/map_repository.dart' as _i8;
import 'package:concordia_nav/data/services/map_service.dart' as _i4;
import 'package:concordia_nav/data/services/outdoor_directions_service.dart'
    as _i6;
import 'package:concordia_nav/utils/map_viewmodel.dart' as _i11;
import 'package:flutter/material.dart' as _i3;
import 'package:google_directions_api/google_directions_api.dart' as _i5;
import 'package:google_maps_flutter/google_maps_flutter.dart' as _i2;
import 'package:http/http.dart' as _i7;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i12;

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

class _FakeCameraPosition_0 extends _i1.SmartFake
    implements _i2.CameraPosition {
  _FakeCameraPosition_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeBitmapDescriptor_1 extends _i1.SmartFake
    implements _i2.BitmapDescriptor {
  _FakeBitmapDescriptor_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeValueNotifier_2<T> extends _i1.SmartFake
    implements _i3.ValueNotifier<T> {
  _FakeValueNotifier_2(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeMapService_3 extends _i1.SmartFake implements _i4.MapService {
  _FakeMapService_3(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeDirectionsService_4 extends _i1.SmartFake
    implements _i5.DirectionsService {
  _FakeDirectionsService_4(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeOutdoorRouteResult_5 extends _i1.SmartFake
    implements _i6.OutdoorRouteResult {
  _FakeOutdoorRouteResult_5(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeResponse_6 extends _i1.SmartFake implements _i7.Response {
  _FakeResponse_6(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeStreamedResponse_7 extends _i1.SmartFake
    implements _i7.StreamedResponse {
  _FakeStreamedResponse_7(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [MapRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockMapRepository extends _i1.Mock implements _i8.MapRepository {
  MockMapRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.CameraPosition getCameraPosition(_i9.ConcordiaCampus? campus) =>
      (super.noSuchMethod(
            Invocation.method(#getCameraPosition, [campus]),
            returnValue: _FakeCameraPosition_0(
              this,
              Invocation.method(#getCameraPosition, [campus]),
            ),
          )
          as _i2.CameraPosition);
}

/// A class which mocks [MapService].
///
/// See the documentation for Mockito's code generation for more information.
class MockMapService extends _i1.Mock implements _i4.MapService {
  MockMapService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void setMapController(_i2.GoogleMapController? controller) =>
      super.noSuchMethod(
        Invocation.method(#setMapController, [controller]),
        returnValueForMissingStub: null,
      );

  @override
  void setDirectionsService(_i6.ODSDirectionsService? directionsService) =>
      super.noSuchMethod(
        Invocation.method(#setDirectionsService, [directionsService]),
        returnValueForMissingStub: null,
      );

  @override
  _i2.CameraPosition getInitialCameraPosition(_i9.ConcordiaCampus? campus) =>
      (super.noSuchMethod(
            Invocation.method(#getInitialCameraPosition, [campus]),
            returnValue: _FakeCameraPosition_0(
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
  _i10.Future<_i2.BitmapDescriptor> getCustomIcon(String? name) =>
      (super.noSuchMethod(
            Invocation.method(#getCustomIcon, [name]),
            returnValue: _i10.Future<_i2.BitmapDescriptor>.value(
              _FakeBitmapDescriptor_1(
                this,
                Invocation.method(#getCustomIcon, [name]),
              ),
            ),
          )
          as _i10.Future<_i2.BitmapDescriptor>);

  @override
  _i10.Future<bool> isLocationServiceEnabled() =>
      (super.noSuchMethod(
            Invocation.method(#isLocationServiceEnabled, []),
            returnValue: _i10.Future<bool>.value(false),
          )
          as _i10.Future<bool>);

  @override
  _i10.Future<bool> checkAndRequestLocationPermission() =>
      (super.noSuchMethod(
            Invocation.method(#checkAndRequestLocationPermission, []),
            returnValue: _i10.Future<bool>.value(false),
          )
          as _i10.Future<bool>);

  @override
  _i10.Future<_i2.LatLng?> getCurrentLocation() =>
      (super.noSuchMethod(
            Invocation.method(#getCurrentLocation, []),
            returnValue: _i10.Future<_i2.LatLng?>.value(),
          )
          as _i10.Future<_i2.LatLng?>);

  @override
  double calculateDistance(_i2.LatLng? point1, _i2.LatLng? point2) =>
      (super.noSuchMethod(
            Invocation.method(#calculateDistance, [point1, point2]),
            returnValue: 0.0,
          )
          as double);

  @override
  _i10.Future<List<_i2.LatLng>> getRoutePath(
    String? originAddress,
    String? destinationAddress,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#getRoutePath, [
              originAddress,
              destinationAddress,
            ]),
            returnValue: _i10.Future<List<_i2.LatLng>>.value(<_i2.LatLng>[]),
          )
          as _i10.Future<List<_i2.LatLng>>);
}

/// A class which mocks [MapViewModel].
///
/// See the documentation for Mockito's code generation for more information.
class MockMapViewModel extends _i1.Mock implements _i11.MapViewModel {
  MockMapViewModel() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get yourLocationString =>
      (super.noSuchMethod(
            Invocation.getter(#yourLocationString),
            returnValue: _i12.dummyValue<String>(
              this,
              Invocation.getter(#yourLocationString),
            ),
          )
          as String);

  @override
  List<_i13.ConcordiaBuilding> get filteredBuildings =>
      (super.noSuchMethod(
            Invocation.getter(#filteredBuildings),
            returnValue: <_i13.ConcordiaBuilding>[],
          )
          as List<_i13.ConcordiaBuilding>);

  @override
  set filteredBuildings(List<_i13.ConcordiaBuilding>? _filteredBuildings) =>
      super.noSuchMethod(
        Invocation.setter(#filteredBuildings, _filteredBuildings),
        returnValueForMissingStub: null,
      );

  @override
  _i3.ValueNotifier<_i13.ConcordiaBuilding?> get selectedBuildingNotifier =>
      (super.noSuchMethod(
            Invocation.getter(#selectedBuildingNotifier),
            returnValue: _FakeValueNotifier_2<_i13.ConcordiaBuilding?>(
              this,
              Invocation.getter(#selectedBuildingNotifier),
            ),
          )
          as _i3.ValueNotifier<_i13.ConcordiaBuilding?>);

  @override
  set selectedBuildingNotifier(
    _i3.ValueNotifier<_i13.ConcordiaBuilding?>? _selectedBuildingNotifier,
  ) => super.noSuchMethod(
    Invocation.setter(#selectedBuildingNotifier, _selectedBuildingNotifier),
    returnValueForMissingStub: null,
  );

  @override
  _i3.ValueNotifier<Set<_i2.Marker>> get shuttleMarkersNotifier =>
      (super.noSuchMethod(
            Invocation.getter(#shuttleMarkersNotifier),
            returnValue: _FakeValueNotifier_2<Set<_i2.Marker>>(
              this,
              Invocation.getter(#shuttleMarkersNotifier),
            ),
          )
          as _i3.ValueNotifier<Set<_i2.Marker>>);

  @override
  set shuttleMarkersNotifier(
    _i3.ValueNotifier<Set<_i2.Marker>>? _shuttleMarkersNotifier,
  ) => super.noSuchMethod(
    Invocation.setter(#shuttleMarkersNotifier, _shuttleMarkersNotifier),
    returnValueForMissingStub: null,
  );

  @override
  set shuttleBusTimer(_i10.Timer? _shuttleBusTimer) => super.noSuchMethod(
    Invocation.setter(#shuttleBusTimer, _shuttleBusTimer),
    returnValueForMissingStub: null,
  );

  @override
  Map<_i11.CustomTravelMode, _i2.Polyline> get multiModeRoutes =>
      (super.noSuchMethod(
            Invocation.getter(#multiModeRoutes),
            returnValue: <_i11.CustomTravelMode, _i2.Polyline>{},
          )
          as Map<_i11.CustomTravelMode, _i2.Polyline>);

  @override
  Set<_i2.Marker> get staticBusStopMarkers =>
      (super.noSuchMethod(
            Invocation.getter(#staticBusStopMarkers),
            returnValue: <_i2.Marker>{},
          )
          as Set<_i2.Marker>);

  @override
  bool get shuttleAvailable =>
      (super.noSuchMethod(
            Invocation.getter(#shuttleAvailable),
            returnValue: false,
          )
          as bool);

  @override
  _i4.MapService get mapService =>
      (super.noSuchMethod(
            Invocation.getter(#mapService),
            returnValue: _FakeMapService_3(
              this,
              Invocation.getter(#mapService),
            ),
          )
          as _i4.MapService);

  @override
  Set<_i2.Polyline> get multiModePolylines =>
      (super.noSuchMethod(
            Invocation.getter(#multiModePolylines),
            returnValue: <_i2.Polyline>{},
          )
          as Set<_i2.Polyline>);

  @override
  Map<_i11.CustomTravelMode, String> get multiModeTravelTimes =>
      (super.noSuchMethod(
            Invocation.getter(#multiModeTravelTimes),
            returnValue: <_i11.CustomTravelMode, String>{},
          )
          as Map<_i11.CustomTravelMode, String>);

  @override
  _i11.CustomTravelMode get selectedTravelModeForRoute =>
      (super.noSuchMethod(
            Invocation.getter(#selectedTravelModeForRoute),
            returnValue: _i11.CustomTravelMode.driving,
          )
          as _i11.CustomTravelMode);

  @override
  Set<_i2.Polyline> get activePolylines =>
      (super.noSuchMethod(
            Invocation.getter(#activePolylines),
            returnValue: <_i2.Polyline>{},
          )
          as Set<_i2.Polyline>);

  @override
  Map<_i11.CustomTravelMode, String> get travelTimes =>
      (super.noSuchMethod(
            Invocation.getter(#travelTimes),
            returnValue: <_i11.CustomTravelMode, String>{},
          )
          as Map<_i11.CustomTravelMode, String>);

  @override
  _i11.CustomTravelMode get selectedTravelMode =>
      (super.noSuchMethod(
            Invocation.getter(#selectedTravelMode),
            returnValue: _i11.CustomTravelMode.driving,
          )
          as _i11.CustomTravelMode);

  @override
  bool get hasListeners =>
      (super.noSuchMethod(Invocation.getter(#hasListeners), returnValue: false)
          as bool);

  @override
  void setActiveMode(_i11.CustomTravelMode? mode) => super.noSuchMethod(
    Invocation.method(#setActiveMode, [mode]),
    returnValueForMissingStub: null,
  );

  @override
  _i10.Future<_i2.CameraPosition> getInitialCameraPosition(
    _i9.ConcordiaCampus? campus,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#getInitialCameraPosition, [campus]),
            returnValue: _i10.Future<_i2.CameraPosition>.value(
              _FakeCameraPosition_0(
                this,
                Invocation.method(#getInitialCameraPosition, [campus]),
              ),
            ),
          )
          as _i10.Future<_i2.CameraPosition>);

  @override
  _i10.Future<void> fetchRoutesForAllModes(
    String? originAddress,
    String? destinationAddress,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#fetchRoutesForAllModes, [
              originAddress,
              destinationAddress,
            ]),
            returnValue: _i10.Future<void>.value(),
            returnValueForMissingStub: _i10.Future<void>.value(),
          )
          as _i10.Future<void>);

  @override
  _i10.Future<_i2.LatLng?> geocodeAddress(String? address) =>
      (super.noSuchMethod(
            Invocation.method(#geocodeAddress, [address]),
            returnValue: _i10.Future<_i2.LatLng?>.value(),
          )
          as _i10.Future<_i2.LatLng?>);

  @override
  _i10.Future<void> fetchShuttleRoute(
    String? originAddress,
    String? destinationAddress,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#fetchShuttleRoute, [
              originAddress,
              destinationAddress,
            ]),
            returnValue: _i10.Future<void>.value(),
            returnValueForMissingStub: _i10.Future<void>.value(),
          )
          as _i10.Future<void>);

  @override
  double calculatePolylineDistance(_i2.Polyline? polyline) =>
      (super.noSuchMethod(
            Invocation.method(#calculatePolylineDistance, [polyline]),
            returnValue: 0.0,
          )
          as double);

  @override
  _i10.Future<void> setActiveModeForRoute(_i11.CustomTravelMode? mode) =>
      (super.noSuchMethod(
            Invocation.method(#setActiveModeForRoute, [mode]),
            returnValue: _i10.Future<void>.value(),
            returnValueForMissingStub: _i10.Future<void>.value(),
          )
          as _i10.Future<void>);

  @override
  void adjustCamera(List<_i2.LatLng>? points) => super.noSuchMethod(
    Invocation.method(#adjustCamera, [points]),
    returnValueForMissingStub: null,
  );

  @override
  void onMapCreated(_i2.GoogleMapController? controller) => super.noSuchMethod(
    Invocation.method(#onMapCreated, [controller]),
    returnValueForMissingStub: null,
  );

  @override
  void moveToLocation(_i2.LatLng? location) => super.noSuchMethod(
    Invocation.method(#moveToLocation, [location]),
    returnValueForMissingStub: null,
  );

  @override
  _i10.Future<Map<String, dynamic>> getCampusPolygonsAndLabels(
    _i9.ConcordiaCampus? campus,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#getCampusPolygonsAndLabels, [campus]),
            returnValue: _i10.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i10.Future<Map<String, dynamic>>);

  @override
  _i10.Future<Map<String, dynamic>> getAllCampusPolygonsAndLabels() =>
      (super.noSuchMethod(
            Invocation.method(#getAllCampusPolygonsAndLabels, []),
            returnValue: _i10.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i10.Future<Map<String, dynamic>>);

  @override
  void selectBuilding(_i13.ConcordiaBuilding? building) => super.noSuchMethod(
    Invocation.method(#selectBuilding, [building]),
    returnValueForMissingStub: null,
  );

  @override
  void unselectBuilding() => super.noSuchMethod(
    Invocation.method(#unselectBuilding, []),
    returnValueForMissingStub: null,
  );

  @override
  _i10.Future<_i2.LatLng?> fetchCurrentLocation() =>
      (super.noSuchMethod(
            Invocation.method(#fetchCurrentLocation, []),
            returnValue: _i10.Future<_i2.LatLng?>.value(),
          )
          as _i10.Future<_i2.LatLng?>);

  @override
  _i10.Future<bool> checkLocationAccess() =>
      (super.noSuchMethod(
            Invocation.method(#checkLocationAccess, []),
            returnValue: _i10.Future<bool>.value(false),
          )
          as _i10.Future<bool>);

  @override
  double getDistance(_i2.LatLng? point1, _i2.LatLng? point2) =>
      (super.noSuchMethod(
            Invocation.method(#getDistance, [point1, point2]),
            returnValue: 0.0,
          )
          as double);

  @override
  void startShuttleBusTimer() => super.noSuchMethod(
    Invocation.method(#startShuttleBusTimer, []),
    returnValueForMissingStub: null,
  );

  @override
  void stopShuttleBusTimer() => super.noSuchMethod(
    Invocation.method(#stopShuttleBusTimer, []),
    returnValueForMissingStub: null,
  );

  @override
  _i10.Future<void> fetchShuttleBusData({_i7.Client? client}) =>
      (super.noSuchMethod(
            Invocation.method(#fetchShuttleBusData, [], {#client: client}),
            returnValue: _i10.Future<void>.value(),
            returnValueForMissingStub: _i10.Future<void>.value(),
          )
          as _i10.Future<void>);

  @override
  _i10.Future<void> loadStaticBusStopMarkers() =>
      (super.noSuchMethod(
            Invocation.method(#loadStaticBusStopMarkers, []),
            returnValue: _i10.Future<void>.value(),
            returnValueForMissingStub: _i10.Future<void>.value(),
          )
          as _i10.Future<void>);

  @override
  _i10.Future<void> checkBuildingAtCurrentLocation(_i3.BuildContext? context) =>
      (super.noSuchMethod(
            Invocation.method(#checkBuildingAtCurrentLocation, [context]),
            returnValue: _i10.Future<void>.value(),
            returnValueForMissingStub: _i10.Future<void>.value(),
          )
          as _i10.Future<void>);

  @override
  _i10.Future<bool> moveToCurrentLocation(_i3.BuildContext? context) =>
      (super.noSuchMethod(
            Invocation.method(#moveToCurrentLocation, [context]),
            returnValue: _i10.Future<bool>.value(false),
          )
          as _i10.Future<bool>);

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );

  @override
  _i10.Future<void> handleSelection(
    String? selectedBuilding,
    _i2.LatLng? currentLocation,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#handleSelection, [
              selectedBuilding,
              currentLocation,
            ]),
            returnValue: _i10.Future<void>.value(),
            returnValueForMissingStub: _i10.Future<void>.value(),
          )
          as _i10.Future<void>);

  @override
  void addListener(_i14.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#addListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void removeListener(_i14.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#removeListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void notifyListeners() => super.noSuchMethod(
    Invocation.method(#notifyListeners, []),
    returnValueForMissingStub: null,
  );
}

/// A class which mocks [ODSDirectionsService].
///
/// See the documentation for Mockito's code generation for more information.
class MockODSDirectionsService extends _i1.Mock
    implements _i6.ODSDirectionsService {
  MockODSDirectionsService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.DirectionsService get directionsService =>
      (super.noSuchMethod(
            Invocation.getter(#directionsService),
            returnValue: _FakeDirectionsService_4(
              this,
              Invocation.getter(#directionsService),
            ),
          )
          as _i5.DirectionsService);

  @override
  set directionsService(_i5.DirectionsService? _directionsService) =>
      super.noSuchMethod(
        Invocation.setter(#directionsService, _directionsService),
        returnValueForMissingStub: null,
      );

  @override
  _i10.Future<_i6.OutdoorRouteResult> fetchRouteResult({
    required String? originAddress,
    required String? destinationAddress,
    required _i5.TravelMode? travelMode,
    String? polylineId = 'route',
    _i14.Color? color = const _i14.Color(4280391411),
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
            returnValue: _i10.Future<_i6.OutdoorRouteResult>.value(
              _FakeOutdoorRouteResult_5(
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
          as _i10.Future<_i6.OutdoorRouteResult>);

  @override
  _i10.Future<_i2.Polyline?> fetchWalkingPolyline({
    required String? originAddress,
    required String? destinationAddress,
    String? polylineId = 'walking_route',
    _i14.Color? color = const _i14.Color(4279007742),
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
            returnValue: _i10.Future<_i2.Polyline?>.value(),
          )
          as _i10.Future<_i2.Polyline?>);

  @override
  _i10.Future<List<_i2.LatLng>> fetchRoute(
    String? originAddress,
    String? destinationAddress,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#fetchRoute, [originAddress, destinationAddress]),
            returnValue: _i10.Future<List<_i2.LatLng>>.value(<_i2.LatLng>[]),
          )
          as _i10.Future<List<_i2.LatLng>>);

  @override
  _i10.Future<List<_i2.LatLng>> fetchRouteFromCoords(
    _i2.LatLng? origin,
    _i2.LatLng? destination,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#fetchRouteFromCoords, [origin, destination]),
            returnValue: _i10.Future<List<_i2.LatLng>>.value(<_i2.LatLng>[]),
          )
          as _i10.Future<List<_i2.LatLng>>);
}

/// A class which mocks [Client].
///
/// See the documentation for Mockito's code generation for more information.
class MockClient extends _i1.Mock implements _i7.Client {
  MockClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i10.Future<_i7.Response> head(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(
            Invocation.method(#head, [url], {#headers: headers}),
            returnValue: _i10.Future<_i7.Response>.value(
              _FakeResponse_6(
                this,
                Invocation.method(#head, [url], {#headers: headers}),
              ),
            ),
          )
          as _i10.Future<_i7.Response>);

  @override
  _i10.Future<_i7.Response> get(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(
            Invocation.method(#get, [url], {#headers: headers}),
            returnValue: _i10.Future<_i7.Response>.value(
              _FakeResponse_6(
                this,
                Invocation.method(#get, [url], {#headers: headers}),
              ),
            ),
          )
          as _i10.Future<_i7.Response>);

  @override
  _i10.Future<_i7.Response> post(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i15.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #post,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
            returnValue: _i10.Future<_i7.Response>.value(
              _FakeResponse_6(
                this,
                Invocation.method(
                  #post,
                  [url],
                  {#headers: headers, #body: body, #encoding: encoding},
                ),
              ),
            ),
          )
          as _i10.Future<_i7.Response>);

  @override
  _i10.Future<_i7.Response> put(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i15.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #put,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
            returnValue: _i10.Future<_i7.Response>.value(
              _FakeResponse_6(
                this,
                Invocation.method(
                  #put,
                  [url],
                  {#headers: headers, #body: body, #encoding: encoding},
                ),
              ),
            ),
          )
          as _i10.Future<_i7.Response>);

  @override
  _i10.Future<_i7.Response> patch(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i15.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #patch,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
            returnValue: _i10.Future<_i7.Response>.value(
              _FakeResponse_6(
                this,
                Invocation.method(
                  #patch,
                  [url],
                  {#headers: headers, #body: body, #encoding: encoding},
                ),
              ),
            ),
          )
          as _i10.Future<_i7.Response>);

  @override
  _i10.Future<_i7.Response> delete(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i15.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #delete,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
            returnValue: _i10.Future<_i7.Response>.value(
              _FakeResponse_6(
                this,
                Invocation.method(
                  #delete,
                  [url],
                  {#headers: headers, #body: body, #encoding: encoding},
                ),
              ),
            ),
          )
          as _i10.Future<_i7.Response>);

  @override
  _i10.Future<String> read(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(
            Invocation.method(#read, [url], {#headers: headers}),
            returnValue: _i10.Future<String>.value(
              _i12.dummyValue<String>(
                this,
                Invocation.method(#read, [url], {#headers: headers}),
              ),
            ),
          )
          as _i10.Future<String>);

  @override
  _i10.Future<_i16.Uint8List> readBytes(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#readBytes, [url], {#headers: headers}),
            returnValue: _i10.Future<_i16.Uint8List>.value(_i16.Uint8List(0)),
          )
          as _i10.Future<_i16.Uint8List>);

  @override
  _i10.Future<_i7.StreamedResponse> send(_i7.BaseRequest? request) =>
      (super.noSuchMethod(
            Invocation.method(#send, [request]),
            returnValue: _i10.Future<_i7.StreamedResponse>.value(
              _FakeStreamedResponse_7(
                this,
                Invocation.method(#send, [request]),
              ),
            ),
          )
          as _i10.Future<_i7.StreamedResponse>);

  @override
  void close() => super.noSuchMethod(
    Invocation.method(#close, []),
    returnValueForMissingStub: null,
  );
}
