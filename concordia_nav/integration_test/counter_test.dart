import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/main.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-To-End Test:', () {
    testWidgets('navigate to counter page and verify counter', (tester) async {
      await tester.pumpWidget(const MyApp());

      // Finds the button with a + icon to navigate to the counter page.
      final navigateButton = find.byIcon(Icons.add);

      await tester.tap(navigateButton);

      // Trigger a frame.
      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);

      // Finds the floating action button to tap on.
      final fab = find.byKey(const ValueKey('increment'));

      await tester.tap(fab);

      // Trigger a frame.
      await tester.pumpAndSettle();

      // Verify the counter increments by 1.
      expect(find.text('1'), findsOneWidget);
    });
  });
}
