// Mocks generated by Mockito 5.4.5 from annotations
// in concordia_nav/test/poi/poi_mapview_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;
import 'dart:ui' as _i7;

import 'package:concordia_nav/data/domain-model/poi.dart' as _i5;
import 'package:concordia_nav/data/repositories/poi_repository.dart' as _i3;
import 'package:concordia_nav/utils/poi/poi_viewmodel.dart' as _i6;
import 'package:flutter/material.dart' as _i2;
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

class _FakeTextEditingController_0 extends _i1.SmartFake
    implements _i2.TextEditingController {
  _FakeTextEditingController_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [POIRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockPOIRepository extends _i1.Mock implements _i3.POIRepository {
  MockPOIRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<String>? Function(String) get loadString =>
      (super.noSuchMethod(
            Invocation.getter(#loadString),
            returnValue: (String path) => null,
          )
          as _i4.Future<String>? Function(String));

  @override
  _i4.Future<List<_i5.POIModel>> fetchPOIData() =>
      (super.noSuchMethod(
            Invocation.method(#fetchPOIData, []),
            returnValue: _i4.Future<List<_i5.POIModel>>.value(<_i5.POIModel>[]),
          )
          as _i4.Future<List<_i5.POIModel>>);
}

/// A class which mocks [POIViewModel].
///
/// See the documentation for Mockito's code generation for more information.
class MockPOIViewModel extends _i1.Mock implements _i6.POIViewModel {
  MockPOIViewModel() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.TextEditingController get searchController =>
      (super.noSuchMethod(
            Invocation.getter(#searchController),
            returnValue: _FakeTextEditingController_0(
              this,
              Invocation.getter(#searchController),
            ),
          )
          as _i2.TextEditingController);

  @override
  List<_i5.POIModel> get poiList =>
      (super.noSuchMethod(
            Invocation.getter(#poiList),
            returnValue: <_i5.POIModel>[],
          )
          as List<_i5.POIModel>);

  @override
  bool get isLoading =>
      (super.noSuchMethod(Invocation.getter(#isLoading), returnValue: false)
          as bool);

  @override
  bool get hasListeners =>
      (super.noSuchMethod(Invocation.getter(#hasListeners), returnValue: false)
          as bool);

  @override
  _i4.Future<void> loadPOIData() =>
      (super.noSuchMethod(
            Invocation.method(#loadPOIData, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );

  @override
  void addListener(_i7.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#addListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void removeListener(_i7.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#removeListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void notifyListeners() => super.noSuchMethod(
    Invocation.method(#notifyListeners, []),
    returnValueForMissingStub: null,
  );
}
