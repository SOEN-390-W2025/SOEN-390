// Mocks generated by Mockito 5.4.5 from annotations
// in concordia_nav/test/map/map_viewmodel_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:concordia_nav/data/domain-model/concordia_campus.dart' as _i4;
import 'package:concordia_nav/data/repositories/map_repository.dart' as _i3;
import 'package:concordia_nav/data/services/map_service.dart' as _i5;
import 'package:google_maps_flutter/google_maps_flutter.dart' as _i2;
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

class _FakeCameraPosition_0 extends _i1.SmartFake
    implements _i2.CameraPosition {
  _FakeCameraPosition_0(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

/// A class which mocks [MapRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockMapRepository extends _i1.Mock implements _i3.MapRepository {
  MockMapRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.CameraPosition getCameraPosition(_i4.ConcordiaCampus? campus) =>
      (super.noSuchMethod(
        Invocation.method(#getCameraPosition, [campus]),
        returnValue: _FakeCameraPosition_0(
          this,
          Invocation.method(#getCameraPosition, [campus]),
        ),
      ) as _i2.CameraPosition);
}

/// A class which mocks [MapService].
///
/// See the documentation for Mockito's code generation for more information.
class MockMapService extends _i1.Mock implements _i5.MapService {
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
  _i2.CameraPosition getInitialCameraPosition(_i4.ConcordiaCampus? campus) =>
      (super.noSuchMethod(
        Invocation.method(#getInitialCameraPosition, [campus]),
        returnValue: _FakeCameraPosition_0(
          this,
          Invocation.method(#getInitialCameraPosition, [campus]),
        ),
      ) as _i2.CameraPosition);

  @override
  void moveCamera(_i2.LatLng? position, {double? zoom = 17.0}) =>
      super.noSuchMethod(
        Invocation.method(#moveCamera, [position], {#zoom: zoom}),
        returnValueForMissingStub: null,
      );

  @override
  Set<_i2.Marker> getCampusMarkers(List<_i2.LatLng>? buildingLocations) =>
      (super.noSuchMethod(
        Invocation.method(#getCampusMarkers, [buildingLocations]),
        returnValue: <_i2.Marker>{},
      ) as Set<_i2.Marker>);
}
