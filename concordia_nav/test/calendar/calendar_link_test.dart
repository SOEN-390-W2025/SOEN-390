import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/ui/setting/calendar/calendar_link_view.dart';

void main() {
  group('calendar link page', () {
    testWidgets('all widgets are present', (WidgetTester tester) async {
      // Build CalendarLink view page
      await tester
          .pumpWidget(const MaterialApp(home: const CalendarLinkView()));
      await tester.pump();

      // Verify the appBar is present and with the right title
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Calendar Link'), findsOneWidget);

      // Verify no calendar message is displayed
      expect(find.text('There is currently no calendar'), findsOneWidget);

      // Verify Link button exists
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Link'), findsOneWidget);
    });
  });
}
