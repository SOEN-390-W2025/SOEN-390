import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/ui/home/homepage_view.dart';

void main() {
  testWidgets('HomePage should render correctly', (WidgetTester tester) async {
    // Build the HomePage widget
    await tester.pumpWidget(const MaterialApp(home: const HomePage()));

    // Verify that the app bar is present and has the correct title
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    // Verify that the Concordia Campus Guide text and icon are present
    expect(find.text('Concordia Campus Guide'), findsOneWidget);
    expect(find.byIcon(Icons.location_on), findsOneWidget);

    // Verify that the SGW map and LOY map FeatureCards are present
    expect(find.text('SGW map'), findsOneWidget);
    expect(find.text('LOY map'), findsOneWidget);
    expect(find.byIcon(Icons.map), findsNWidgets(2));

    // Verify that the Outdoor directions and Next class directions FeatureCards are present
    expect(find.text('Outdoor directions'), findsOneWidget);
    expect(find.text('Next class directions'), findsOneWidget);
    expect(find.byIcon(Icons.maps_home_work), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);

    // Verify that the Indoor directions and Find nearby facilities FeatureCards are present
    expect(find.text('Indoor directions'), findsOneWidget);
    expect(find.text('Find nearby facilities'), findsOneWidget);
    expect(find.byIcon(Icons.meeting_room), findsOneWidget);
    expect(find.byIcon(Icons.wash), findsOneWidget);
  });

  testWidgets('SGW campus navigation should work', (WidgetTester tester) async {
    // Build the HomePage widget
    await tester.pumpWidget(const MaterialApp(home: const HomePage()));
    await tester.pump();

    // Tap on the SGW map FeatureCard
    await tester.tap(find.text('SGW map'));
    await tester.pumpAndSettle();
    expect(find.text('SGW Campus'), findsOneWidget);

    // Press the back button
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('Loyola campus navigation should work', (WidgetTester tester) async {
    // Build the HomePage widget
    await tester.pumpWidget(const MaterialApp(home: const HomePage()));
    await tester.pump();

    // Tap on the Loyola map FeatureCard
    await tester.tap(find.text('LOY map'));
    await tester.pumpAndSettle();
    expect(find.text('LOY Campus'), findsOneWidget);

    // Press the back button
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('Indoor Directions navigation should work', (WidgetTester tester) async {
    // Build the HomePage widget
    await tester.pumpWidget(const MaterialApp(home: const HomePage()));
    await tester.pump();

    // Tap on the Indoor directions FeatureCard
    await tester.tap(find.text('Indoor directions'));
    await tester.pumpAndSettle(); // Wait for navigation to complete
    expect(find.text('Indoor Map'), findsOneWidget);

    // Tap the back button in the app bar
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle(); // Wait for navigation to complete
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('Nearby Facilities navigation should work', (WidgetTester tester) async {
    // Build the HomePage widget
    await tester.pumpWidget(const MaterialApp(home: const HomePage()));
    await tester.pump();

    // Tap on the Find nearby facilities FeatureCard
    await tester.tap(find.byIcon(Icons.wash));
    await tester.pumpAndSettle(); // Wait for navigation to complete

    // Tap the back button in the app bar
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle(); // Wait for navigation to complete
  });

  testWidgets('Next Class navigation should work', (WidgetTester tester) async {
    // Build the HomePage widget
    await tester.pumpWidget(const MaterialApp(home: const HomePage()));
    await tester.pump();

    // Tap on the Next Class directions FeatureCard
    await tester.tap(find.byIcon(Icons.calendar_today));
    await tester.pumpAndSettle(); // Wait for navigation to complete

    // Tap the back button in the app bar
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle(); // Wait for navigation to complete
  });

  testWidgets('Outdoor Directions navigation should work', (WidgetTester tester) async {
    // Build the HomePage widget
    await tester.pumpWidget(const MaterialApp(home: const HomePage()));
    await tester.pump();

    // Tap on the Outdoor Directions FeatureCard
    await tester.tap(find.byIcon(Icons.maps_home_work));
    await tester.pumpAndSettle(); // Wait for navigation to complete

    // Tap the back button in the app bar
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle(); // Wait for navigation to complete
  });

  testWidgets('Main menu items are present',
      (WidgetTester tester) async {

    // Build the HomePage widget with mock onPress handlers
    await tester.pumpWidget(const MaterialApp(
      home: const HomePage()
    ));
    await tester.pump();
    // Tap on the Menu button
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump();

    // Verify that the app has returned to the HomePage
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Concordia Campus Guide'), findsOneWidget);
  });
}
