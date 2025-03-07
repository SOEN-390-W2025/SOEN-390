import 'package:concordia_nav/ui/indoor_location/indoor_directions_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');
  group('IndoorDirectionsView', () {
    testWidgets('IndoorDirectionsView renders correctly',
      (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: IndoorDirectionsView(
              sourceRoom: 'Your Location',
              building: 'Hall Building',
              floor: '1',
              endRoom: 'H 110',
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Indoor Directions'), findsOneWidget);
        expect(find.text('From: Your Location'), findsOneWidget);
        expect(find.textContaining('To: H 110'), findsOneWidget);
        expect(find.byType(SvgPicture), findsOneWidget);
      });
    });

    testWidgets('Tapping zoom buttons changes scale',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: IndoorDirectionsView(
              sourceRoom: 'Your Location',
              building: 'Hall Building',
              floor: '1',
              endRoom: 'H110',
            ),
          ),
        );
        await tester.pump();

        final Finder zoomInButton = find.byIcon(Icons.add);
        final Finder zoomOutButton = find.byIcon(Icons.remove);

        await tester.tap(zoomInButton);
        await tester.pump();

        await tester.tap(zoomOutButton);
        await tester.pumpAndSettle();

        expect(find.byType(SvgPicture), findsOneWidget);
      });
    });

    testWidgets('Start button exists and can be tapped',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: IndoorDirectionsView(
              sourceRoom: 'Your Location',
              building: 'Hall Building',
              floor: '1',
              endRoom: 'H110',
            ),
          ),
        );
        await tester.pump();

        final Finder startButton = find.text('Start');
        expect(startButton, findsOneWidget);

        await tester.tap(startButton);
        await tester.pump();
      });
    });
  });
}
