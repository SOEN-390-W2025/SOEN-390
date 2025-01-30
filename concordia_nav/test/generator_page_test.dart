import 'package:concordia_nav/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('GeneratorPage Tests:', () {
    testWidgets('displays correct icon based on favorite status',
        (WidgetTester tester) async {
      final appState = MyAppState();

      await tester.pumpWidget(
        ChangeNotifierProvider<MyAppState>.value(
          value: appState,
          child: const MaterialApp(
            home: Scaffold(
              body: GeneratorPage(),
            ),
          ),
        ),
      );

      // Verify that the initial icon is favorite_border
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      // Add the current pair to favorites
      appState.toggleFavorite();
      await tester.pump();

      // Verify that the icon changes to favorite
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      // Remove the current pair from favorites
      appState.toggleFavorite();
      await tester.pump();

      // Verify that the icon changes back to favorite_border
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });
  });
}
