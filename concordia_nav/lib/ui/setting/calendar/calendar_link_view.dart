import 'package:flutter/material.dart';
import '../../../data/repositories/calendar.dart';
import '../../../widgets/custom_appbar.dart';
import 'calandar_view.dart';

class CalendarLinkView extends StatelessWidget {
  const CalendarLinkView({super.key});

  /// Request calendar permissions.
  Future<void> requestCalendarPermissions(BuildContext context) async {
    // Check if permission is granted
    final permissionsGranted = await CalendarRepository().checkPermissions();
    
    if (context.mounted) {
      if (permissionsGranted) {
        // Assume there is no error
        // Navigate to calendar view
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CalendarView()),
        );

      } else {
        // Show an error if permission is denied

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied. Please enable it in settings.')),
        );
      }
    }
  }

  // This shows a UI that allows the user to request calendar permissions.
  // If permission is granted, it navigates to the calendar view. If permission
  // is denied, it shows an error.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Calendar Link'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show a message if there is no calendar
            const Text(
              'There is currently no calendar',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            // Show a button to request calendar permissions
            ElevatedButton(
              onPressed: () => requestCalendarPermissions(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'Link',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
