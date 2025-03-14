// ignore_for_file: avoid_catches_without_on_clauses

import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import '../../../data/repositories/calendar.dart';
import '../../../utils/calendar_selection_viewmodel.dart';
import '../../../widgets/custom_appbar.dart';

/// A view that allows users to select from available calendars.
/// Displays a list of all user calendars with a location format guide at the bottom.
class CalendarSelectionView extends StatefulWidget {
  final CalendarSelectionViewModel? calendarViewModel;
  const CalendarSelectionView({super.key, this.calendarViewModel});

  @override
  State<CalendarSelectionView> createState() => _CalendarSelectionViewState();
}

class _CalendarSelectionViewState extends State<CalendarSelectionView> {
  late CalendarSelectionViewModel _calendarViewModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calendarViewModel = widget.calendarViewModel ?? CalendarSelectionViewModel();
    _loadCalendars();
  }

  /// Loads available calendars from the device.
  /// Shows an error message if permissions are not granted.
  Future<void> _loadCalendars() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _calendarViewModel.loadCalendars();
    } catch (e) {
      dev.log('Error loading calendars: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load calendars. Please check permissions.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Calendar Selection'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  /// Builds the main content of the screen.
  /// Includes the header, scrollable calendar list, and location guide.
  Widget _buildContent() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          _buildHeader(),
          
          // Calendar list - takes available space and scrolls if needed
          Expanded(
            child: _buildCalendarList(),
          ),
          
          // Location guide - fixed at bottom
          _buildLocationGuide(),
        ],
      ),
    );
  }

  /// Builds the header section with title text.
  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Select a calendar category',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the scrollable list of calendars.
  /// Shows a message if no calendars are found.
  Widget _buildCalendarList() {
    if (_calendarViewModel.calendars.isEmpty) {
      return const Center(
        child: Text('No calendars found. Please check your device settings.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _calendarViewModel.calendars.length,
      itemBuilder: (context, index) {
        final calendar = _calendarViewModel.calendars[index];
        return _buildCalendarButton(calendar, index);
      },
    );
  }

  /// Builds a button for a specific calendar.
  /// Each button has a unique color and displays the calendar name.
  Widget _buildCalendarButton(UserCalendar calendar, int index) {
    final color = _getCalendarColor(index);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => navigateToCalendarView(calendar),
        child: Row(
          children: [
            // Calendar initial avatar
            CircleAvatar(
              backgroundColor: Colors.white.withAlpha(25),
              child: Text(
                _getCalendarInitial(calendar),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Calendar name
            Expanded(
              child: Text(
                calendar.displayName ?? 'Unnamed Calendar',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the location format guide that appears at the bottom of the screen.
  /// Provides instructions on how to format location information for navigation.
  Widget _buildLocationGuide() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Location Format Guide',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 6),

          // Introduction
          const Text(
            'To enable accurate directions for your calendar events, ensure the location field follows this format:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 6),

          // Format instructions
          const Text(
            'Format: [Building Code] ␣ [Floor] [Room]',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Example
          const Text(
            'Example: Hall Building, Floor 9, Room 27 → H 927',
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  /// Gets the first character of the calendar name to use as an initial.
  /// Returns '?' if the calendar has no name.
  String _getCalendarInitial(UserCalendar calendar) {
    return (calendar.displayName?.isNotEmpty == true)
        ? calendar.displayName![0]
        : '?';
  }
  
  /// Navigates to the calendar view screen with the selected calendar.
  void navigateToCalendarView(UserCalendar selectedCalendars) {
    Navigator.pushNamed(
      context,
      '/CalendarView',
      arguments: selectedCalendars,
    );
  }

  /// Returns a color for a calendar based on its index.
  /// Creates a repeating pattern of colors for visual distinction.
  Color _getCalendarColor(int index) {
    // Generate a different color for each calendar
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
    ];
    return colors[index % colors.length];
  }
}