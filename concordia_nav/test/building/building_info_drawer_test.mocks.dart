// Mocks generated by Mockito 5.4.5 from annotations
// in concordia_nav/test/building/building_info_drawer_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i4;

import 'package:concordia_nav/utils/building_drawer_viewmodel.dart' as _i3;
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

class _FakeAnimation_0<T> extends _i1.SmartFake implements _i2.Animation<T> {
  _FakeAnimation_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [BuildingInfoDrawerViewModel].
///
/// See the documentation for Mockito's code generation for more information.
class MockBuildingInfoDrawerViewModel extends _i1.Mock
    implements _i3.BuildingInfoDrawerViewModel {
  MockBuildingInfoDrawerViewModel() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Animation<_i4.Offset> get slideAnimation =>
      (super.noSuchMethod(
            Invocation.getter(#slideAnimation),
            returnValue: _FakeAnimation_0<_i4.Offset>(
              this,
              Invocation.getter(#slideAnimation),
            ),
          )
          as _i2.Animation<_i4.Offset>);

  @override
  bool get hasListeners =>
      (super.noSuchMethod(Invocation.getter(#hasListeners), returnValue: false)
          as bool);

  @override
  void initializeAnimation(_i2.TickerProvider? vsync) => super.noSuchMethod(
    Invocation.method(#initializeAnimation, [vsync]),
    returnValueForMissingStub: null,
  );

  @override
  void closeDrawer(_i4.VoidCallback? onClose) => super.noSuchMethod(
    Invocation.method(#closeDrawer, [onClose]),
    returnValueForMissingStub: null,
  );

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );

  @override
  void addListener(_i4.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#addListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void removeListener(_i4.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#removeListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void notifyListeners() => super.noSuchMethod(
    Invocation.method(#notifyListeners, []),
    returnValueForMissingStub: null,
  );
}
