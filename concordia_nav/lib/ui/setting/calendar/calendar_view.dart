// Copyright (c) 2021 Simform Solutions
// This code uses the calendar_view library, which is licensed under the MIT License.
// See LICENSE file for details.

import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:provider/provider.dart';
import '../../../data/domain-model/concordia_floor.dart';
import '../../../data/domain-model/concordia_room.dart';
import '../../../data/domain-model/room_category.dart';
import '../../../data/repositories/calendar.dart';
import '../../../utils/building_viewmodel.dart';
import '../../../utils/calendar_viewmodel.dart';
import '../../../utils/event_controller_ex.dart';
import '../../../utils/indoor_directions_viewmodel.dart';
import '../../../widgets/custom_appbar.dart';

import 'dart:developer' as dev;

class CalendarView extends StatefulWidget {
  final UserCalendar? selectedCalendar;
  final CalendarViewModel? calendarViewModel;
  const CalendarView(
      {super.key, this.selectedCalendar, this.calendarViewModel});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final EventController eventController = EventController();
  late CalendarViewModel _calendarViewModel;
  late IndoorDirectionsViewModel _indoorDirectionsViewModel;
  late BuildingViewModel _buildingViewModel;

  UserCalendarEvent? _selectedEvent;
  bool _floorPlanExists = false;
  bool _checkingFloorPlan = false;

  @override
  void initState() {
    super.initState();
    dev.log(
        'CalendarView: widget.selectedCalendar: ${widget.selectedCalendar?.displayName ?? "null"}');
    _calendarViewModel = widget.calendarViewModel ?? CalendarViewModel();
    _indoorDirectionsViewModel = IndoorDirectionsViewModel();
    _buildingViewModel = BuildingViewModel();
    _initialize();
  }

  Future<void> _initialize() async {
    // Pass the selectedCalendar to the view model
    await _calendarViewModel.initialize(
        selectedCalendar: widget.selectedCalendar);
    _updateEventController();
  }

  void _updateEventController() {
    // Clear existing events
    eventController.clearAll();

    // Add events from the view model
    final events = _calendarViewModel.getCalendarEventData();
    eventController.addAll(events);
  }

