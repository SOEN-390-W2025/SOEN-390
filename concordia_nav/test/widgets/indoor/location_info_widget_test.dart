import 'package:concordia_nav/widgets/indoor/location_info_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'Tapping on location box navigates to ClassroomSelection with correct arguments',
      (WidgetTester tester) async {
    final mockNavigatorObserver = MockNavigatorObserver();

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [mockNavigatorObserver],
        routes: {
          '/ClassroomSelection': (context) => const Placeholder(),
        },
        home: const Scaffold(
          body: LocationInfoWidget(
            from: 'H 820',
            to: 'H 110',
            building: 'Hall Building',
            isDisability: false,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap the "From" box
    await tester.tap(find.text('From: H 820'));
    await tester.pumpAndSettle();

    // Verify navigation happened with expected arguments
    expect(
      mockNavigatorObserver.lastPushedRoute,
      isA<MaterialPageRoute>()
          .having((r) => r.settings.name, 'name', '/ClassroomSelection'),
    );
  });
}

class MockNavigatorObserver extends NavigatorObserver {
  Route<dynamic>? lastPushedRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    lastPushedRoute = route;
    super.didPush(route, previousRoute);
  }
}
