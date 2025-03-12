import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import '../../../data/repositories/calendar.dart';
import '../../../utils/calendar _selction_viewmodel.dart';
import '../../../widgets/custom_appbar.dart';

class CalendarSelectionView extends StatefulWidget {
  const CalendarSelectionView({super.key});

  @override
  State<CalendarSelectionView> createState() => _CalendarSelectionViewState();
}

class _CalendarSelectionViewState extends State<CalendarSelectionView> {
  final CalendarSelectionViewModel _viewModel = CalendarSelectionViewModel();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCalendars();
  }

  Future<void> _loadCalendars() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _viewModel.loadCalendars();
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
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Select a calendar category',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                Expanded(child: _buildCalendarList()),
              ],
            ),
    );
  }

  Widget _buildCalendarList() {
    if (_viewModel.calendars.isEmpty) {
      return const Center(
        child: Text('No calendars found. Please check your device settings.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _viewModel.calendars.length,
      itemBuilder: (context, index) {
        final calendar = _viewModel.calendars[index];
        return _buildCalendarButton(calendar, index);
      },
    );
  }

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
        onPressed: () {
          
          // Navigate with only this specific calendar
          navigateToCalendarView([calendar]);
        },
        child: Row(
          children: [
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

  String _getCalendarInitial(UserCalendar calendar) {
    return (calendar.displayName?.isNotEmpty == true)
        ? calendar.displayName![0]
        : '?';
  }
  
  void navigateToCalendarView(List<UserCalendar> selectedCalendars) {
     dev.log('CalendarViewModel: Navigating to CalendarView with ${selectedCalendars.length} calendars');
    Navigator.pushNamed(
      context,
      '/CalendarView',
      arguments: selectedCalendars,
    );
  }

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