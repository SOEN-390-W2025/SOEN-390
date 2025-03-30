// Mocks generated by Mockito 5.4.5 from annotations
// in concordia_nav/test/indoor_map/indoor_map_viewmodel_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i10;
import 'dart:ui' as _i12;

import 'package:concordia_nav/data/domain-model/concordia_building.dart' as _i9;
import 'package:concordia_nav/data/domain-model/concordia_campus.dart' as _i13;
import 'package:concordia_nav/data/domain-model/concordia_room.dart' as _i7;
import 'package:concordia_nav/data/services/map_service.dart' as _i4;
import 'package:concordia_nav/data/services/outdoor_directions_service.dart'
    as _i3;
import 'package:concordia_nav/utils/indoor_map_viewmodel.dart' as _i6;
import 'package:concordia_nav/utils/map_viewmodel.dart' as _i11;
import 'package:flutter/material.dart' as _i2;
import 'package:google_maps_flutter/google_maps_flutter.dart' as _i5;
import 'package:http/http.dart' as _i14;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i8;

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

class _FakeTransformationController_0 extends _i1.SmartFake
    implements _i2.TransformationController {
  _FakeTransformationController_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeAnimationController_1 extends _i1.SmartFake
    implements _i2.AnimationController {
  _FakeAnimationController_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeValueNotifier_2<T> extends _i1.SmartFake
    implements _i2.ValueNotifier<T> {
  _FakeValueNotifier_2(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeODSDirectionsService_3 extends _i1.SmartFake
    implements _i3.ODSDirectionsService {
  _FakeODSDirectionsService_3(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeMapService_4 extends _i1.SmartFake implements _i4.MapService {
  _FakeMapService_4(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeCameraPosition_5 extends _i1.SmartFake
    implements _i5.CameraPosition {
  _FakeCameraPosition_5(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeWidget_6 extends _i1.SmartFake implements _i2.Widget {
  _FakeWidget_6(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);

  @override
  String toString({_i2.DiagnosticLevel? minLevel = _i2.DiagnosticLevel.info}) =>
      super.toString();
}

/// A class which mocks [IndoorMapViewModel].
///
/// See the documentation for Mockito's code generation for more information.
class MockIndoorMapViewModel extends _i1.Mock
    implements _i6.IndoorMapViewModel {
  MockIndoorMapViewModel() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.TransformationController get transformationController =>
      (super.noSuchMethod(
            Invocation.getter(#transformationController),
            returnValue: _FakeTransformationController_0(
              this,
              Invocation.getter(#transformationController),
            ),
          )
          as _i2.TransformationController);

  @override
  _i2.AnimationController get animationController =>
      (super.noSuchMethod(
            Invocation.getter(#animationController),
            returnValue: _FakeAnimationController_1(
              this,
              Invocation.getter(#animationController),
            ),
          )
          as _i2.AnimationController);

  @override
  _i2.ValueNotifier<Set<_i5.Marker>> get markersNotifier =>
      (super.noSuchMethod(
            Invocation.getter(#markersNotifier),
            returnValue: _FakeValueNotifier_2<Set<_i5.Marker>>(
              this,
              Invocation.getter(#markersNotifier),
            ),
          )
          as _i2.ValueNotifier<Set<_i5.Marker>>);

  @override
  _i2.ValueNotifier<Set<_i5.Polyline>> get polylinesNotifier =>
      (super.noSuchMethod(
            Invocation.getter(#polylinesNotifier),
            returnValue: _FakeValueNotifier_2<Set<_i5.Polyline>>(
              this,
              Invocation.getter(#polylinesNotifier),
            ),
          )
          as _i2.ValueNotifier<Set<_i5.Polyline>>);

  @override
  set selectedRoom(_i7.ConcordiaRoom? _selectedRoom) => super.noSuchMethod(
    Invocation.setter(#selectedRoom, _selectedRoom),
    returnValueForMissingStub: null,
  );

  @override
  _i3.ODSDirectionsService get odsDirectionsService =>
      (super.noSuchMethod(
            Invocation.getter(#odsDirectionsService),
            returnValue: _FakeODSDirectionsService_3(
              this,
              Invocation.getter(#odsDirectionsService),
            ),
          )
          as _i3.ODSDirectionsService);

  @override
  set odsDirectionsService(_i3.ODSDirectionsService? _odsDirectionsService) =>
      super.noSuchMethod(
        Invocation.setter(#odsDirectionsService, _odsDirectionsService),
        returnValueForMissingStub: null,
      );

  @override
  String get yourLocationString =>
      (super.noSuchMethod(
            Invocation.getter(#yourLocationString),
            returnValue: _i8.dummyValue<String>(
              this,
              Invocation.getter(#yourLocationString),
            ),
          )
          as String);

  @override
  List<_i9.ConcordiaBuilding> get filteredBuildings =>
      (super.noSuchMethod(
            Invocation.getter(#filteredBuildings),
            returnValue: <_i9.ConcordiaBuilding>[],
          )
          as List<_i9.ConcordiaBuilding>);

  @override
  set filteredBuildings(List<_i9.ConcordiaBuilding>? _filteredBuildings) =>
      super.noSuchMethod(
        Invocation.setter(#filteredBuildings, _filteredBuildings),
        returnValueForMissingStub: null,
      );

  @override
  _i2.ValueNotifier<_i9.ConcordiaBuilding?> get selectedBuildingNotifier =>
      (super.noSuchMethod(
            Invocation.getter(#selectedBuildingNotifier),
            returnValue: _FakeValueNotifier_2<_i9.ConcordiaBuilding?>(
              this,
              Invocation.getter(#selectedBuildingNotifier),
            ),
          )
          as _i2.ValueNotifier<_i9.ConcordiaBuilding?>);

  @override
  set selectedBuildingNotifier(
    _i2.ValueNotifier<_i9.ConcordiaBuilding?>? _selectedBuildingNotifier,
  ) => super.noSuchMethod(
    Invocation.setter(#selectedBuildingNotifier, _selectedBuildingNotifier),
    returnValueForMissingStub: null,
  );

  @override
  _i2.ValueNotifier<Set<_i5.Marker>> get shuttleMarkersNotifier =>
      (super.noSuchMethod(
            Invocation.getter(#shuttleMarkersNotifier),
            returnValue: _FakeValueNotifier_2<Set<_i5.Marker>>(
              this,
              Invocation.getter(#shuttleMarkersNotifier),
            ),
          )
          as _i2.ValueNotifier<Set<_i5.Marker>>);

  @override
  set shuttleMarkersNotifier(
    _i2.ValueNotifier<Set<_i5.Marker>>? _shuttleMarkersNotifier,
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
  Map<_i11.CustomTravelMode, _i5.Polyline> get multiModeRoutes =>
      (super.noSuchMethod(
            Invocation.getter(#multiModeRoutes),
            returnValue: <_i11.CustomTravelMode, _i5.Polyline>{},
          )
          as Map<_i11.CustomTravelMode, _i5.Polyline>);

  @override
  Set<_i5.Marker> get staticBusStopMarkers =>
      (super.noSuchMethod(
            Invocation.getter(#staticBusStopMarkers),
            returnValue: <_i5.Marker>{},
          )
          as Set<_i5.Marker>);

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
            returnValue: _FakeMapService_4(
              this,
              Invocation.getter(#mapService),
            ),
          )
          as _i4.MapService);

  @override
  Set<_i5.Polyline> get multiModePolylines =>
      (super.noSuchMethod(
            Invocation.getter(#multiModePolylines),
            returnValue: <_i5.Polyline>{},
          )
          as Set<_i5.Polyline>);

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
  Set<_i5.Polyline> get activePolylines =>
      (super.noSuchMethod(
            Invocation.getter(#activePolylines),
            returnValue: <_i5.Polyline>{},
          )
          as Set<_i5.Polyline>);

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
  void setInitialCameraPosition({
    double? scale = 1.0,
    double? offsetX = 0.0,
    double? offsetY = 0.0,
  }) => super.noSuchMethod(
    Invocation.method(#setInitialCameraPosition, [], {
      #scale: scale,
      #offsetX: offsetX,
      #offsetY: offsetY,
    }),
    returnValueForMissingStub: null,
  );

  @override
  void animateTo(_i2.Matrix4? targetMatrix) => super.noSuchMethod(
    Invocation.method(#animateTo, [targetMatrix]),
    returnValueForMissingStub: null,
  );

  @override
  void panToRegion({required double? offsetX, required double? offsetY}) =>
      super.noSuchMethod(
        Invocation.method(#panToRegion, [], {
          #offsetX: offsetX,
          #offsetY: offsetY,
        }),
        returnValueForMissingStub: null,
      );

  @override
  void centerOnPoint(
    _i12.Offset? point,
    _i12.Size? viewportSize, {
    double? padding = 50.0,
  }) => super.noSuchMethod(
    Invocation.method(
      #centerOnPoint,
      [point, viewportSize],
      {#padding: padding},
    ),
    returnValueForMissingStub: null,
  );

  @override
  void centerBetweenPoints(
    _i12.Offset? startLocation,
    _i12.Offset? endLocation,
    _i12.Size? viewportSize, {
    double? padding = 100.0,
  }) => super.noSuchMethod(
    Invocation.method(
      #centerBetweenPoints,
      [startLocation, endLocation, viewportSize],
      {#padding: padding},
    ),
    returnValueForMissingStub: null,
  );

  @override
  _i10.Future<bool> doesAssetExist(String? assetPath) =>
      (super.noSuchMethod(
            Invocation.method(#doesAssetExist, [assetPath]),
            returnValue: _i10.Future<bool>.value(false),
          )
          as _i10.Future<bool>);

  @override
  String extractFloor(String? roomName) =>
      (super.noSuchMethod(
            Invocation.method(#extractFloor, [roomName]),
            returnValue: _i8.dummyValue<String>(
              this,
              Invocation.method(#extractFloor, [roomName]),
            ),
          )
          as String);

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );

  @override
  void setActiveMode(_i11.CustomTravelMode? mode) => super.noSuchMethod(
    Invocation.method(#setActiveMode, [mode]),
    returnValueForMissingStub: null,
  );

  @override
  _i10.Future<_i5.CameraPosition> getInitialCameraPosition(
    _i13.ConcordiaCampus? campus,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#getInitialCameraPosition, [campus]),
            returnValue: _i10.Future<_i5.CameraPosition>.value(
              _FakeCameraPosition_5(
                this,
                Invocation.method(#getInitialCameraPosition, [campus]),
              ),
            ),
          )
          as _i10.Future<_i5.CameraPosition>);

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
  _i10.Future<_i5.LatLng?> geocodeAddress(String? address) =>
      (super.noSuchMethod(
            Invocation.method(#geocodeAddress, [address]),
            returnValue: _i10.Future<_i5.LatLng?>.value(),
          )
          as _i10.Future<_i5.LatLng?>);

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
  double calculatePolylineDistance(_i5.Polyline? polyline) =>
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
  void adjustCamera(List<_i5.LatLng>? points) => super.noSuchMethod(
    Invocation.method(#adjustCamera, [points]),
    returnValueForMissingStub: null,
  );

  @override
  void onMapCreated(_i5.GoogleMapController? controller) => super.noSuchMethod(
    Invocation.method(#onMapCreated, [controller]),
    returnValueForMissingStub: null,
  );

  @override
  void moveToLocation(_i5.LatLng? location) => super.noSuchMethod(
    Invocation.method(#moveToLocation, [location]),
    returnValueForMissingStub: null,
  );

  @override
  _i10.Future<Map<String, dynamic>> getCampusPolygonsAndLabels(
    _i13.ConcordiaCampus? campus,
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
  void selectBuilding(_i9.ConcordiaBuilding? building) => super.noSuchMethod(
    Invocation.method(#selectBuilding, [building]),
    returnValueForMissingStub: null,
  );

  @override
  void unselectBuilding() => super.noSuchMethod(
    Invocation.method(#unselectBuilding, []),
    returnValueForMissingStub: null,
  );

  @override
  _i10.Future<_i5.LatLng?> fetchCurrentLocation() =>
      (super.noSuchMethod(
            Invocation.method(#fetchCurrentLocation, []),
            returnValue: _i10.Future<_i5.LatLng?>.value(),
          )
          as _i10.Future<_i5.LatLng?>);

  @override
  _i10.Future<bool> checkLocationAccess() =>
      (super.noSuchMethod(
            Invocation.method(#checkLocationAccess, []),
            returnValue: _i10.Future<bool>.value(false),
          )
          as _i10.Future<bool>);

  @override
  double getDistance(_i5.LatLng? point1, _i5.LatLng? point2) =>
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
  _i10.Future<void> fetchShuttleBusData({_i14.Client? client}) =>
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
  _i10.Future<void> checkBuildingAtCurrentLocation(_i2.BuildContext? context) =>
      (super.noSuchMethod(
            Invocation.method(#checkBuildingAtCurrentLocation, [context]),
            returnValue: _i10.Future<void>.value(),
            returnValueForMissingStub: _i10.Future<void>.value(),
          )
          as _i10.Future<void>);

  @override
  _i10.Future<bool> moveToCurrentLocation(_i2.BuildContext? context) =>
      (super.noSuchMethod(
            Invocation.method(#moveToCurrentLocation, [context]),
            returnValue: _i10.Future<bool>.value(false),
          )
          as _i10.Future<bool>);

  @override
  _i2.Widget buildPlaceAutocompleteTextField({
    required _i2.TextEditingController? controller,
    required dynamic Function(dynamic)? onPlaceSelected,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#buildPlaceAutocompleteTextField, [], {
              #controller: controller,
              #onPlaceSelected: onPlaceSelected,
            }),
            returnValue: _FakeWidget_6(
              this,
              Invocation.method(#buildPlaceAutocompleteTextField, [], {
                #controller: controller,
                #onPlaceSelected: onPlaceSelected,
              }),
            ),
          )
          as _i2.Widget);

  @override
  _i10.Future<void> handleSelection(
    String? selectedBuilding,
    _i5.LatLng? currentLocation,
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
