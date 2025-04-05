import 'package:concordia_nav/data/domain-model/place.dart';
import 'package:concordia_nav/data/domain-model/poi.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:concordia_nav/data/services/map_service.dart';
import 'package:concordia_nav/data/services/places_service.dart';
import 'package:concordia_nav/ui/poi/poi_map_view.dart';
import 'package:concordia_nav/utils/poi/poi_map_viewmodel.dart';
import 'package:concordia_nav/utils/poi/poi_viewmodel.dart';
import 'package:concordia_nav/widgets/poi_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'poi_viewmodel_test.mocks.dart';
import 'poipage_test.mocks.dart';

@GenerateMocks([MapService, PlacesService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');
  late POIViewModel poiViewModel;
  late MockMapService mockMapService;
  late MockPlacesService mockPlacesService;

  final outdoorPois = [
    Place(
        id: "1",
        name: "Allons Burger",
        location: const LatLng(45.49648751167641, -73.57862647170876),
        types: ["foodDrink"]),
    Place(
        id: "2",
        name: "Misoya",
        location: const LatLng(45.49776972691097, -73.57849236126107),
        types: ["foodDrink"])
  ];

  setUp(() {
    mockMapService = MockMapService();
    mockPlacesService = MockPlacesService();
    when(mockPlacesService.nearbySearch(
            location: const LatLng(45.4215, -75.6992),
            includedType: PlaceType.foodDrink,
            options: anyNamed("options")))
        .thenAnswer((_) async => outdoorPois);
    when(mockPlacesService.textSearch(
            textQuery: "Allons",
            location: const LatLng(45.4215, -75.6992),
            includedType: PlaceType.foodDrink,
            options: anyNamed("options")))
        .thenAnswer((_) async => [outdoorPois[0]]);
    when(mockMapService.isLocationServiceEnabled())
        .thenAnswer((_) async => true);
    when(mockMapService.checkAndRequestLocationPermission())
        .thenAnswer((_) async => true);
    when(mockMapService.getCurrentLocation())
        .thenAnswer((_) async => const LatLng(45.4215, -75.6992));

    poiViewModel = POIViewModel(
        mapService: mockMapService, placesService: mockPlacesService);
  });

  testWidgets('showPOIDetails updates state and displays POIBottomSheet',
      (WidgetTester tester) async {
    // Mock dependencies
    final testPOI = POI(
        id: 'test_id',
        name: 'Test POI',
        buildingId: 'Test Building',
        floor: '1',
        category: POICategory.elevator,
        x: 100,
        y: 200);

    final MockPOIMapViewModel poiMapViewModel = MockPOIMapViewModel();

    when(poiMapViewModel.nearestBuilding).thenReturn(BuildingRepository.h);
    when(poiMapViewModel.isLoading).thenReturn(false);
    when(poiMapViewModel.errorMessage).thenReturn("");
    when(poiMapViewModel.floorPlanExists).thenReturn(true);
    when(poiMapViewModel.floorPlanPath)
        .thenReturn("assets/maps/indoor/floorplans/H1.svg");
    when(poiMapViewModel.selectedFloor).thenReturn("1");
    when(poiMapViewModel.width).thenReturn(1024);
    when(poiMapViewModel.height).thenReturn(1024);
    when(poiMapViewModel.userPosition)
        .thenReturn(const Offset(45.4215, -75.6992));
    when(poiMapViewModel.noPoisOnCurrentFloor).thenReturn(false);
    when(poiMapViewModel.searchRadius).thenReturn(50);
    when(poiMapViewModel.poisOnCurrentFloor).thenReturn([testPOI]);

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => ChangeNotifierProvider<POIMapViewModel>.value(
                value: poiMapViewModel,
                child: POIMapView(
                  poiName: 'Test POI',
                  poiChoiceViewModel: poiViewModel,
                  poiMapViewModel: poiMapViewModel,
                ),
              ),
        },
      ),
    );
    // Find the slider in the RadiusBar
    final sliderFinder = find.byType(Slider);

    // Ensure the slider is found
    expect(sliderFinder, findsOneWidget);

    // Drag the slider to increase the radius (e.g., to 100)
    await tester.drag(sliderFinder, const Offset(50, 0));
    await tester.pumpAndSettle();

    final state = tester.state<POIMapViewState>(find.byType(POIMapView));
    state.showPOIDetails(testPOI, poiMapViewModel);
    await tester.pumpAndSettle();

    // Verify that POIBottomSheet appears
    expect(find.byType(POIBottomSheet), findsOneWidget);
  });

  test('can get globalSearchQuery value', () {
    final globalSearchQuery = poiViewModel.globalSearchQuery;

    // returns an empty string by default
    expect(globalSearchQuery, '');
  });

  test('can get isLoadingIndoor value', () {
    final isLoadingIndoor = poiViewModel.isLoadingIndoor;

    // returns true by default
    expect(isLoadingIndoor, true);
  });

  test('can get isLoadingOutdoor value', () {
    final isLoadingOutdoor = poiViewModel.isLoadingOutdoor;

    // returns false by default
    expect(isLoadingOutdoor, false);
  });

  test('can get errorIndoor value', () {
    final errorIndoor = poiViewModel.errorIndoor;

    // returns an empty string by default
    expect(errorIndoor, '');
  });

  test('can get errorOutdoor value', () {
    final errorOutdoor = poiViewModel.errorOutdoor;

    // returns an empty string by default
    expect(errorOutdoor, '');
  });

  test('can get travelMode value', () {
    final travelMode = poiViewModel.travelMode;

    // returns drive by default
    expect(travelMode, TravelMode.DRIVE);
  });

  test('can get selectedOutdoorCategory value', () {
    final selectedOutdoorCategory = poiViewModel.selectedOutdoorCategory;

    // returns foodDrink by default
    expect(selectedOutdoorCategory, PlaceType.foodDrink);
  });

  test('loadIndoorPOIs loads indoor POIs for all buildings', () async {
    await poiViewModel.loadIndoorPOIs();

    // Verify allPOIs is not empty
    expect(poiViewModel.allPOIs, isNotEmpty);
  });

  test('filterPOIsWithGlobalSearch returns all POIs if no query', () async {
    await poiViewModel.loadIndoorPOIs();
    final allPois = poiViewModel.allPOIs;

    final pois = poiViewModel.filterPOIsWithGlobalSearch();

    // Verify both are the same
    expect(pois, allPois);
  });

  test('filterPOIsWithGlobalSearch filters POIs', () async {
    when(mockMapService.isLocationServiceEnabled())
        .thenAnswer((_) async => false);
    await poiViewModel.init();
    await poiViewModel.loadIndoorPOIs();
    final allPois = poiViewModel.allPOIs;

    await poiViewModel.setGlobalSearchQuery("Wash");

    when(mockMapService.isLocationServiceEnabled())
        .thenAnswer((_) async => false);
    await poiViewModel.refreshLocation();
    final pois = poiViewModel.filterPOIsWithGlobalSearch();

    expect(pois, isNot(allPois));
    expect(pois.first.name, "Washroom");
  });

  test('setGlobalSearchQuery filters outdoor POI', () async {
    await poiViewModel.init();
    final outdoorPois = poiViewModel.outdoorPOIs;

    await poiViewModel.setGlobalSearchQuery("Allons");

    expect(poiViewModel.outdoorPOIs, isNot(outdoorPois));
    expect(poiViewModel.outdoorPOIs.first.name, "Allons Burger");
  });

  test('getUniqueFilteredPOINames returns list of POI names', () async {
    await poiViewModel.loadIndoorPOIs();
    final allPois = poiViewModel.allPOIs;

    final names = poiViewModel.getUniqueFilteredPOINames(allPois);

    expect(names, isA<List<String>>());
    expect(names.first, "Escalators");
  });

  test("getIconForPOICategory returns the icon of a category", () {
    const poiCategory = POICategory.restaurant;
    IconData icon = poiViewModel.getIconForPOICategory(poiCategory);
    expect(icon, Icons.restaurant);

    icon = poiViewModel.getIconForPOICategory(POICategory.elevator);
    expect(icon, Icons.elevator);
  });

  test('calculateDistance returnd the distance from mapService', () {
    const point1 = const LatLng(45.4215, -75.6992);
    const point2 = LatLng(45.49648751167641, -73.57862647170876);
    when(mockMapService.calculateDistance(point1, point2)).thenReturn(5);

    final distance = poiViewModel.calculateDistance(point1, point2);

    expect(distance, 5);
  });

  test('createMarkersForOutdoorPOIs should create markers for given POIs',
      () async {
    // Define a mock onTap callback function
    void mockOnTapCallback(Place place) {}

    poiViewModel.filteredOutdoorPOIs = outdoorPois;

    // Call the function and await the result
    final Set<Marker> markers =
        await poiViewModel.createMarkersForOutdoorPOIs(mockOnTapCallback);

    expect(markers.length, equals(2));
  });

  test('hasMatchingIndoorPOIs returns true if filtered list not empty',
      () async {
    await poiViewModel.loadIndoorPOIs();
    await poiViewModel.refreshLocation();

    final matching = poiViewModel.hasMatchingIndoorPOIs();

    expect(matching, true);
  });

  test('getOutdoorCategories returns list of categories', () {
    final categories = poiViewModel.getOutdoorCategories();

    expect(categories, isA<List<Map<String, dynamic>>>());
    expect(categories, isNotEmpty);
    expect(categories.first["icon"], Icons.restaurant);
  });

  test('getOutdoorCategories returns filtered list if query', () async {
    when(mockMapService.isLocationServiceEnabled())
        .thenAnswer((_) async => false);
    await poiViewModel.init();
    await poiViewModel.setGlobalSearchQuery("Coffee");

    final categories = poiViewModel.getOutdoorCategories();

    expect(categories, isA<List<Map<String, dynamic>>>());
    expect(categories.length, 1);
    expect(categories.first["icon"], Icons.coffee);
  });

  test('setSearchRadius updates search radius value', () async {
    final initialRadius = poiViewModel.searchRadius;
    await poiViewModel.setSearchRadius(500);

    final radius = poiViewModel.searchRadius;
    expect(radius, isNot(initialRadius));
    expect(radius, 500);
  });

  test('setOutdoorCategory updates outdoorCategory', () async {
    when(mockMapService.isLocationServiceEnabled())
        .thenAnswer((_) async => false);
    await poiViewModel.init();

    await poiViewModel.setOutdoorCategory(PlaceType.foodDrink, true);
    expect(poiViewModel.selectedOutdoorCategory, PlaceType.foodDrink);
  });

  test('setOutdoorCategory updates to null if selected false', () async {
    when(mockMapService.isLocationServiceEnabled())
        .thenAnswer((_) async => false);
    await poiViewModel.init();

    await poiViewModel.setOutdoorCategory(PlaceType.foodDrink, false);
    expect(poiViewModel.selectedOutdoorCategory, isNull);
  });

  test('hasMatchingCategories returns true if categories not empty', () {
    final matching = poiViewModel.hasMatchingCategories();

    expect(matching, true);
  });

  test('getIconForPlaceType return icon of place type', () {
    IconData icon = poiViewModel.getIconForPlaceType(PlaceType.foodDrink);
    expect(icon, Icons.restaurant);

    icon = poiViewModel.getIconForPlaceType(PlaceType.grocery);
    expect(icon, Icons.shopping_cart);
  });

  test('getIconForTravelMode returns icon for travel mode', () {
    IconData icon = poiViewModel.getIconForTravelMode(TravelMode.WALK);
    expect(icon, Icons.directions_walk);

    icon = poiViewModel.getIconForTravelMode(TravelMode.BICYCLE);
    expect(icon, Icons.directions_bike);
  });

  test('getCategoryTitle returns category title', () {
    String title = poiViewModel.getCategoryTitle(PlaceType.healthCenter);
    expect(title, "Health Centers");

    title = poiViewModel.getCategoryTitle(PlaceType.grocery);
    expect(title, "Grocery Stores");
  });

  test('init leaves pois empty if location service disabled', () async {
    // Arrange
    when(mockMapService.isLocationServiceEnabled())
        .thenAnswer((_) async => false);

    // Act
    await poiViewModel.init();

    // Assert
    expect(poiViewModel.hasLocationPermission, false);
    expect(poiViewModel.locationErrorMessage, "Location services are disabled");
    expect(poiViewModel.currentLocation, isNull);
    expect(poiViewModel.allPOIs, isEmpty);
    expect(poiViewModel.outdoorPOIs, isEmpty);
  });

  test('init leaves pois empty if location permission disabled', () async {
    // Arrange
    when(mockMapService.checkAndRequestLocationPermission())
        .thenAnswer((_) async => false);
    await poiViewModel.refreshLocation();

    // Act
    await poiViewModel.init();

    // Assert
    expect(poiViewModel.hasLocationPermission, false);
    expect(poiViewModel.locationErrorMessage, "Location permission denied");
    expect(poiViewModel.currentLocation, isNull);
    expect(poiViewModel.allPOIs, isEmpty);
  });

  test('init leaves pois empty if current location is null', () async {
    // Arrange
    when(mockMapService.getCurrentLocation()).thenAnswer((_) async => null);
    await poiViewModel.refreshLocation();

    // Act
    await poiViewModel.init();

    // Assert
    expect(poiViewModel.hasLocationPermission, false);
    expect(poiViewModel.locationErrorMessage, "Unable to get current location");
    expect(poiViewModel.currentLocation, isNull);
    expect(poiViewModel.allPOIs, isEmpty);
  });

  test('init creates outdoor and indoor pois', () async {
    await poiViewModel.init();

    expect(poiViewModel.allPOIs, isNotEmpty);
    expect(poiViewModel.outdoorPOIs, isNotEmpty);
    expect(poiViewModel.outdoorPOIs.length, 2);
  });

  test('setTravelMode updates travel mode', () async {
    await poiViewModel.setTravelMode(TravelMode.WALK);

    expect(poiViewModel.travelMode, TravelMode.WALK);
    expect(poiViewModel.outdoorPOIs, isNotNull);
  });

  test('setOutdoorCategory updates category', () async {
    await poiViewModel.init();
    await poiViewModel.setOutdoorCategory(PlaceType.foodDrink, true);

    expect(poiViewModel.outdoorPOIs, isNotEmpty);
    expect(poiViewModel.selectedOutdoorCategory, PlaceType.foodDrink);
  });

  test('applyRadiusChange loads outdoorPOIs', () async {
    await poiViewModel.init();
    await poiViewModel.applyRadiusChange();

    expect(poiViewModel.outdoorPOIs, isNotEmpty);
  });

  test('updatePlaceWithDistance update place', () async {
    await poiViewModel.init();
    final place = Place(
        id: "3",
        name: "PFK",
        location: const LatLng(45.496331463078164, -73.5786988913346),
        types: ["foodDrink"]);

    poiViewModel.updatePlaceWithDistance(0, place);

    expect(poiViewModel.outdoorPOIs[0], place);
  });

  group('POI Tests', () {
    test('get POI hashcode', () {
      final poi = POI(
          id: "1",
          name: "Bathroom",
          buildingId: "H",
          floor: "1",
          category: POICategory.washroom,
          x: 492,
          y: 678);

      expect(poi.hashCode, isA<int>());
    });

    test('POI toString was overwridden', () {
      final poi = POI(
          id: "1",
          name: "Bathroom",
          buildingId: "H",
          floor: "1",
          category: POICategory.washroom,
          x: 492,
          y: 678);

      expect(poi.toString(), "POI(name: Bathroom, floor: 1, building: H)");
    });
  });
}
