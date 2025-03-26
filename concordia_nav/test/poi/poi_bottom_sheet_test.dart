import 'package:concordia_nav/data/domain-model/poi.dart';
import 'package:concordia_nav/ui/indoor_location/indoor_directions_view.dart';
import 'package:concordia_nav/utils/settings/preferences_viewmodel.dart';
import 'package:concordia_nav/widgets/poi_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import '../settings/preferences_view_test.mocks.dart';

void main () {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');
  
  testWidgets('POIBottomSheet renders with non-constant key', 
      (WidgetTester tester) async {
    final poi = POI(id: "1", name: "Washroom", buildingId: "H", floor: "1",
        category: POICategory.washroom, x: 492, y: 678);
    // Build POIBottomsheet widget
    await tester.pumpWidget(MaterialApp(home: POIBottomSheet(
        key: UniqueKey(),
        buildingName: "Hall Building", 
        poi: poi)));
    await tester.pump();

    expect(find.text("Washroom"), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('POIBottomSheet renders correctly', (WidgetTester tester) async {
    final poi = POI(id: "1", name: "Washroom", buildingId: "H", floor: "1",
        category: POICategory.washroom, x: 492, y: 678);
    // Build POIBottomsheet widget
    await tester.pumpWidget(MaterialApp(home: POIBottomSheet(
        buildingName: "Hall Building", 
        poi: poi)));
    await tester.pump();

    expect(find.text("Washroom"), findsOneWidget);
    expect(find.text("Directions"), findsOneWidget);
  });

  testWidgets('tap Directions button navigates to indoor directions', 
      (WidgetTester tester) async {
    final poi = POI(id: "1", name: "Washroom", buildingId: "H", floor: "1",
        category: POICategory.washroom, x: 492, y: 678);
    final mockPreferencesModel = MockPreferencesModel();
    when(mockPreferencesModel.selectedTransportation).thenReturn('Driving');
    when(mockPreferencesModel.selectedMeasurementUnit).thenReturn('Metric');

    // define routes needed for this test
    final routes = {
      '/': (context) => POIBottomSheet(
        buildingName: "Hall Building", 
        poi: poi),
      '/IndoorDirectionsView': (context) => IndoorDirectionsView(
        sourceRoom: 'Your location',
        building: 'Hall Building',
        endRoom: '901'),
    };
    
    // Build POIBottomsheet widget
    await tester.pumpWidget(
      ChangeNotifierProvider<PreferencesModel>(
        create: (BuildContext context) => mockPreferencesModel,
        child: MaterialApp(
                initialRoute: '/',
                routes: routes,
              ),
      )
    );
    await tester.pump();

    expect(find.text("Directions"), findsOneWidget);
    await tester.tap(find.text("Directions"));
    await tester.pumpAndSettle();

    expect(find.text("Floor Navigation"), findsOneWidget);
  });
}