import 'package:concordia_nav/ui/setting/preferences/preferences_view.dart';
import 'package:concordia_nav/utils/settings/preferences_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'preferences_view_test.mocks.dart';

@GenerateMocks([PreferencesModel])
void main () {
  group('PreferencesPage tests', () {
    late MockPreferencesModel mockPreferencesModel;

    setUp(() {
      mockPreferencesModel = MockPreferencesModel();
      when(mockPreferencesModel.selectedTransportation).thenReturn('Driving');
      when(mockPreferencesModel.selectedMeasurementUnit).thenReturn('Metric');
      when(mockPreferencesModel.updateTransportation(any)).thenAnswer((_) async => {});
      when(mockPreferencesModel.updateMeasurementUnit(any)).thenAnswer((_) async => {});
    });

    testWidgets('renders PreferencesPage with non-constant key',
       (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: MaterialApp(home: PreferencesPage(key: UniqueKey())),
        )
      );
      await tester.pump();
       
      expect(find.text("Preferences"), findsOneWidget);
    });

    testWidgets('renders PreferencesPage correctly',
       (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: MaterialApp(home: PreferencesPage(key: UniqueKey())),
        )
      );
      await tester.pump();
       
      expect(find.text("Preferences"), findsOneWidget);
      expect(find.text('Transportation Method'), findsOneWidget);
      expect(find.text('Measurement Unit'), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsNWidgets(2)); 
    });

    testWidgets('tap transportation method dropdown opens it',
       (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: MaterialApp(home: PreferencesPage(key: UniqueKey())),
        )
      );
      await tester.pump();

      // tap driving dropdown
      expect(find.text("Driving"), findsOneWidget);
      await tester.tap(find.text('Driving'));
      await tester.pumpAndSettle();

      expect(find.text('Walking'), findsOneWidget);
      expect(find.text('Biking'), findsOneWidget);
      expect(find.text('Transit'), findsOneWidget);
    });

    testWidgets('transportation dropdown has accurate icons',
       (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: MaterialApp(home: PreferencesPage(key: UniqueKey())),
        )
      );
      await tester.pump();

      // tap driving dropdown
      expect(find.byIcon(Icons.directions_car), findsOneWidget);
      await tester.tap(find.text('Driving'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.directions_walk), findsOneWidget);
      expect(find.byIcon(Icons.directions_bike), findsOneWidget);
      expect(find.byIcon(Icons.directions_transit), findsOneWidget);
    });

    testWidgets('can select a transportation method to update it',
       (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: MaterialApp(home: PreferencesPage(key: UniqueKey())),
        )
      );
      await tester.pump();

      // tap driving dropdown
      expect(find.text("Driving"), findsOneWidget);
      await tester.tap(find.text('Driving'));
      await tester.pumpAndSettle();

      // tap on walking
      await tester.tap(find.text('Walking'));
      await tester.pumpAndSettle();

      // verify tranportation updated
      verify(mockPreferencesModel.updateTransportation('Walking')).called(1);
    });

    testWidgets('tap measurement unit dropdown opens it',
       (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: MaterialApp(home: PreferencesPage(key: UniqueKey())),
        )
      );
      await tester.pump();

      // tap metric dropdown
      expect(find.text("Metric (m)"), findsOneWidget);
      await tester.tap(find.text('Metric (m)'));
      await tester.pumpAndSettle();

      expect(find.text('Imperial (yd)'), findsOneWidget);
    });

    testWidgets('can select a measurement unit to update it',
       (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: MaterialApp(home: PreferencesPage(key: UniqueKey())),
        )
      );
      await tester.pump();

      // tap Metric dropdown
      expect(find.text("Metric (m)"), findsOneWidget);
      await tester.tap(find.text('Metric (m)'));
      await tester.pumpAndSettle();

      // tap on Imperial
      await tester.tap(find.text('Imperial (yd)'));
      await tester.pumpAndSettle();

      // verify measurement updated
      verify(mockPreferencesModel.updateMeasurementUnit('Imperial')).called(1);
    });
  });
}