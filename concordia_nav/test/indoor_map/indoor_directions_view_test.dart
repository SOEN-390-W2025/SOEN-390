import 'package:concordia_nav/data/domain-model/poi.dart';
import 'package:concordia_nav/ui/indoor_location/indoor_directions_view.dart';
import 'package:concordia_nav/utils/indoor_directions_viewmodel.dart';
import 'package:concordia_nav/utils/settings/preferences_viewmodel.dart';
import 'package:concordia_nav/widgets/indoor/location_info_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import '../settings/preferences_view_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');

  const String yourLocationString = 'Your Location';

  late Widget view;
  late IndoorDirectionsViewModel mockDirectionsViewModel;
  late MockPreferencesModel mockPreferencesModel;

  setUp(() {
    mockDirectionsViewModel = IndoorDirectionsViewModel();
    mockPreferencesModel = MockPreferencesModel();
    when(mockPreferencesModel.selectedTransportation).thenReturn('Driving');
    when(mockPreferencesModel.selectedMeasurementUnit).thenReturn('Metric');
  });

  group('IndoorDirectionsView', () {
    testWidgets('handles previous floor press correctly',
        (WidgetTester tester) async {
      view = MultiProvider(
        providers: [
          ChangeNotifierProvider<IndoorDirectionsViewModel>(
            create: (_) => mockDirectionsViewModel),
          ChangeNotifierProvider<PreferencesModel>(
            create: (_) => mockPreferencesModel)
        ],
        child: MaterialApp(
          home: IndoorDirectionsView(
            sourceRoom: 'H 921',
            building: 'Hall Building',
            endRoom: 'H 830',
          ),
        ),
      );

      await tester.pumpWidget(view);
      await tester.pumpAndSettle();

      final state = tester
          .state<IndoorDirectionsViewState>(find.byType(IndoorDirectionsView));

      state.handleNextFloorPress();
      await tester.pump();

      expect(state.widget.sourceRoom, 'H 921');
      expect(state.widget.endRoom, yourLocationString);
      expect(IndoorDirectionsViewState.isMultiFloor, true);

      state.handlePrevFloorPress();
      await tester.pump();

      expect(state.widget.sourceRoom, 'connection');
      expect(state.widget.endRoom, 'H 830');
      expect(IndoorDirectionsViewState.isMultiFloor, true);
    });

    testWidgets('IndoorDirectionsView renders correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: MaterialApp(
                  home: IndoorDirectionsView(
                    sourceRoom: yourLocationString,
                    building: 'Hall Building',
                    endRoom: 'H 110',
                  ),
                ),
        )
      );
      await tester.pumpAndSettle();

      expect(find.text('Floor Navigation'), findsOneWidget);
      expect(find.text('From: Your Location'), findsOneWidget);
      expect(find.textContaining('To: H 110'), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('IndoorDirectionsView with selectedPOI',
        (WidgetTester tester) async {
      final poi = POI(id: "1", name: "Bathroom", buildingId:"H", floor: "1", 
          category: POICategory.washroom, x: 492, y: 678);
      await tester.pumpWidget(
        ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: MaterialApp(
                  home: IndoorDirectionsView(
                    sourceRoom: yourLocationString,
                    building: 'Hall Building',
                    endRoom: 'H 110',
                    selectedPOI: poi,
                  ),
                ),
        )
      );
      await tester.pumpAndSettle();

      final locationInfoWidget = find.byType(LocationInfoWidget).evaluate().single.widget as LocationInfoWidget;
      expect(locationInfoWidget.to, 'Bathroom (H 1)');
    });

    testWidgets('IndoorDirectionsView with selectedPOI on different floor',
        (WidgetTester tester) async {
      final poi = POI(id: "1", name: "Bathroom", buildingId:"H", floor: "9", 
          category: POICategory.washroom, x: 593, y: 778);
      await tester.pumpWidget(
        ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: MaterialApp(
                  home: IndoorDirectionsView(
                    sourceRoom: yourLocationString,
                    building: 'Hall Building',
                    endRoom: 'H 937',
                    selectedPOI: poi,
                  ),
                ),
        )
      );
      await tester.pumpAndSettle();
      
      final locationInfoWidget = find.byType(LocationInfoWidget).evaluate().single.widget as LocationInfoWidget;
      expect(locationInfoWidget.to, 'Bathroom (H 9)');
    });

    testWidgets('Start button exists and can be tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: MaterialApp(
                  home: IndoorDirectionsView(
                    sourceRoom: yourLocationString,
                    building: 'Hall Building',
                    endRoom: 'H110',
                  ),
                ),
        )
      );
      await tester.pumpAndSettle();

      final Finder startButton = find.text('Start');
      expect(startButton, findsOneWidget);

      await tester.tap(startButton);
      await tester.pumpAndSettle();

      expect(find.text('Step-by-Step Guide'), findsOneWidget);
    });
  });
}
