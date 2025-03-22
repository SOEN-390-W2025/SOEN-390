import 'package:concordia_nav/data/domain-model/place.dart';
import 'package:concordia_nav/data/domain-model/poi.dart';
import 'package:concordia_nav/ui/poi/poi_choice_view.dart';
import 'package:concordia_nav/ui/poi/poi_map_view.dart';
import 'package:concordia_nav/utils/poi/poi_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'poipage_test.mocks.dart';

@GenerateMocks([POIViewModel])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');

  late MockPOIViewModel mockPOIViewModel;

  setUp(() {
    mockPOIViewModel = MockPOIViewModel();
    when(mockPOIViewModel.init()).thenAnswer((_) async => {});
    when(mockPOIViewModel.currentLocation).thenReturn(const LatLng(45.4215, -75.6992));
    final allPois = [
      POI(id: "1", name: "Bathroom", buildingId:"H", floor: "1", category: POICategory.washroom, 
          x: 492, y: 678),
      POI(id: "2", name: "Water Fountain", buildingId:"H", floor: "1", category: POICategory.waterFountain, 
          x: 564, y: 711),
      POI(id: "3", name: "Police", buildingId:"H", floor: "1", category: POICategory.police, 
          x: 815, y: 915)];
    when(mockPOIViewModel.allPOIs).thenReturn(allPois);
    final outdoorPois = [
      Place(id: "1", name: "Allons Burger", location: const LatLng(45.49648751167641, -73.57862647170876), types: ["foodDrink"]),
      Place(id: "2", name: "Misoya", location: const LatLng(45.49776972691097, -73.57849236126107), types: ["foodDrink"])
    ];
    when(mockPOIViewModel.outdoorPOIs).thenReturn(outdoorPois);
    when(mockPOIViewModel.isLoadingLocation).thenReturn(false);
    when(mockPOIViewModel.hasLocationPermission).thenReturn(true);
    when(mockPOIViewModel.globalSearchQuery).thenReturn('');
    when(mockPOIViewModel.errorOutdoor).thenReturn('');
    when(mockPOIViewModel.isLoadingOutdoor).thenReturn(false);
    when(mockPOIViewModel.isLoadingIndoor).thenReturn(false);
    when(mockPOIViewModel.errorIndoor).thenReturn('');
    when(mockPOIViewModel.filterPOIsWithGlobalSearch()).thenReturn(allPois);
    when(mockPOIViewModel.getUniqueFilteredPOINames(allPois)).thenReturn(["Bathroom", "Water Fountain", "Police"]);
    when(mockPOIViewModel.getIconForPOICategory(POICategory.washroom)).thenReturn(Icons.wc);
    when(mockPOIViewModel.getIconForPOICategory(POICategory.waterFountain)).thenReturn(Icons.water_drop);
    when(mockPOIViewModel.getIconForPOICategory(POICategory.police)).thenReturn(Icons.local_police);
  });

  group('poiAppBar', () {
    testWidgets('renders POIChoiceView with non-constant key',
        (WidgetTester tester) async {
      // runAsync ref: https://stackoverflow.com/a/69004451
      await tester.runAsync(() async {
        // wait for loading JSON
        // Build the POI page widget
        await tester
            .pumpWidget(MaterialApp(home: POIChoiceView(key: UniqueKey(), viewModel: mockPOIViewModel)));
        await tester.pump();

        // Verify that the appBar exists and has the right title
        expect(find.text('POI List'), findsOneWidget);
      });
    });

    testWidgets('appBar has the right title', (WidgetTester tester) async {
      await tester.runAsync(() async {
        // wait for loading JSON
        // Build the POI page widget
        await tester.pumpWidget(MaterialApp(home: POIChoiceView(viewModel: mockPOIViewModel)));
        await tester.pump();

        // Verify that the appBar exists and has the right title
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('POI List'), findsOneWidget);
      });
    });
  });

  group('poiViewModel', () {
    testWidgets('filter option works', (WidgetTester tester) async {
      await tester.runAsync(() async {
        when(mockPOIViewModel.globalSearchQuery).thenReturn("Bath");
        when(mockPOIViewModel.setGlobalSearchQuery("Bath")).thenAnswer((_) async => {});
        final filteredPOI = [POI(id: "1", name: "Bathroom", buildingId:"H", floor: "1", category: POICategory.washroom, 
          x: 492, y: 678),];
        when(mockPOIViewModel.filterPOIsWithGlobalSearch()).thenReturn(filteredPOI);
        when(mockPOIViewModel.getUniqueFilteredPOINames(filteredPOI)).thenReturn(["Bathroom"]);
        // Build the POI page widget
        await tester.pumpWidget(MaterialApp(home: POIChoiceView(viewModel: mockPOIViewModel)));
        await tester.pump();

        // Find the SearchBarWidget
        final searchBarWidget = find
            .byType(TextField)
            .evaluate()
            .single
            .widget as TextField;

        // Enter "Bath" in the searchBar
        await tester.enterText(find.byType(TextField), "Bath");
        
        expect(searchBarWidget.controller?.text, "Bath");
        await tester.pumpAndSettle();

        // Verify that the Bathroom poi widget is present
        expect(find.text("Bathroom"), findsOneWidget);
        expect(find.text("Water Fountain"), findsNothing);
      });
    });

    testWidgets('filter invalid option removes all poiBoxes',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        when(mockPOIViewModel.globalSearchQuery).thenReturn("Test");
        when(mockPOIViewModel.setGlobalSearchQuery("Test")).thenAnswer((_) async => {});
        when(mockPOIViewModel.filterPOIsWithGlobalSearch()).thenReturn([]);
        when(mockPOIViewModel.getUniqueFilteredPOINames([])).thenReturn([]);
        // Build the POI page widget
        await tester.pumpWidget(MaterialApp(home: POIChoiceView(viewModel: mockPOIViewModel,)));
        await tester.pump();

        // Find the SearchBarWidget
        final searchBarWidget = find
            .byType(TextField)
            .evaluate()
            .single
            .widget as TextField;

        // Enter "Test" in the searchBar
        await tester.enterText(find.byType(TextField), "Test");
        expect(searchBarWidget.controller?.text, "Test");
        await tester.pumpAndSettle();

        // Verify that a PoiBox is present
        expect(find.text("No indoor POIs found. Try changing your search."), findsOneWidget);
      });
    });
  });

  group('poiPage', () {
    testWidgets('searchBar and title exists', (WidgetTester tester) async {
      await tester.runAsync(() async {
        // wait for loading JSON
        // Build the POI page widget
        await tester.pumpWidget(MaterialApp(home: POIChoiceView(viewModel: mockPOIViewModel,)));
        await tester.pump();

        // Verify that the searchBar widget exists
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('POI List'), findsOneWidget);
      });
    });

    testWidgets('list of POI boxes are accurate', (WidgetTester tester) async {
      await tester.runAsync(() async {
        // wait for loading JSON
        // Build the POI page widget
        await tester.pumpWidget(MaterialApp(home: POIChoiceView(viewModel: mockPOIViewModel,)));
        await tester.pump();

        // Verify that the Bathroom POI text and icon are present
        expect(find.text('Bathroom'), findsOneWidget);
        expect(find.byIcon(Icons.wc), findsOneWidget);

        // Verify that the Water Fountain PoiBox text and icon are present
        expect(find.text('Water Fountain'), findsOneWidget);
        expect(find.byIcon(Icons.water_drop), findsOneWidget);
      });
    });

    testWidgets('poi box onPress works', (WidgetTester tester) async {
      await tester.runAsync(() async {
        // wait for loading JSON
        // define routes needed for this test
        final routes = {
          '/': (context) => POIChoiceView(viewModel: mockPOIViewModel,),
          '/POIMapView': (context) => POIMapView(
            poiChoiceViewModel: mockPOIViewModel,
            poiName: "Bathroom",
          ),
        };

        // Build the POIChoiceView widget
        await tester.pumpWidget(MaterialApp(
          initialRoute: '/',
          routes: routes,
        ));
        await tester.pumpAndSettle();

        // Tap on Police Poi Box brings to POIMapView
        await tester.tap(find.text('Police'));
        await tester.pumpAndSettle();
        // Should be in the POI map view page
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle(); // return to POIPage
      });
    });
  });
}
