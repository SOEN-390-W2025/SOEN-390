// Mocks generated by Mockito 5.4.5 from annotations
// in concordia_nav/test/indoor_map/indoor_step_view_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i8;
import 'dart:ui' as _i5;

import 'package:concordia_nav/data/domain-model/concordia_floor_point.dart'
    as _i11;
import 'package:concordia_nav/data/domain-model/indoor_route.dart' as _i10;
import 'package:concordia_nav/utils/building_viewmodel.dart' as _i3;
import 'package:concordia_nav/utils/indoor_directions_viewmodel.dart' as _i2;
import 'package:concordia_nav/utils/indoor_map_viewmodel.dart' as _i4;
import 'package:concordia_nav/utils/indoor_step_viewmodel.dart' as _i6;
import 'package:flutter/material.dart' as _i9;
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

class _FakeIndoorDirectionsViewModel_0 extends _i1.SmartFake
    implements _i2.IndoorDirectionsViewModel {
  _FakeIndoorDirectionsViewModel_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeBuildingViewModel_1 extends _i1.SmartFake
    implements _i3.BuildingViewModel {
  _FakeBuildingViewModel_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeIndoorMapViewModel_2 extends _i1.SmartFake
    implements _i4.IndoorMapViewModel {
  _FakeIndoorMapViewModel_2(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeOffset_3 extends _i1.SmartFake implements _i5.Offset {
  _FakeOffset_3(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeSize_4 extends _i1.SmartFake implements _i5.Size {
  _FakeSize_4(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [VirtualStepGuideViewModel].
///
/// See the documentation for Mockito's code generation for more information.
class MockVirtualStepGuideViewModel extends _i1.Mock
    implements _i6.VirtualStepGuideViewModel {
  MockVirtualStepGuideViewModel() {
    _i1.throwOnMissingStub(this);
  }

  @override
  double get maxScale =>
      (super.noSuchMethod(Invocation.getter(#maxScale), returnValue: 0.0)
          as double);

  @override
  double get minScale =>
      (super.noSuchMethod(Invocation.getter(#minScale), returnValue: 0.0)
          as double);

  @override
  String get sourceRoom =>
      (super.noSuchMethod(
            Invocation.getter(#sourceRoom),
            returnValue: _i7.dummyValue<String>(
              this,
              Invocation.getter(#sourceRoom),
            ),
          )
          as String);

  @override
  String get building =>
      (super.noSuchMethod(
            Invocation.getter(#building),
            returnValue: _i7.dummyValue<String>(
              this,
              Invocation.getter(#building),
            ),
          )
          as String);

  @override
  String get floor =>
      (super.noSuchMethod(
            Invocation.getter(#floor),
            returnValue: _i7.dummyValue<String>(
              this,
              Invocation.getter(#floor),
            ),
          )
          as String);

  @override
  String get endRoom =>
      (super.noSuchMethod(
            Invocation.getter(#endRoom),
            returnValue: _i7.dummyValue<String>(
              this,
              Invocation.getter(#endRoom),
            ),
          )
          as String);

  @override
  bool get disability =>
      (super.noSuchMethod(Invocation.getter(#disability), returnValue: false)
          as bool);

  @override
  set disability(bool? _disability) => super.noSuchMethod(
    Invocation.setter(#disability, _disability),
    returnValueForMissingStub: null,
  );

  @override
  _i2.IndoorDirectionsViewModel get directionsViewModel =>
      (super.noSuchMethod(
            Invocation.getter(#directionsViewModel),
            returnValue: _FakeIndoorDirectionsViewModel_0(
              this,
              Invocation.getter(#directionsViewModel),
            ),
          )
          as _i2.IndoorDirectionsViewModel);

  @override
  _i3.BuildingViewModel get buildingViewModel =>
      (super.noSuchMethod(
            Invocation.getter(#buildingViewModel),
            returnValue: _FakeBuildingViewModel_1(
              this,
              Invocation.getter(#buildingViewModel),
            ),
          )
          as _i3.BuildingViewModel);

  @override
  _i4.IndoorMapViewModel get indoorMapViewModel =>
      (super.noSuchMethod(
            Invocation.getter(#indoorMapViewModel),
            returnValue: _FakeIndoorMapViewModel_2(
              this,
              Invocation.getter(#indoorMapViewModel),
            ),
          )
          as _i4.IndoorMapViewModel);

  @override
  bool get isLoading =>
      (super.noSuchMethod(Invocation.getter(#isLoading), returnValue: false)
          as bool);

  @override
  set isLoading(bool? _isLoading) => super.noSuchMethod(
    Invocation.setter(#isLoading, _isLoading),
    returnValueForMissingStub: null,
  );

  @override
  int get currentStepIndex =>
      (super.noSuchMethod(Invocation.getter(#currentStepIndex), returnValue: 0)
          as int);

  @override
  set currentStepIndex(int? _currentStepIndex) => super.noSuchMethod(
    Invocation.setter(#currentStepIndex, _currentStepIndex),
    returnValueForMissingStub: null,
  );

  @override
  List<_i6.NavigationStep> get navigationSteps =>
      (super.noSuchMethod(
            Invocation.getter(#navigationSteps),
            returnValue: <_i6.NavigationStep>[],
          )
          as List<_i6.NavigationStep>);

  @override
  set navigationSteps(List<_i6.NavigationStep>? _navigationSteps) =>
      super.noSuchMethod(
        Invocation.setter(#navigationSteps, _navigationSteps),
        returnValueForMissingStub: null,
      );

  @override
  double get width =>
      (super.noSuchMethod(Invocation.getter(#width), returnValue: 0.0)
          as double);

  @override
  set width(double? _width) => super.noSuchMethod(
    Invocation.setter(#width, _width),
    returnValueForMissingStub: null,
  );

  @override
  double get height =>
      (super.noSuchMethod(Invocation.getter(#height), returnValue: 0.0)
          as double);

  @override
  set height(double? _height) => super.noSuchMethod(
    Invocation.setter(#height, _height),
    returnValueForMissingStub: null,
  );

  @override
  List<double> get stepDistanceMeters =>
      (super.noSuchMethod(
            Invocation.getter(#stepDistanceMeters),
            returnValue: <double>[],
          )
          as List<double>);

  @override
  set stepDistanceMeters(List<double>? _stepDistanceMeters) =>
      super.noSuchMethod(
        Invocation.setter(#stepDistanceMeters, _stepDistanceMeters),
        returnValueForMissingStub: null,
      );

  @override
  List<int> get stepTimeSeconds =>
      (super.noSuchMethod(
            Invocation.getter(#stepTimeSeconds),
            returnValue: <int>[],
          )
          as List<int>);

  @override
  set stepTimeSeconds(List<int>? _stepTimeSeconds) => super.noSuchMethod(
    Invocation.setter(#stepTimeSeconds, _stepTimeSeconds),
    returnValueForMissingStub: null,
  );

  @override
  String get buildingAbbreviation =>
      (super.noSuchMethod(
            Invocation.getter(#buildingAbbreviation),
            returnValue: _i7.dummyValue<String>(
              this,
              Invocation.getter(#buildingAbbreviation),
            ),
          )
          as String);

  @override
  set buildingAbbreviation(String? _buildingAbbreviation) => super.noSuchMethod(
    Invocation.setter(#buildingAbbreviation, _buildingAbbreviation),
    returnValueForMissingStub: null,
  );

  @override
  String get floorPlanPath =>
      (super.noSuchMethod(
            Invocation.getter(#floorPlanPath),
            returnValue: _i7.dummyValue<String>(
              this,
              Invocation.getter(#floorPlanPath),
            ),
          )
          as String);

  @override
  set floorPlanPath(String? _floorPlanPath) => super.noSuchMethod(
    Invocation.setter(#floorPlanPath, _floorPlanPath),
    returnValueForMissingStub: null,
  );

  @override
  bool get hasListeners =>
      (super.noSuchMethod(Invocation.getter(#hasListeners), returnValue: false)
          as bool);

  @override
  _i8.Future<void> initializeRoute() =>
      (super.noSuchMethod(
            Invocation.method(#initializeRoute, []),
            returnValue: _i8.Future<void>.value(),
            returnValueForMissingStub: _i8.Future<void>.value(),
          )
          as _i8.Future<void>);

  @override
  void focusOnCurrentStep(_i9.BuildContext? context) => super.noSuchMethod(
    Invocation.method(#focusOnCurrentStep, [context]),
    returnValueForMissingStub: null,
  );

  @override
  void nextStep(_i9.BuildContext? context) => super.noSuchMethod(
    Invocation.method(#nextStep, [context]),
    returnValueForMissingStub: null,
  );

  @override
  void previousStep(_i9.BuildContext? context) => super.noSuchMethod(
    Invocation.method(#previousStep, [context]),
    returnValueForMissingStub: null,
  );

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );

  @override
  void addConnectionStep(_i10.IndoorRoute? route) => super.noSuchMethod(
    Invocation.method(#addConnectionStep, [route]),
    returnValueForMissingStub: null,
  );

  @override
  void calculateTimeAndDistanceEstimates() => super.noSuchMethod(
    Invocation.method(#calculateTimeAndDistanceEstimates, []),
    returnValueForMissingStub: null,
  );

  @override
  String getCurrentStepTimeEstimate() =>
      (super.noSuchMethod(
            Invocation.method(#getCurrentStepTimeEstimate, []),
            returnValue: _i7.dummyValue<String>(
              this,
              Invocation.method(#getCurrentStepTimeEstimate, []),
            ),
          )
          as String);

  @override
  String getCurrentStepDistanceEstimate() =>
      (super.noSuchMethod(
            Invocation.method(#getCurrentStepDistanceEstimate, []),
            returnValue: _i7.dummyValue<String>(
              this,
              Invocation.method(#getCurrentStepDistanceEstimate, []),
            ),
          )
          as String);

  @override
  String getRemainingTimeEstimate() =>
      (super.noSuchMethod(
            Invocation.method(#getRemainingTimeEstimate, []),
            returnValue: _i7.dummyValue<String>(
              this,
              Invocation.method(#getRemainingTimeEstimate, []),
            ),
          )
          as String);

  @override
  String getRemainingDistanceEstimate() =>
      (super.noSuchMethod(
            Invocation.method(#getRemainingDistanceEstimate, []),
            returnValue: _i7.dummyValue<String>(
              this,
              Invocation.method(#getRemainingDistanceEstimate, []),
            ),
          )
          as String);

  @override
  void addListener(_i5.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#addListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void removeListener(_i5.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#removeListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void notifyListeners() => super.noSuchMethod(
    Invocation.method(#notifyListeners, []),
    returnValueForMissingStub: null,
  );
}

/// A class which mocks [IndoorDirectionsViewModel].
///
/// See the documentation for Mockito's code generation for more information.
class MockIndoorDirectionsViewModel extends _i1.Mock
    implements _i2.IndoorDirectionsViewModel {
  MockIndoorDirectionsViewModel() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get eta =>
      (super.noSuchMethod(
            Invocation.getter(#eta),
            returnValue: _i7.dummyValue<String>(this, Invocation.getter(#eta)),
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
            returnValue: _i7.dummyValue<String>(
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
  bool get isAccessibilityMode =>
      (super.noSuchMethod(
            Invocation.getter(#isAccessibilityMode),
            returnValue: false,
          )
          as bool);

  @override
  _i5.Offset get startLocation =>
      (super.noSuchMethod(
            Invocation.getter(#startLocation),
            returnValue: _FakeOffset_3(this, Invocation.getter(#startLocation)),
          )
          as _i5.Offset);

  @override
  _i5.Offset get endLocation =>
      (super.noSuchMethod(
            Invocation.getter(#endLocation),
            returnValue: _FakeOffset_3(this, Invocation.getter(#endLocation)),
          )
          as _i5.Offset);

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
  _i8.Future<_i11.ConcordiaFloorPoint?> getPositionPoint(
    String? buildingName,
    String? floor,
    String? room,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#getPositionPoint, [buildingName, floor, room]),
            returnValue: _i8.Future<_i11.ConcordiaFloorPoint?>.value(),
          )
          as _i8.Future<_i11.ConcordiaFloorPoint?>);

  @override
  _i8.Future<_i11.ConcordiaFloorPoint?> getStartPoint(
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
            returnValue: _i8.Future<_i11.ConcordiaFloorPoint?>.value(),
          )
          as _i8.Future<_i11.ConcordiaFloorPoint?>);

  @override
  _i8.Future<void> calculateRoute(
    String? building,
    String? floor,
    String? sourceRoom,
    String? endRoom,
    bool? disability,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#calculateRoute, [
              building,
              floor,
              sourceRoom,
              endRoom,
              disability,
            ]),
            returnValue: _i8.Future<void>.value(),
            returnValueForMissingStub: _i8.Future<void>.value(),
          )
          as _i8.Future<void>);

  @override
  _i8.Future<_i5.Size> getSvgDimensions(String? svgPath) =>
      (super.noSuchMethod(
            Invocation.method(#getSvgDimensions, [svgPath]),
            returnValue: _i8.Future<_i5.Size>.value(
              _FakeSize_4(
                this,
                Invocation.method(#getSvgDimensions, [svgPath]),
              ),
            ),
          )
          as _i8.Future<_i5.Size>);

  @override
  void addListener(_i5.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#addListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void removeListener(_i5.VoidCallback? listener) => super.noSuchMethod(
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