  Future<void> _showEventBottomDrawer(UserCalendarEvent event) async {
    // Set selected event first
    setState(() {
      _selectedEvent = event;
      _checkingFloorPlan = true;
      _floorPlanExists = false; // Reset initially
    });

    // Start checking if floor plan exists asynchronously
    bool floorPlanExists = false;
    if (event.locationField != null) {
      floorPlanExists = await _indoorDirectionsViewModel
          .areDirectionsAvailableForLocation(event.locationField);
    }

    // Update state before showing the bottom sheet
    if (mounted) {
      setState(() {
        _floorPlanExists = floorPlanExists;
        _checkingFloorPlan = false;
      });
    }

    // Now show bottom sheet with the updated state
    if (mounted) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => _buildEventDetailsDrawer(),
      ).then((_) {
        // When the bottom sheet is closed, clear the selection
        setState(() {
          _selectedEvent = null;
        });
      });
    }
  }

  /// Navigates to the appropriate directions view.
  void _navigateToDirections() {
    if (_selectedEvent?.locationField == null) return;

    final locationField = _selectedEvent!.locationField!;
    // Ex. take "MB S2.330" which is one of the rooms provided to the users
    // under "Location Format Guide".
    // We'll parse out building code = "MB", floor = "S2", room = "330"

    // Parse the building/floor/room from the event location
    final parsed = _parseCalendarLocation(locationField);

    final buildingCode = parsed['buildingCode'];
    if (buildingCode == null) return;

    // Lookup the building from the code
    final building = _buildingViewModel.getBuildingByAbbreviation(buildingCode);
    if (building == null) {
      dev.log("Could not find building for code: $buildingCode");
      return;
    }

    dev.log('Navigating to directions for $locationField');

    if (_floorPlanExists) {
      // Given an indoor floor plan...
      final floorNumber = parsed['floor'] ?? '1';
      final roomNumber = parsed['room'] ?? '0001';

      // Initialize Class objects that map to the domain model
      final floor = ConcordiaFloor(floorNumber, building);
      final room = ConcordiaRoom(
        roomNumber,
        RoomCategory.classroom, // Assume the user's schedule only involves
        // classrooms, at least for the current point in time of the project.
        floor,
        null,
      );
      Navigator.pushNamed(
        context,
        '/NextClassDirectionsPreview',
        arguments: [room],
      );
    } else {
      // Navigate to outdoor map
      Navigator.pushNamed(
        context,
        '/OutdoorLocationMapView',
        arguments: {
          'campus': building.campus,
          'building': building,
        },
      );
    }
  }

  /// Parses a string following our convention, like "MB S2.330", into:
  /// buildingCode = "MB", floor = "S2", room = "330"
  Map<String, String> _parseCalendarLocation(String locationField) {
    // Again, same format that's used in "Location Format Guide" is: "MB S2.330"
    // We'll split on space -> ["MB", "S2.330"]
    // Then split the second token on '.' -> ["S2", "330"]
    // This assumed that the format is never incorrect, given the "Location
    // Format Guide" section that's presented to the user

    String buildingCode = '';
    String floorCode = '1';
    String roomNumber = '';

    final tokens = locationField.trim().split(' ');
    if (tokens.isEmpty) {
      return {
        'buildingCode': buildingCode,
        'floor': floorCode,
        'room': roomNumber,
      };
    }

    // The first token is the building code, e.g. "MB"
    buildingCode = tokens[0];

    // The second token (if any) is "S2.330"
    if (tokens.length > 1) {
      final floorRoom = tokens[1];
      final subTokens = floorRoom.split('.');
      if (subTokens.length == 2) {
        floorCode = subTokens[0]; // "S2"
        roomNumber = subTokens[1]; // "330"
      }
    }

    return {
      'buildingCode': buildingCode,
      'floor': floorCode,
      'room': roomNumber,
    };
  }

  Widget _buildEventDetailsDrawer() {
    // Calculate the height as a percentage of screen height
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomSheetHeight = screenHeight * 0.26;

    // Get building information early to use it for button state
    final building = _selectedEvent?.locationField != null
        ? _buildingViewModel
            .getBuildingFromLocation(_selectedEvent!.locationField!)
        : null;

    return Container(
      height: bottomSheetHeight,
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle indicator
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Header with title and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Event title
              Expanded(
                child: Text(
                  _selectedEvent?.title ?? 'No Title',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Event time and direction button row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column with time and location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _calendarViewModel.formatEventTime(_selectedEvent),
                            style: Theme.of(context).textTheme.bodyLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Event location if available
                    if (_selectedEvent?.locationField != null)
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedEvent!.locationField!,
                              style: Theme.of(context).textTheme.bodyLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Direction button with states: loading, enabled, disabled
              if (_checkingFloorPlan)
                // Loading state
                const SizedBox(
                  height: 36,
                  width: 36,
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: CircularProgressIndicator(color: Color(0xFF962e42)),
                  ),
                )
              else if (_selectedEvent?.locationField == null ||
                  building == null)
                // No location or building - disabled button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  icon: const Icon(Icons.directions, color: Colors.white),
                  label: const Text('Not Available',
                      style: TextStyle(color: Colors.white)),
                  onPressed: null, // Disabled button
                )
              else
                // Enabled button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  icon: const Icon(Icons.directions, color: Colors.white),
                  label: const Text('Directions',
                      style: TextStyle(color: Colors.white)),
                  onPressed: _navigateToDirections,
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _calendarViewModel,
      child: Consumer<CalendarViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: customAppBar(context, 'Calendar'),
            body: Semantics(
              label: 'View the selected Calendar details.',
              child: Column(
                children: [
                  // Loading indicator or error message
                  if (viewModel.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child:
                          CircularProgressIndicator(color: Color(0xFF962e42)),
                    ),

                  if (viewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  // Calendar week view
                  Expanded(
                    child: DayView(
                      controller: eventController,
                      eventTileBuilder: _eventTileBuilder,
                      showVerticalLine: true,
                      minDay: DateTime.now(),
                      maxDay: DateTime.now().add(const Duration(days: 7)),
                      initialDay: DateTime.now(),
                      heightPerMinute: 1,
                      eventArranger: const SideEventArranger(),
                      startHour: 5,
                      endHour: 22,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _eventTileBuilder(
    DateTime date,
    List<CalendarEventData> events,
    Rect boundry,
    DateTime start,
    DateTime end,
  ) {
    if (events.isEmpty) return Container();

    // Extract the original UserCalendarEvent
    final UserCalendarEvent? userEvent =
        events.first.event as UserCalendarEvent?;

    return GestureDetector(
      onTap: () async {
        if (userEvent != null) {
          await _showEventBottomDrawer(userEvent);
        }
      },
      child: Container(
        width: boundry.width,
        height: boundry.height,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                events.first.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (userEvent?.locationField != null && boundry.height > 30)
                Text(
                  userEvent!.locationField!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
