// Copyright (c) 2021 Simform Solutions
// This code uses the calendar_view library, which is licensed under the MIT License.
// See LICENSE file for details.

import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:provider/provider.dart';
import '../../../data/domain-model/concordia_building.dart';
import '../../../data/repositories/calendar.dart';
import '../../../utils/building_viewmodel.dart';
import '../../../utils/calendar_viewmodel.dart';
import '../../../utils/event_controller_ex.dart';
import '../../../utils/indoor_directions_viewmodel.dart';
import '../../../widgets/custom_appbar.dart';

import 'dart:developer' as dev;

class CalendarView extends StatefulWidget {
  final UserCalendar? selectedCalendar;
  const CalendarView({super.key, this.selectedCalendar});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final EventController eventController = EventController();
  late CalendarViewModel _calendarViewModel;
  late IndoorDirectionsViewModel _indoorDirectionsViewModel;
  late BuildingViewModel _buildingViewModel;

  UserCalendarEvent? _selectedEvent;
  String building = '';
  bool _floorPlanExists = false;
  bool _checkingFloorPlan = false;
  
  @override
  void initState() {
    super.initState();
    dev.log('CalendarView: widget.selectedCalendar: ${widget.selectedCalendar?.displayName ?? "null"}');
    _calendarViewModel = CalendarViewModel();
    _indoorDirectionsViewModel = IndoorDirectionsViewModel();
    _buildingViewModel = BuildingViewModel();
    _initialize();
  }
  
  Future<void> _initialize() async {
    // Pass the selectedCalendar to the view model
    await _calendarViewModel.initialize(selectedCalendar: widget.selectedCalendar);
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
    final String floorPlanPath = 'assets/maps/indoor/floorplans/${_getFloorPlanName(event.locationField!)}.svg';
    floorPlanExists = await _indoorDirectionsViewModel.checkFloorPlanExists(floorPlanPath);
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

  Widget _buildEventDetailsDrawer() {
    // Calculate the height as a percentage of screen height
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomSheetHeight = screenHeight * 0.22;
    
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
                            _formatEventTime(_selectedEvent),
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
              // Direction button with three states: loading, enabled, disabled
              if (_checkingFloorPlan)
                // Loading state
                const SizedBox(
                  height: 36,
                  width: 36,
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_selectedEvent?.locationField == null)
                // No location state - disabled button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  icon: const Icon(Icons.directions, color: Colors.white),
                  label: const Text('Not Available', style: TextStyle(color: Colors.white)),
                  onPressed: null, // No location, so button is disabled
                )
              else
                // Normal state - enabled or disabled based on floor plan existence
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _floorPlanExists 
                      ? Theme.of(context).primaryColor 
                      : Colors.grey,
                  ),
                  icon: const Icon(Icons.directions, color: Colors.white),
                  label: const Text('Direction', style: TextStyle(color: Colors.white)),
                  onPressed: _floorPlanExists
                    ? () {
                        final building = _building(_selectedEvent!.locationField!);
                        Navigator.pushNamed(
                          context,
                          '/IndoorDirectionsView',
                          arguments:{
                            'building': building?.name,
                            'sourceRoom': 'Your Location',
                            'endRoom': _selectedEvent?.locationField,
                          }
                        );
                      }
                    : null, // Button is disabled when floor plan doesn't exist
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
            body: Column(
              children: [
                // Loading indicator or error message
                if (viewModel.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
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
    final UserCalendarEvent? userEvent = events.first.event as UserCalendarEvent?;

    return GestureDetector(
      onTap: () {
        if (userEvent != null) {
          _showEventBottomDrawer(userEvent);
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

  // Helper functions
  String _formatEventTime(UserCalendarEvent? event) {
    if (event == null) return 'No time specified';

    final startTime = event.localStart;
    final endTime = event.localEnd;

    final startFormat = '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';
    final endFormat = '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}';

    return '$startFormat - $endFormat';
  }

  String _getFloorPlanName(String name) {
    // Split the string by spaces
    final List<String> parts = name.split(" ");
    if (parts.length < 2) {
      return name; // Return original if no space found
    }
    
    building = parts[0];
    final String roomNumber = parts[1];
    
    // Check if roomNumber starts with a letter
    if (roomNumber.isNotEmpty && RegExp(r'[A-Za-z]').hasMatch(roomNumber[0])) {
      // If roomNumber starts with a letter, return building + first two characters
      if (roomNumber.length > 1) {
        return building + roomNumber[0] + roomNumber[1];
      } else {
        return building + roomNumber[0];
      }
    } else {
      // For regular cases, return building + first character of roomNumber
      if (roomNumber.isNotEmpty) {
        return building + roomNumber[0];
      }
    }
    
    return building; // Fallback if roomNumber is empty
  }


  ConcordiaBuilding? _building(String name) {
    // Split the string by spaces
    final List<String> parts = name.split(" ");

    building = parts[0];

    return _buildingViewModel.getBuildingByAbbreviation(building);
  }
}