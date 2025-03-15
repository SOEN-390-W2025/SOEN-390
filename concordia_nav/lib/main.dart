import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import '../../data/domain-model/concordia_campus.dart';
import 'data/domain-model/concordia_building.dart';
import 'data/repositories/building_data_manager.dart';
import 'data/repositories/calendar.dart';
import 'ui/campus_map/campus_map_view.dart';
import 'ui/home/homepage_view.dart';
import 'ui/indoor_location/indoor_directions_view.dart';
import 'ui/indoor_location/indoor_location_view.dart';
import 'ui/indoor_map/building_selection.dart';
import 'ui/indoor_map/classroom_selection.dart';
import 'ui/next_class/next_class_directions_preview.dart';
import 'ui/outdoor_location/outdoor_location_map_view.dart';
import 'ui/poi/poi_choice_view.dart';
import 'ui/poi/poi_map_view.dart';
import 'ui/search/search_view.dart';
import 'ui/setting/accessibility/accessibility_page.dart';
import 'ui/setting/calendar/calendar_link_view.dart';
import 'ui/setting/calendar/calendar_selection_view.dart';
import 'ui/setting/calendar/calendar_view.dart';
import 'ui/setting/settings_page.dart';
import 'ui/themes/app_theme.dart';
import 'widgets/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:calendar_view/calendar_view.dart';

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
    return CalendarControllerProvider(
      controller: EventController(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/HomePage': (context) => const HomePage(),
          '/CampusMapPage': (context) => CampusMapPage(
              campus: ModalRoute.of(context)!.settings.arguments
                  as ConcordiaCampus),
          '/IndoorLocationView': (context) => IndoorLocationView(
                building: ModalRoute.of(context)!.settings.arguments
                    as ConcordiaBuilding,
              ),
          '/BuildingSelection': (context) => const BuildingSelection(),
          '/OutdoorLocationMapView': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            return OutdoorLocationMapView(
              campus: args['campus'] as ConcordiaCampus,
              building: args['building'] as ConcordiaBuilding?,
            );
          },
          '/POIChoiceView': (context) => const POIChoiceView(),
          '/POIMapView': (context) => const POIMapView(),
          '/AccessibilityPage': (context) => const AccessibilityPage(),
          '/CalendarLinkView': (context) => const CalendarLinkView(),
          '/CalendarSelectionView': (context) => const CalendarSelectionView(),
          '/CalendarView': (context) => CalendarView(
                selectedCalendar:
                    ModalRoute.of(context)!.settings.arguments as UserCalendar,
              ),
          '/SettingsPage': (context) => const SettingsPage(),
          '/SearchView': (context) => const SearchView(),
          '/SelectBuilding': (context) => const BuildingSelection(),
          '/IndoorDirectionsView': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            return IndoorDirectionsView(
              sourceRoom: args['sourceRoom'] as String,
              building: args['building'] as String,
              endRoom: args['endRoom'] as String,
            );
          },
          '/ClassroomSelection': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            return ClassroomSelection(
              building: args['building'] as String,
              floor: args['floor'] as String,
              currentRoom: args['currentRoom'] as String,
              isSource: args['isSource'] as bool? ?? false,
              isSearch: args['isSearch'] as bool? ?? false,
              isDisability: args['isDisability'] as bool? ?? false,
              routeType: args['routeType'] as NavigationRouteType? ??
                  NavigationRouteType.indoor,
            );
          },
          '/NextClassDirectionsPreview': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            return NextClassDirectionsPreview(
              sourceRoom: args['sourceRoom'] as String,
              sourceBuilding: args['sourceBuilding'] as String,
              sourceFloor: args['sourceFloor'] as String,
              destRoom: args['destRoom'] as String,
              destBuilding: args['destBuilding'] as String,
              destFloor: args['destFloor'] as String,
              routeType: args['routeType'] as NavigationRouteType? ??
                  NavigationRouteType.indoor,
            );
          },
        },
      ),
    );
  }
}
