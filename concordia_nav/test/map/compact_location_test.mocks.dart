// Mocks generated by Mockito 5.4.5 from annotations
// in concordia_nav/test/map/compact_location_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i9;
import 'dart:ui' as _i12;

import 'package:concordia_nav/data/domain-model/concordia_building.dart' as _i8;
import 'package:concordia_nav/data/domain-model/concordia_campus.dart' as _i10;
import 'package:concordia_nav/data/services/map_service.dart' as _i3;
import 'package:concordia_nav/utils/map_viewmodel.dart' as _i6;
import 'package:flutter/foundation.dart' as _i2;
import 'package:flutter/material.dart' as _i5;
import 'package:google_maps_flutter/google_maps_flutter.dart' as _i4;
import 'package:http/http.dart' as _i11;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i7;

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

class _FakeValueNotifier_0<T> extends _i1.SmartFake
    implements _i2.ValueNotifier<T> {
  _FakeValueNotifier_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeMapService_1 extends _i1.SmartFake implements _i3.MapService {
  _FakeMapService_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeCameraPosition_2 extends _i1.SmartFake
    implements _i4.CameraPosition {
  _FakeCameraPosition_2(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeWidget_3 extends _i1.SmartFake implements _i5.Widget {
  _FakeWidget_3(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);

  @override
  String toString({_i2.DiagnosticLevel? minLevel = _i2.DiagnosticLevel.info}) =>
      super.toString();
}

/// A class which mocks [MapViewModel].
///
/// See the documentation for Mockito's code generation for more information.
class MockMapViewModel extends _i1.Mock implements _i6.MapViewModel {
  MockMapViewModel() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get yourLocationString =>
      (super.noSuchMethod(
            Invocation.getter(#yourLocationString),
            returnValue: _i7.dummyValue<String>(
              this,
              Invocation.getter(#yourLocationString),
            ),
          )
          as String);

  @override
  List<_i8.ConcordiaBuilding> get filteredBuildings =>
      (super.noSuchMethod(
            Invocation.getter(#filteredBuildings),
            returnValue: <_i8.ConcordiaBuilding>[],
          )
          as List<_i8.ConcordiaBuilding>);

  @override
  set filteredBuildings(List<_i8.ConcordiaBuilding>? _filteredBuildings) =>
      super.noSuchMethod(
        Invocation.setter(#filteredBuildings, _filteredBuildings),
        returnValueForMissingStub: null,
      );

  @override
  _i2.ValueNotifier<_i8.ConcordiaBuilding?> get selectedBuildingNotifier =>
      (super.noSuchMethod(
            Invocation.getter(#selectedBuildingNotifier),
            returnValue: _FakeValueNotifier_0<_i8.ConcordiaBuilding?>(
              this,
              Invocation.getter(#selectedBuildingNotifier),
            ),
          )
          as _i2.ValueNotifier<_i8.ConcordiaBuilding?>);

  @override
  set selectedBuildingNotifier(
    _i2.ValueNotifier<_i8.ConcordiaBuilding?>? _selectedBuildingNotifier,
  ) => super.noSuchMethod(
    Invocation.setter(#selectedBuildingNotifier, _selectedBuildingNotifier),
    returnValueForMissingStub: null,
  );

  @override
  _i2.ValueNotifier<Set<_i4.Marker>> get shuttleMarkersNotifier =>
      (super.noSuchMethod(
            Invocation.getter(#shuttleMarkersNotifier),
            returnValue: _FakeValueNotifier_0<Set<_i4.Marker>>(
              this,
              Invocation.getter(#shuttleMarkersNotifier),
            ),
          )
          as _i2.ValueNotifier<Set<_i4.Marker>>);

  @override
  set shuttleMarkersNotifier(
    _i2.ValueNotifier<Set<_i4.Marker>>? _shuttleMarkersNotifier,
  ) => super.noSuchMethod(
    Invocation.setter(#shuttleMarkersNotifier, _shuttleMarkersNotifier),
    returnValueForMissingStub: null,
  );

  @override
  set shuttleBusTimer(_i9.Timer? _shuttleBusTimer) => super.noSuchMethod(
    Invocation.setter(#shuttleBusTimer, _shuttleBusTimer),
    returnValueForMissingStub: null,
  );

  @override
  Map<_i6.CustomTravelMode, _i4.Polyline> get multiModeRoutes =>
      (super.noSuchMethod(
            Invocation.getter(#multiModeRoutes),
            returnValue: <_i6.CustomTravelMode, _i4.Polyline>{},
          )
          as Map<_i6.CustomTravelMode, _i4.Polyline>);

  @override
  Set<_i4.Marker> get staticBusStopMarkers =>
      (super.noSuchMethod(
            Invocation.getter(#staticBusStopMarkers),
            returnValue: <_i4.Marker>{},
          )
          as Set<_i4.Marker>);

  @override
  bool get shuttleAvailable =>
      (super.noSuchMethod(
            Invocation.getter(#shuttleAvailable),
            returnValue: false,
          )
          as bool);

  @override
  _i3.MapService get mapService =>
      (super.noSuchMethod(
            Invocation.getter(#mapService),
            returnValue: _FakeMapService_1(
              this,
              Invocation.getter(#mapService),
            ),
          )
          as _i3.MapService);

  @override
  Set<_i4.Polyline> get multiModePolylines =>
      (super.noSuchMethod(
            Invocation.getter(#multiModePolylines),
            returnValue: <_i4.Polyline>{},
          )
          as Set<_i4.Polyline>);

  @override
  Map<_i6.CustomTravelMode, String> get multiModeTravelTimes =>
      (super.noSuchMethod(
            Invocation.getter(#multiModeTravelTimes),
            returnValue: <_i6.CustomTravelMode, String>{},
          )
          as Map<_i6.CustomTravelMode, String>);

  @override
  _i6.CustomTravelMode get selectedTravelModeForRoute =>
      (super.noSuchMethod(
            Invocation.getter(#selectedTravelModeForRoute),
            returnValue: _i6.CustomTravelMode.driving,
          )
          as _i6.CustomTravelMode);

  @override
  Set<_i4.Polyline> get activePolylines =>
      (super.noSuchMethod(
            Invocation.getter(#activePolylines),
            returnValue: <_i4.Polyline>{},
          )
          as Set<_i4.Polyline>);

  @override
  Map<_i6.CustomTravelMode, String> get travelTimes =>
      (super.noSuchMethod(
            Invocation.getter(#travelTimes),
            returnValue: <_i6.CustomTravelMode, String>{},
          )
          as Map<_i6.CustomTravelMode, String>);

  @override
  _i6.CustomTravelMode get selectedTravelMode =>
      (super.noSuchMethod(
            Invocation.getter(#selectedTravelMode),
            returnValue: _i6.CustomTravelMode.driving,
          )
          as _i6.CustomTravelMode);

  @override
  bool get hasListeners =>
      (super.noSuchMethod(Invocation.getter(#hasListeners), returnValue: false)
          as bool);

  @override
  void setActiveMode(_i6.CustomTravelMode? mode) => super.noSuchMethod(
    Invocation.method(#setActiveMode, [mode]),
    returnValueForMissingStub: null,
  );

  @override
  _i9.Future<_i4.CameraPosition> getInitialCameraPosition(
    _i10.ConcordiaCampus? campus,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#getInitialCameraPosition, [campus]),
            returnValue: _i9.Future<_i4.CameraPosition>.value(
              _FakeCameraPosition_2(
                this,
                Invocation.method(#getInitialCameraPosition, [campus]),
              ),
            ),
          )
          as _i9.Future<_i4.CameraPosition>);

  @override
  _i9.Future<void> fetchRoutesForAllModes(
    String? originAddress,
    String? destinationAddress,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#fetchRoutesForAllModes, [
              originAddress,
              destinationAddress,
            ]),
            returnValue: _i9.Future<void>.value(),
            returnValueForMissingStub: _i9.Future<void>.value(),
          )
          as _i9.Future<void>);

  @override
  _i9.Future<_i4.LatLng?> geocodeAddress(String? address) =>
      (super.noSuchMethod(
            Invocation.method(#geocodeAddress, [address]),
            returnValue: _i9.Future<_i4.LatLng?>.value(),
          )
          as _i9.Future<_i4.LatLng?>);

  @override
  _i9.Future<void> fetchShuttleRoute(
    String? originAddress,
    String? destinationAddress,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#fetchShuttleRoute, [
              originAddress,
              destinationAddress,
            ]),
            returnValue: _i9.Future<void>.value(),
            returnValueForMissingStub: _i9.Future<void>.value(),
          )
          as _i9.Future<void>);

  @override
  double calculatePolylineDistance(_i4.Polyline? polyline) =>
      (super.noSuchMethod(
            Invocation.method(#calculatePolylineDistance, [polyline]),
            returnValue: 0.0,
          )
          as double);

  @override
  _i9.Future<void> setActiveModeForRoute(_i6.CustomTravelMode? mode) =>
      (super.noSuchMethod(
            Invocation.method(#setActiveModeForRoute, [mode]),
            returnValue: _i9.Future<void>.value(),
            returnValueForMissingStub: _i9.Future<void>.value(),
          )
          as _i9.Future<void>);

  @override
  void adjustCamera(List<_i4.LatLng>? points) => super.noSuchMethod(
    Invocation.method(#adjustCamera, [points]),
    returnValueForMissingStub: null,
  );

  @override
  void onMapCreated(_i4.GoogleMapController? controller) => super.noSuchMethod(
    Invocation.method(#onMapCreated, [controller]),
    returnValueForMissingStub: null,
  );

  @override
  void moveToLocation(_i4.LatLng? location) => super.noSuchMethod(
    Invocation.method(#moveToLocation, [location]),
    returnValueForMissingStub: null,
  );

  @override
  _i9.Future<Map<String, dynamic>> getCampusPolygonsAndLabels(
    _i10.ConcordiaCampus? campus,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#getCampusPolygonsAndLabels, [campus]),
            returnValue: _i9.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i9.Future<Map<String, dynamic>>);

  @override
  _i9.Future<Map<String, dynamic>> getAllCampusPolygonsAndLabels() =>
      (super.noSuchMethod(
            Invocation.method(#getAllCampusPolygonsAndLabels, []),
            returnValue: _i9.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i9.Future<Map<String, dynamic>>);

  @override
  void selectBuilding(_i8.ConcordiaBuilding? building) => super.noSuchMethod(
    Invocation.method(#selectBuilding, [building]),
    returnValueForMissingStub: null,
  );

  @override
  void unselectBuilding() => super.noSuchMethod(
    Invocation.method(#unselectBuilding, []),
    returnValueForMissingStub: null,
  );

  @override
  _i9.Future<_i4.LatLng?> fetchCurrentLocation() =>
      (super.noSuchMethod(
            Invocation.method(#fetchCurrentLocation, []),
            returnValue: _i9.Future<_i4.LatLng?>.value(),
          )
          as _i9.Future<_i4.LatLng?>);

  @override
  _i9.Future<bool> checkLocationAccess() =>
      (super.noSuchMethod(
            Invocation.method(#checkLocationAccess, []),
            returnValue: _i9.Future<bool>.value(false),
          )
          as _i9.Future<bool>);

  @override
  double getDistance(_i4.LatLng? point1, _i4.LatLng? point2) =>
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
  _i9.Future<void> fetchShuttleBusData({_i11.Client? client}) =>
      (super.noSuchMethod(
            Invocation.method(#fetchShuttleBusData, [], {#client: client}),
            returnValue: _i9.Future<void>.value(),
            returnValueForMissingStub: _i9.Future<void>.value(),
          )
          as _i9.Future<void>);

  @override
  _i9.Future<void> loadStaticBusStopMarkers() =>
      (super.noSuchMethod(
            Invocation.method(#loadStaticBusStopMarkers, []),
            returnValue: _i9.Future<void>.value(),
            returnValueForMissingStub: _i9.Future<void>.value(),
          )
          as _i9.Future<void>);

  @override
  _i9.Future<void> checkBuildingAtCurrentLocation(_i5.BuildContext? context) =>
      (super.noSuchMethod(
            Invocation.method(#checkBuildingAtCurrentLocation, [context]),
            returnValue: _i9.Future<void>.value(),
            returnValueForMissingStub: _i9.Future<void>.value(),
          )
          as _i9.Future<void>);

  @override
  _i9.Future<bool> moveToCurrentLocation(_i5.BuildContext? context) =>
      (super.noSuchMethod(
            Invocation.method(#moveToCurrentLocation, [context]),
            returnValue: _i9.Future<bool>.value(false),
          )
          as _i9.Future<bool>);

  @override
  _i5.Widget buildPlaceAutocompleteTextField({
    required _i5.TextEditingController? controller,
    required dynamic Function(dynamic)? onPlaceSelected,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#buildPlaceAutocompleteTextField, [], {
              #controller: controller,
              #onPlaceSelected: onPlaceSelected,
            }),
            returnValue: _FakeWidget_3(
              this,
              Invocation.method(#buildPlaceAutocompleteTextField, [], {
                #controller: controller,
                #onPlaceSelected: onPlaceSelected,
              }),
            ),
          )
          as _i5.Widget);

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );

  @override
  _i9.Future<void> handleSelection(
    String? selectedBuilding,
    _i4.LatLng? currentLocation,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#handleSelection, [
              selectedBuilding,
              currentLocation,
            ]),
            returnValue: _i9.Future<void>.value(),
            returnValueForMissingStub: _i9.Future<void>.value(),
          )
          as _i9.Future<void>);

  @override
  void addListener(_i12.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#addListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void removeListener(_i12.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#removeListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void notifyListeners() => super.noSuchMethod(
    Invocation.method(#notifyListeners, []),
    returnValueForMissingStub: null,
  );
}
