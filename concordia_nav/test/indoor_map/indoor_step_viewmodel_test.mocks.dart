// Mocks generated by Mockito 5.4.5 from annotations
// in concordia_nav/test/indoor_map/indoor_step_viewmodel_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;
import 'dart:ui' as _i2;

import 'package:concordia_nav/data/domain-model/concordia_floor_point.dart'
    as _i6;
import 'package:concordia_nav/data/domain-model/poi.dart' as _i8;
import 'package:concordia_nav/data/repositories/building_data.dart' as _i7;
import 'package:concordia_nav/utils/indoor_directions_viewmodel.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i4;

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

class _FakeOffset_0 extends _i1.SmartFake implements _i2.Offset {
  _FakeOffset_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeSize_1 extends _i1.SmartFake implements _i2.Size {
  _FakeSize_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [IndoorDirectionsViewModel].
///
/// See the documentation for Mockito's code generation for more information.
class MockIndoorDirectionsViewModel extends _i1.Mock
    implements _i3.IndoorDirectionsViewModel {
  MockIndoorDirectionsViewModel() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get mainEntranceString =>
      (super.noSuchMethod(
            Invocation.getter(#mainEntranceString),
            returnValue: _i4.dummyValue<String>(
              this,
              Invocation.getter(#mainEntranceString),
            ),
          )
          as String);

  @override
  String get eta =>
      (super.noSuchMethod(
            Invocation.getter(#eta),
            returnValue: _i4.dummyValue<String>(this, Invocation.getter(#eta)),
          )
          as String);

  @override
  set eta(String? _eta) => super.noSuchMethod(
    Invocation.setter(#eta, _eta),
    returnValueForMissingStub: null,
  );

  @override
  String get distance =>
      (super.noSuchMethod(
            Invocation.getter(#distance),
            returnValue: _i4.dummyValue<String>(
              this,
              Invocation.getter(#distance),
            ),
          )
          as String);

  @override
  set distance(String? _distance) => super.noSuchMethod(
    Invocation.setter(#distance, _distance),
    returnValueForMissingStub: null,
  );

  @override
  String get measurementUnit =>
      (super.noSuchMethod(
            Invocation.getter(#measurementUnit),
            returnValue: _i4.dummyValue<String>(
              this,
              Invocation.getter(#measurementUnit),
            ),
          )
          as String);

  @override
  set measurementUnit(String? _measurementUnit) => super.noSuchMethod(
    Invocation.setter(#measurementUnit, _measurementUnit),
    returnValueForMissingStub: null,
  );

  @override
  bool get isLoading =>
      (super.noSuchMethod(Invocation.getter(#isLoading), returnValue: false)
          as bool);

  @override
  bool get isAccessibilityMode =>
      (super.noSuchMethod(
            Invocation.getter(#isAccessibilityMode),
            returnValue: false,
          )
          as bool);

  @override
  _i2.Offset get startLocation =>
      (super.noSuchMethod(
            Invocation.getter(#startLocation),
            returnValue: _FakeOffset_0(this, Invocation.getter(#startLocation)),
          )
          as _i2.Offset);

  @override
  _i2.Offset get endLocation =>
      (super.noSuchMethod(
            Invocation.getter(#endLocation),
            returnValue: _FakeOffset_0(this, Invocation.getter(#endLocation)),
          )
          as _i2.Offset);

  @override
  set endLocation(_i2.Offset? value) => super.noSuchMethod(
    Invocation.setter(#endLocation, value),
    returnValueForMissingStub: null,
  );

  @override
  bool get hasListeners =>
      (super.noSuchMethod(Invocation.getter(#hasListeners), returnValue: false)
          as bool);

  @override
  void toggleAccessibilityMode(bool? value) => super.noSuchMethod(
    Invocation.method(#toggleAccessibilityMode, [value]),
    returnValueForMissingStub: null,
  );

  @override
  _i5.Future<_i6.ConcordiaFloorPoint?> getPositionPoint(
    String? buildingName,
    String? floor,
    String? room,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#getPositionPoint, [buildingName, floor, room]),
            returnValue: _i5.Future<_i6.ConcordiaFloorPoint?>.value(),
          )
          as _i5.Future<_i6.ConcordiaFloorPoint?>);

  @override
  _i6.ConcordiaFloorPoint? getRegularStartPoint(
    _i7.BuildingData? buildingData,
    String? floor, {
    String? connection,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #getRegularStartPoint,
              [buildingData, floor],
              {#connection: connection},
            ),
          )
          as _i6.ConcordiaFloorPoint?);

  @override
  _i5.Future<_i6.ConcordiaFloorPoint?> getStartPoint(
    String? buildingName,
    String? floor,
    bool? disability,
    String? connection,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#getStartPoint, [
              buildingName,
              floor,
              disability,
              connection,
            ]),
            returnValue: _i5.Future<_i6.ConcordiaFloorPoint?>.value(),
          )
          as _i5.Future<_i6.ConcordiaFloorPoint?>);

  @override
  _i5.Future<void> calculateRoute(
    String? building,
    String? floor,
    String? sourceRoom,
    String? endRoom,
    bool? disability, {
    _i8.POI? destinationPOI,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #calculateRoute,
              [building, floor, sourceRoom, endRoom, disability],
              {#destinationPOI: destinationPOI},
            ),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<bool> areDirectionsAvailableForLocation(String? location) =>
      (super.noSuchMethod(
            Invocation.method(#areDirectionsAvailableForLocation, [location]),
            returnValue: _i5.Future<bool>.value(false),
          )
          as _i5.Future<bool>);

  @override
  _i5.Future<bool> checkFloorPlanExists(String? floorPlanPath) =>
      (super.noSuchMethod(
            Invocation.method(#checkFloorPlanExists, [floorPlanPath]),
            returnValue: _i5.Future<bool>.value(false),
          )
          as _i5.Future<bool>);

  @override
  _i5.Future<_i2.Size> getSvgDimensions(String? svgPath) =>
      (super.noSuchMethod(
            Invocation.method(#getSvgDimensions, [svgPath]),
            returnValue: _i5.Future<_i2.Size>.value(
              _FakeSize_1(
                this,
                Invocation.method(#getSvgDimensions, [svgPath]),
              ),
            ),
          )
          as _i5.Future<_i2.Size>);

  @override
  void forceEndLocation(_i2.Offset? location) => super.noSuchMethod(
    Invocation.method(#forceEndLocation, [location]),
    returnValueForMissingStub: null,
  );

  @override
  void addListener(_i2.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#addListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void removeListener(_i2.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#removeListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );

  @override
  void notifyListeners() => super.noSuchMethod(
    Invocation.method(#notifyListeners, []),
    returnValueForMissingStub: null,
  );
}
