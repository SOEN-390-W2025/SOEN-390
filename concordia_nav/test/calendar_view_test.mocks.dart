// Mocks generated by Mockito 5.4.5 from annotations
// in concordia_nav/test/calendar_view_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:concordia_nav/data/repositories/calendar.dart' as _i3;
import 'package:device_calendar/device_calendar.dart' as _i2;
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

class _FakeDeviceCalendarPlugin_0 extends _i1.SmartFake
    implements _i2.DeviceCalendarPlugin {
  _FakeDeviceCalendarPlugin_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [CalendarRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockCalendarRepository extends _i1.Mock
    implements _i3.CalendarRepository {
  MockCalendarRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.DeviceCalendarPlugin get plugin =>
      (super.noSuchMethod(
            Invocation.getter(#plugin),
            returnValue: _FakeDeviceCalendarPlugin_0(
              this,
              Invocation.getter(#plugin),
            ),
          )
          as _i2.DeviceCalendarPlugin);

  @override
  set plugin(_i2.DeviceCalendarPlugin? _plugin) => super.noSuchMethod(
    Invocation.setter(#plugin, _plugin),
    returnValueForMissingStub: null,
  );

  @override
  _i4.Future<bool> checkPermissions() =>
      (super.noSuchMethod(
            Invocation.method(#checkPermissions, []),
            returnValue: _i4.Future<bool>.value(false),
          )
          as _i4.Future<bool>);

  @override
  _i4.Future<List<_i3.UserCalendar>> getUserCalendars() =>
      (super.noSuchMethod(
            Invocation.method(#getUserCalendars, []),
            returnValue: _i4.Future<List<_i3.UserCalendar>>.value(
              <_i3.UserCalendar>[],
            ),
          )
          as _i4.Future<List<_i3.UserCalendar>>);

  @override
  _i4.Future<List<_i3.UserCalendarEvent>> getEvents(
    List<_i3.UserCalendar>? selectedCalendars,
    Duration? timeSpan,
    DateTime? utcStart,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#getEvents, [
              selectedCalendars,
              timeSpan,
              utcStart,
            ]),
            returnValue: _i4.Future<List<_i3.UserCalendarEvent>>.value(
              <_i3.UserCalendarEvent>[],
            ),
          )
          as _i4.Future<List<_i3.UserCalendarEvent>>);

  @override
  _i4.Future<List<_i3.UserCalendarEvent>> getEventsOnLocalDate(
    List<_i3.UserCalendar>? selectedCalendars,
    int? offset,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#getEventsOnLocalDate, [
              selectedCalendars,
              offset,
            ]),
            returnValue: _i4.Future<List<_i3.UserCalendarEvent>>.value(
              <_i3.UserCalendarEvent>[],
            ),
          )
          as _i4.Future<List<_i3.UserCalendarEvent>>);
}
