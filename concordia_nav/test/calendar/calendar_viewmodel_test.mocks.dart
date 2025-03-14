import 'package:mockito/mockito.dart' as _i1;
import 'package:concordia_nav/utils/calendar_selection_viewmodel.dart' as _i2;
import 'package:concordia_nav/data/repositories/calendar.dart' as _i3;
import 'dart:async' as _i4;

/// A class which mocks [CalendarSelectionViewmodel].
///
/// See the documentation for Mockito's code generation for more information.

class MockCalendarSelectionViewModel extends _i1.Mock
    implements _i2.CalendarSelectionViewModel {

  MockCalendarSelectionViewModel() {
    _i1.throwOnMissingStub(this);
  }    

  @override
  List<_i3.UserCalendar> get calendars => 
    (super.noSuchMethod(
        Invocation.getter(#calendars),
        returnValue: <_i3.UserCalendar>[],
      ) as List<_i3.UserCalendar>);

  @override
  _i4.Future<void> loadCalendars() => 
    (super.noSuchMethod(
        Invocation.method(#loadCalendars, []),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  bool isCalendarSelected(_i3.UserCalendar calendar) => 
    (super.noSuchMethod(
        Invocation.method(#isCalendarSelected, [calendar]),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  void selectCalendar(_i3.UserCalendar calendar) => 
    (super.noSuchMethod(
        Invocation.method(#selectCalendar, [calendar]),
        returnValue: null,
        returnValueForMissingStub: null,
      ));

  @override
  void unselectCalendar(_i3.UserCalendar calendar) => 
    (super.noSuchMethod(
        Invocation.method(#unselectCalendar, [calendar]),
        returnValue: null,
        returnValueForMissingStub: null,
      ));

  @override
  void toggleCalendarSelection(_i3.UserCalendar calendar) => 
    (super.noSuchMethod(
        Invocation.method(#toggleCalendarSelection, [calendar]),
        returnValue: null,
        returnValueForMissingStub: null,
      ));

  @override
  List<_i3.UserCalendar> getSelectedCalendars() =>
    (super.noSuchMethod(
        Invocation.method(#getSelectedCalendars, []),
        returnValue: <_i3.UserCalendar>[],
        returnValueForMissingStub: <_i3.UserCalendar>[],
      ) as List<_i3.UserCalendar>);

  @override
  void selectCalendarsByDisplayName(String calendar) => 
    (super.noSuchMethod(
        Invocation.method(#selectCalendarsByDisplayName, [calendar]),
        returnValue: null,
        returnValueForMissingStub: null,
      ));

  @override
  List<_i3.UserCalendar> getSelectedCalendarsByDisplayName(String displayName) =>
    (super.noSuchMethod(
        Invocation.method(#getSelectedCalendarsByDisplayName, [displayName]),
        returnValue: <_i3.UserCalendar>[],
        returnValueForMissingStub: <_i3.UserCalendar>[],
      ) as List<_i3.UserCalendar>);
}