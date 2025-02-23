import 'package:concordia_nav/data/domain-model/concordia_building.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:concordia_nav/ui/campus_map/campus_map_view.dart';
import 'package:concordia_nav/ui/home/homepage_view.dart';
import 'package:concordia_nav/utils/map_viewmodel.dart';
import 'package:concordia_nav/utils/splash_screen_viewmodel.dart';
import 'package:concordia_nav/widgets/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'map/map_viewmodel_test.mocks.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  late SplashScreenViewModel splashScreenViewModel;
  late MockMapViewModel mockMapViewModel;
  late MapViewModel realMapViewModel;
  final mockResponse = {
    'polygons': <Polygon>{const Polygon(polygonId: PolygonId('1'))},
    'labels': <Marker>{const Marker(markerId: MarkerId('1'))},
  };

  setUp(() {
    mockMapViewModel = MockMapViewModel();
    realMapViewModel = MapViewModel();
    splashScreenViewModel = SplashScreenViewModel();
    splashScreenViewModel =
        SplashScreenViewModel(mapViewModel: mockMapViewModel);

    when(mockMapViewModel.selectedBuildingNotifier)
        .thenReturn(ValueNotifier<ConcordiaBuilding?>(null));
    when(mockMapViewModel.startShuttleBusTimer()).thenAnswer((_) async => true);
  });

  group('navigateBasedOnLocation', () {

    testWidgets('should navigate to home when location access is denied',
        (WidgetTester tester) async {
      // Arrange
      final routes = {
        '/': (context) => SplashScreen(viewModel: splashScreenViewModel),
        '/HomePage': (context) => const HomePage(),
        '/CampusMapPage': (context) => CampusMapPage(
            campus:
                ModalRoute.of(context)!.settings.arguments as ConcordiaCampus,
            mapViewModel: mockMapViewModel),
      };

      when(mockMapViewModel.checkLocationAccess())
          .thenAnswer((_) async => false);

      // Act
      await tester.pumpWidget(MaterialApp(initialRoute: '/', routes: routes));
      await tester.pumpAndSettle();

      // Assert
      verify(mockMapViewModel.checkLocationAccess()).called(1);
      verifyNever(mockMapViewModel.fetchCurrentLocation());
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should navigate to home when location cannot be determined',
        (WidgetTester tester) async {
      // Arrange
      when(mockMapViewModel.checkLocationAccess())
          .thenAnswer((_) async => true);

      when(mockMapViewModel.fetchCurrentLocation())
          .thenAnswer((_) async => null);

      final routes = {
        '/': (context) => SplashScreen(viewModel: splashScreenViewModel),
        '/HomePage': (context) => const HomePage(),
        '/CampusMapPage': (context) => CampusMapPage(
            campus:
                ModalRoute.of(context)!.settings.arguments as ConcordiaCampus,
            mapViewModel: mockMapViewModel),
      };

      // Act
      await tester.pumpWidget(MaterialApp(initialRoute: '/', routes: routes));
      await tester.pumpAndSettle();

      // Assert
      verify(mockMapViewModel.checkLocationAccess()).called(1);
      verify(mockMapViewModel.fetchCurrentLocation()).called(1);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should navigate to SGW campus when user is within 1km of SGW',
        (WidgetTester tester) async {
      // Arrange
      final mockResponse = {
        'polygons': <Polygon>{const Polygon(polygonId: PolygonId('1'))},
        'labels': <Marker>{const Marker(markerId: MarkerId('1'))},
      };

      when(mockMapViewModel.checkLocationAccess())
          .thenAnswer((_) async => true);

      when(mockMapViewModel.fetchCurrentLocation())
          .thenAnswer((_) async => const LatLng(45.497, -73.579)); // Near SGW

      when(mockMapViewModel.getDistance(
              any, LatLng(ConcordiaCampus.sgw.lat, ConcordiaCampus.sgw.lng)))
          .thenReturn(500.0); // Within 1km

      when(mockMapViewModel.getDistance(
              any, LatLng(ConcordiaCampus.loy.lat, ConcordiaCampus.loy.lng)))
          .thenReturn(5000.0); // More than 1km

      when(mockMapViewModel.getInitialCameraPosition(any))
          .thenAnswer((_) async {
        return const CameraPosition(
            target: LatLng(45.4215, -75.6992), zoom: 10);
      });

      when(mockMapViewModel.getCampusPolygonsAndLabels(ConcordiaCampus.sgw))
          .thenAnswer((_) async => mockResponse);

      final routes = {
        '/': (context) => SplashScreen(viewModel: splashScreenViewModel),
        '/HomePage': (context) => const HomePage(),
        '/CampusMapPage': (context) => CampusMapPage(
            campus:
                ModalRoute.of(context)!.settings.arguments as ConcordiaCampus,
            mapViewModel: mockMapViewModel),
      };

      // Act
      await tester.pumpWidget(MaterialApp(initialRoute: '/', routes: routes));
      await tester.pumpAndSettle();

      // Assert
      verify(mockMapViewModel.checkLocationAccess()).called(2);
      verify(mockMapViewModel.fetchCurrentLocation()).called(1);
      expect(find.byType(CampusMapPage), findsOneWidget);
    });

    testWidgets(
        'should navigate to Loyola campus when user is within 1km of Loyola',
        (WidgetTester tester) async {
      // Arrange

      final double distanceToLoy = realMapViewModel.getDistance(
          const LatLng(45.458, -73.639),
          LatLng(ConcordiaCampus.loy.lat, ConcordiaCampus.loy.lng));

      when(mockMapViewModel.checkLocationAccess())
          .thenAnswer((_) async => true);

      when(mockMapViewModel.fetchCurrentLocation())
          .thenAnswer((_) async => const LatLng(45.458, -73.639)); // Near LOY

      when(mockMapViewModel.getDistance(const LatLng(45.458, -73.639),
              LatLng(ConcordiaCampus.loy.lat, ConcordiaCampus.loy.lng)))
          .thenReturn(distanceToLoy); // Within 1km

      when(mockMapViewModel.getDistance(const LatLng(45.458, -73.639),
              LatLng(ConcordiaCampus.sgw.lat, ConcordiaCampus.sgw.lng)))
          .thenReturn(5000.0); // More than 1km

      when(mockMapViewModel.getInitialCameraPosition(any))
          .thenAnswer((_) async {
        return const CameraPosition(
            target: LatLng(45.4215, -75.6992), zoom: 10);
      });

      when(mockMapViewModel.getInitialCameraPosition(any))
          .thenAnswer((_) async {
        return const CameraPosition(target: LatLng(45.458, -73.639), zoom: 10);
      });

      when(mockMapViewModel.getCampusPolygonsAndLabels(ConcordiaCampus.loy))
          .thenAnswer((_) async => mockResponse);

      final routes = {
        '/': (context) => SplashScreen(viewModel: splashScreenViewModel),
        '/HomePage': (context) => const HomePage(),
        '/CampusMapPage': (context) => CampusMapPage(
            campus:
                ModalRoute.of(context)!.settings.arguments as ConcordiaCampus,
            mapViewModel: mockMapViewModel),
      };

      // Act
      await tester.pumpWidget(MaterialApp(initialRoute: '/', routes: routes));
      await tester.pumpAndSettle();

      // Assert
      verify(mockMapViewModel.checkLocationAccess()).called(2);
      verify(mockMapViewModel.fetchCurrentLocation()).called(1);
      expect(find.byType(CampusMapPage), findsOneWidget);
    });

    testWidgets(
        'should navigate to home when user is not within 1km of either campus',
        (WidgetTester tester) async {
      // Arrange
      when(mockMapViewModel.checkLocationAccess())
          .thenAnswer((_) async => true);
      when(mockMapViewModel.fetchCurrentLocation()).thenAnswer(
          (_) async => const LatLng(45.500, -73.600)); // Far from both
      when(mockMapViewModel.getDistance(any, any))
          .thenReturn(1500.0); // Beyond 1km
      when(mockMapViewModel.getInitialCameraPosition(any))
          .thenAnswer((_) async {
        return const CameraPosition(target: LatLng(45.458, -73.639), zoom: 10);
      });
      when(mockMapViewModel.getCampusPolygonsAndLabels(ConcordiaCampus.sgw))
          .thenAnswer((_) async => mockResponse);

      final routes = {
        '/': (context) => SplashScreen(viewModel: splashScreenViewModel),
        '/HomePage': (context) => const HomePage(),
        '/CampusMapPage': (context) => CampusMapPage(
            campus:
                ModalRoute.of(context)!.settings.arguments as ConcordiaCampus,
            mapViewModel: mockMapViewModel),
      };

      // Act
      await tester.pumpWidget(MaterialApp(initialRoute: '/', routes: routes));
      await tester.pumpAndSettle();

      // Assert
      verify(mockMapViewModel.checkLocationAccess()).called(1);
      verify(mockMapViewModel.fetchCurrentLocation()).called(1);
    });

    testWidgets('should navigate to home when an exception occurs',
        (WidgetTester tester) async {
      // Arrange
      when(mockMapViewModel.checkLocationAccess())
          .thenThrow(Exception('Error'));

      final routes = {
        '/': (context) => SplashScreen(viewModel: splashScreenViewModel),
        '/HomePage': (context) => const HomePage(),
        '/CampusMapPage': (context) => CampusMapPage(
            campus:
                ModalRoute.of(context)!.settings.arguments as ConcordiaCampus,
            mapViewModel: mockMapViewModel),
      };

      // Act
      await tester.pumpWidget(MaterialApp(initialRoute: '/', routes: routes));
      await tester.pumpAndSettle();

      // Assert
      verify(mockMapViewModel.checkLocationAccess()).called(1);
      verifyNever(mockMapViewModel.fetchCurrentLocation());
    });
  });
}
