import 'package:concordia_nav/ui/indoor_location/indoor_directions_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');

  testWidgets('IndoorDirectionsView renders correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: IndoorDirectionsView(
          currentLocation: 'Entrance',
          building: 'Hall Building',
          floor: '1',
          room: 'H101',
        ),
      ),
    );

    expect(find.text('Indoor Directions'), findsOneWidget);
    expect(find.text('From: Entrance'), findsOneWidget);
    expect(find.textContaining('To:'), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('Dropdown menu updates selected mode',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: IndoorDirectionsView(
          currentLocation: 'Entrance',
          building: 'Hall Building',
          floor: '1',
          room: 'H101',
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Accessibility').last);
    await tester.pumpAndSettle();

    expect(find.text('Accessibility'), findsOneWidget);
  });

  testWidgets('Tapping zoom buttons changes scale',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: IndoorDirectionsView(
          currentLocation: 'Entrance',
          building: 'Hall Building',
          floor: '1',
          room: 'H101',
        ),
      ),
    );

    final Finder zoomInButton = find.byIcon(Icons.add);
    final Finder zoomOutButton = find.byIcon(Icons.remove);

    await tester.tap(zoomInButton);
    await tester.pumpAndSettle();

    await tester.tap(zoomOutButton);
    await tester.pumpAndSettle();
  });

  testWidgets('Start button exists and can be tapped',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: IndoorDirectionsView(
          currentLocation: 'Entrance',
          building: 'Hall Building',
          floor: '1',
          room: 'H101',
        ),
      ),
    );

    final Finder startButton = find.text('Start');
    expect(startButton, findsOneWidget);

    await tester.tap(startButton);
    await tester.pumpAndSettle();
  });
}
