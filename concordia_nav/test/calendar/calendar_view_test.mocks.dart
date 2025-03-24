// Mocks generated by Mockito 5.4.5 from annotations
// in concordia_nav/test/calendar/calendar_view_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;
import 'dart:ui' as _i11;

import 'package:calendar_view/calendar_view.dart' as _i9;
import 'package:concordia_nav/data/domain-model/concordia_room.dart' as _i5;
import 'package:concordia_nav/data/repositories/calendar.dart' as _i3;
import 'package:concordia_nav/utils/building_viewmodel.dart' as _i6;
import 'package:concordia_nav/utils/calendar_selection_viewmodel.dart' as _i7;
import 'package:concordia_nav/utils/calendar_viewmodel.dart' as _i8;
import 'package:device_calendar/device_calendar.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i10;

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

  @override
  _i4.Future<_i3.UserCalendarEvent?> getNextClassEvent(
    List<_i3.UserCalendar>? selectedCalendars,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#getNextClassEvent, [selectedCalendars]),
            returnValue: _i4.Future<_i3.UserCalendarEvent?>.value(),
          )
          as _i4.Future<_i3.UserCalendarEvent?>);

  @override
  _i4.Future<_i5.ConcordiaRoom?> getNextClassRoom(
    List<_i3.UserCalendar>? selectedCalendars,
    _i6.BuildingViewModel? buildingViewModel,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#getNextClassRoom, [
              selectedCalendars,
              buildingViewModel,
            ]),
            returnValue: _i4.Future<_i5.ConcordiaRoom?>.value(),
          )
          as _i4.Future<_i5.ConcordiaRoom?>);
}

/// A class which mocks [CalendarSelectionViewModel].
///
/// See the documentation for Mockito's code generation for more information.
class MockCalendarSelectionViewModel extends _i1.Mock
    implements _i7.CalendarSelectionViewModel {
  MockCalendarSelectionViewModel() {
    _i1.throwOnMissingStub(this);
  }

  @override
  set calendarRepository(_i3.CalendarRepository? repo) => super.noSuchMethod(
    Invocation.setter(#calendarRepository, repo),
    returnValueForMissingStub: null,
  );

  @override
  List<_i3.UserCalendar> get calendars =>
      (super.noSuchMethod(
            Invocation.getter(#calendars),
            returnValue: <_i3.UserCalendar>[],
          )
          as List<_i3.UserCalendar>);

  @override
  _i4.Future<void> loadCalendars() =>
      (super.noSuchMethod(
            Invocation.method(#loadCalendars, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  bool isCalendarSelected(_i3.UserCalendar? calendar) =>
      (super.noSuchMethod(
            Invocation.method(#isCalendarSelected, [calendar]),
            returnValue: false,
          )
          as bool);

  @override
  void selectCalendar(_i3.UserCalendar? calendar) => super.noSuchMethod(
    Invocation.method(#selectCalendar, [calendar]),
    returnValueForMissingStub: null,
  );

  @override
  void unselectCalendar(_i3.UserCalendar? calendar) => super.noSuchMethod(
    Invocation.method(#unselectCalendar, [calendar]),
    returnValueForMissingStub: null,
  );

  @override
  void toggleCalendarSelection(_i3.UserCalendar? calendar) =>
      super.noSuchMethod(
        Invocation.method(#toggleCalendarSelection, [calendar]),
        returnValueForMissingStub: null,
      );

  @override
  List<_i3.UserCalendar> getSelectedCalendars() =>
      (super.noSuchMethod(
            Invocation.method(#getSelectedCalendars, []),
            returnValue: <_i3.UserCalendar>[],
          )
          as List<_i3.UserCalendar>);

  @override
  void selectCalendarsByDisplayName(String? displayName) => super.noSuchMethod(
    Invocation.method(#selectCalendarsByDisplayName, [displayName]),
    returnValueForMissingStub: null,
  );

  @override
  List<_i3.UserCalendar> getSelectedCalendarsByDisplayName(
    String? displayName,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#getSelectedCalendarsByDisplayName, [
              displayName,
            ]),
            returnValue: <_i3.UserCalendar>[],
          )
          as List<_i3.UserCalendar>);
}

/// A class which mocks [CalendarViewModel].
///
/// See the documentation for Mockito's code generation for more information.
class MockCalendarViewModel extends _i1.Mock implements _i8.CalendarViewModel {
  MockCalendarViewModel() {
    _i1.throwOnMissingStub(this);
  }

  @override
  List<_i3.UserCalendar> get allCalendars =>
      (super.noSuchMethod(
            Invocation.getter(#allCalendars),
            returnValue: <_i3.UserCalendar>[],
          )
          as List<_i3.UserCalendar>);

  @override
  List<_i3.UserCalendar> get selectedCalendars =>
      (super.noSuchMethod(
            Invocation.getter(#selectedCalendars),
            returnValue: <_i3.UserCalendar>[],
          )
          as List<_i3.UserCalendar>);

  @override
  List<_i3.UserCalendarEvent> get events =>
      (super.noSuchMethod(
            Invocation.getter(#events),
            returnValue: <_i3.UserCalendarEvent>[],
          )
          as List<_i3.UserCalendarEvent>);

  @override
  bool get isLoading =>
      (super.noSuchMethod(Invocation.getter(#isLoading), returnValue: false)
          as bool);

  @override
  set calendarRepository(_i3.CalendarRepository? repo) => super.noSuchMethod(
    Invocation.setter(#calendarRepository, repo),
    returnValueForMissingStub: null,
  );

  @override
  set eventsList(List<_i3.UserCalendarEvent>? events) => super.noSuchMethod(
    Invocation.setter(#eventsList, events),
    returnValueForMissingStub: null,
  );

  @override
  bool get hasListeners =>
      (super.noSuchMethod(Invocation.getter(#hasListeners), returnValue: false)
          as bool);

  @override
  _i4.Future<void> initialize({_i3.UserCalendar? selectedCalendar}) =>
      (super.noSuchMethod(
            Invocation.method(#initialize, [], {
              #selectedCalendar: selectedCalendar,
            }),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  List<_i9.CalendarEventData<Object?>> getCalendarEventData() =>
      (super.noSuchMethod(
            Invocation.method(#getCalendarEventData, []),
            returnValue: <_i9.CalendarEventData<Object?>>[],
          )
          as List<_i9.CalendarEventData<Object?>>);

  @override
  String formatEventTime(_i3.UserCalendarEvent? event) =>
      (super.noSuchMethod(
            Invocation.method(#formatEventTime, [event]),
            returnValue: _i10.dummyValue<String>(
              this,
              Invocation.method(#formatEventTime, [event]),
            ),
          )
          as String);

  @override
  String getBuildingAbbreviation(String? location) =>
      (super.noSuchMethod(
            Invocation.method(#getBuildingAbbreviation, [location]),
            returnValue: _i10.dummyValue<String>(
              this,
              Invocation.method(#getBuildingAbbreviation, [location]),
            ),
          )
          as String);

  @override
  void addListener(_i11.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#addListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void removeListener(_i11.VoidCallback? listener) => super.noSuchMethod(
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
