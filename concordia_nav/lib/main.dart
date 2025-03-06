import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import '../../data/domain-model/concordia_campus.dart';
import 'data/domain-model/concordia_building.dart';
import 'data/repositories/building_data_manager.dart';
import 'ui/campus_map/campus_map_view.dart';
import 'ui/home/homepage_view.dart';
import 'ui/indoor_location/floor_change_view_.dart';
import 'ui/indoor_location/indoor_directions_view.dart';
import 'ui/indoor_location/indoor_location_view.dart';
import 'ui/indoor_map/building_selection.dart';
import 'ui/indoor_map/classroom_selection.dart';
import 'ui/outdoor_location/outdoor_location_map_view.dart';
import 'ui/poi/poi_choice_view.dart';
import 'ui/poi/poi_map_view.dart';
import 'ui/search/search_view.dart';
import 'ui/setting/accessibility/accessibility_page.dart';
import 'ui/setting/calendar/calendar_link_view.dart';
import 'ui/setting/calendar/calendar_view.dart';
import 'ui/setting/settings_page.dart';
import 'ui/themes/app_theme.dart';
import 'widgets/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  try {
    await BuildingDataManager.initialize();
  } on Exception catch (e, stackTrace) {
    dev.log('Error initializing building data manager',
        error: e, stackTrace: stackTrace);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/HomePage': (context) => const HomePage(),
        '/CampusMapPage': (context) => CampusMapPage(
            campus:
                ModalRoute.of(context)!.settings.arguments as ConcordiaCampus
        ),
        '/IndoorLocationView': (context) => IndoorLocationView(
            building: ModalRoute.of(context)!.settings.arguments as ConcordiaBuilding,
        ),
        '/BuildingSelection': (context) => const BuildingSelection(),
        '/OutdoorLocationMapView': (context) => OutdoorLocationMapView(
            campus:
                ModalRoute.of(context)!.settings.arguments as ConcordiaCampus),
        '/POIChoiceView': (context) => const POIChoiceView(),
        '/POIMapView': (context) => const POIMapView(),
        '/AccessibilityPage': (context) => const AccessibilityPage(),
        '/CalendarLinkView': (context) => const CalendarLinkView(),
        '/CalendarView': (context) => const CalendarView(),
        '/SettingsPage': (context) => const SettingsPage(),
        '/SearchView': (context) => const SearchView(),
        '/SelectBuilding': (context) => const BuildingSelection(),
        '/IndoorDirectionsView': (context) => IndoorDirectionsView(
              sourceRoom: ModalRoute.of(context)!.settings.arguments as String,
              building: ModalRoute.of(context)!.settings.arguments as String,
              floor: ModalRoute.of(context)!.settings.arguments as String,
              endRoom: ModalRoute.of(context)!.settings.arguments as String,
        ),
        '/ClassroomSelection': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

          return ClassroomSelection(
            building: args['building'] as String,
            floor: args['floor'] as String,
            currentRoom: args['currentRoom'] as String,
            isSource: args['isSource'] as bool? ?? false,
          );
        },
        '/FloorChange': (context) => FloorChange(
              building: ModalRoute.of(context)!.settings.arguments as ConcordiaBuilding
        ),
      },
    );
  }
}
