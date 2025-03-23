import 'package:concordia_nav/data/domain-model/place.dart';
import 'package:concordia_nav/data/services/places_service.dart';
import 'package:concordia_nav/ui/poi/nearby_poi_map.dart';
import 'package:concordia_nav/utils/poi/poi_viewmodel.dart';
import 'package:concordia_nav/widgets/poi_info_drawer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'nearby_poi_mapview_test.mocks.dart';

@GenerateMocks([POIViewModel])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');

  late MockPOIViewModel mockPOIViewModel;
  late Set<Marker> markers;

  setUp(() {
    mockPOIViewModel = MockPOIViewModel();
    when(mockPOIViewModel.currentLocation).thenReturn(const LatLng(45.4215, -75.6992));
    final outdoorPois = [
      Place(id: "1", name: "Allons Burger", location: const LatLng(45.49648751167641, -73.57862647170876), types: ["foodDrink"]),
      Place(id: "2", name: "Misoya", location: const LatLng(45.49776972691097, -73.57849236126107), types: ["foodDrink"])
    ];
    final marker1 = Marker(
        markerId: MarkerId(outdoorPois[0].id),
        position: outdoorPois[0].location,
        infoWindow: InfoWindow(
          title: outdoorPois[0].name,
          snippet: 'No address available',
        ),
      );
    final marker2 = Marker(
        markerId: MarkerId(outdoorPois[1].id),
        position: outdoorPois[1].location,
        infoWindow: InfoWindow(
          title: outdoorPois[1].name,
          snippet: 'No address available',
        ),
      );
    markers = {marker1, marker2};
    when(mockPOIViewModel.loadOutdoorPOIs(PlaceType.foodDrink)).thenAnswer((_) async => {});
    when(mockPOIViewModel.outdoorPOIs).thenReturn(outdoorPois);
    when(mockPOIViewModel.filteredOutdoorPOIs).thenReturn(outdoorPois);
    when(mockPOIViewModel.errorOutdoor).thenReturn('');
    when(mockPOIViewModel.isLoadingOutdoor).thenReturn(false);
    when(mockPOIViewModel.getCategoryTitle(PlaceType.foodDrink)).thenReturn("Restaurants");
    final categories = [
      {'type': PlaceType.foodDrink, 'icon': Icons.restaurant, 'label': 'Restaurants'},
    ];
    when(mockPOIViewModel.getOutdoorCategories()).thenReturn(categories);
    when(mockPOIViewModel.getIconForPlaceType(PlaceType.foodDrink)).thenReturn(Icons.restaurant);
    when(mockPOIViewModel.travelMode).thenReturn(TravelMode.WALK);
    when(mockPOIViewModel.getIconForTravelMode(TravelMode.WALK)).thenReturn(Icons.directions_walk);
    when(mockPOIViewModel.searchRadius).thenReturn(1000);
  });
  group('NearbyPOIMapView Tests', () {
    testWidgets('renders NearbyPOIMapView with non-constant key', (WidgetTester tester) async {
      // Build the NearbyPOIMapView widget
      await tester.pumpWidget(MaterialApp(home: NearbyPOIMapView(
          key: UniqueKey(), poiViewModel: mockPOIViewModel, category: PlaceType.foodDrink, markers: markers,)));
      await tester.pump();
      
      // Verify that the appBar exists and has the right title
      expect(find.text("Restaurants"), findsOneWidget);
    });

    testWidgets('renders NearbyPOIMapView accurately', (WidgetTester tester) async {
      // Build the NearbyPOIMapView widget
      await tester.pumpWidget(MaterialApp(home: NearbyPOIMapView(
          poiViewModel: mockPOIViewModel, category: PlaceType.foodDrink, markers: markers,)));
      await tester.pump();
      
      expect(find.text("Restaurants"), findsOneWidget);
      expect(find.byIcon(Icons.list), findsOneWidget);
      expect(find.text('Search Radius:'), findsOneWidget);  
    });

    testWidgets('tap list icon to view list of POIs', (WidgetTester tester) async {
      // Build the NearbyPOIMapView widget
      await tester.pumpWidget(MaterialApp(home: NearbyPOIMapView(
          poiViewModel: mockPOIViewModel, category: PlaceType.foodDrink, markers: markers,)));
      await tester.pump();
      
      // tap the list icon
      expect(find.byIcon(Icons.list), findsOneWidget);
      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();

      expect(find.text("Nearby Restaurants"), findsOneWidget);
      expect(find.text("Allons Burger"), findsOneWidget);
    });

    testWidgets('POI list returns message when no places found', (WidgetTester tester) async {
      when(mockPOIViewModel.filteredOutdoorPOIs).thenReturn([]);
      // Build the NearbyPOIMapView widget
      await tester.pumpWidget(MaterialApp(home: NearbyPOIMapView(
          poiViewModel: mockPOIViewModel, category: PlaceType.foodDrink, markers: markers,)));
      await tester.pump();
      
      // tap the list icon
      expect(find.byIcon(Icons.list), findsOneWidget);
      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();

      expect(find.text("No places found"), findsOneWidget); 
    });
  });

  group('POIInfoDrawer', () {
    testWidgets('POIInfoDrawer renders', (WidgetTester tester) async {
      // Build a POIInfoDrawer widget
      final place = Place(id: "1", name: "Allons Burger", 
        location: const LatLng(45.49648751167641, -73.57862647170876), types: ["foodDrink"],
        distanceMeters: 20, durationSeconds: 60, rating: 7.5, isOpen: false);
      await tester.pumpWidget(MaterialApp(home: 
        POIInfoDrawer(place: place, onClose: () => {}, onDirections: () => {})));
      await tester.pump();

      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text(place.name), findsOneWidget);
      expect(find.text("Closed"), findsOneWidget);
    });
  });
}