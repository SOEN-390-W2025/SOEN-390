import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import '../../data/domain-model/concordia_campus.dart';
import 'data/domain-model/concordia_building.dart';
import 'data/domain-model/location.dart';
import 'data/repositories/building_data_manager.dart';
import 'data/repositories/calendar.dart';
import 'ui/campus_map/campus_map_view.dart';
import 'ui/home/homepage_view.dart';
import 'ui/indoor_location/indoor_directions_view.dart';
import 'ui/indoor_location/indoor_location_view.dart';
import 'ui/indoor_map/building_selection.dart';
import 'ui/indoor_map/classroom_selection.dart';
import 'ui/journey/journey_view.dart';
import 'ui/next_class/next_class_directions_view.dart';
import 'ui/outdoor_location/outdoor_location_map_view.dart';
import 'utils/logger_util.dart';
import 'ui/poi/nearby_poi_map.dart';
import 'ui/poi/poi_choice_view.dart';
import 'ui/poi/poi_map_view.dart';
import 'ui/search/search_view.dart';
import 'ui/setting/accessibility/accessibility_page.dart';
import 'ui/setting/calendar/calendar_link_view.dart';
import 'ui/setting/calendar/calendar_selection_view.dart';
import 'ui/setting/calendar/calendar_view.dart';
import 'ui/setting/settings_page.dart';
import 'ui/smart_planner/generated_plan_view.dart';
import 'ui/smart_planner/smart_planner_view.dart';
import 'ui/themes/app_theme.dart';
import 'utils/poi/poi_viewmodel.dart';
import 'widgets/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:calendar_view/calendar_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  LoggerUtil.setLogLevel(LoggerUtil.stringToLevel(dotenv.env['LOG_LEVEL']));

  LoggerUtil.info('Application starting...');

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
          '/POIMapView': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            return POIMapView(
              poiName: args['poiName'] as String,
              poiChoiceViewModel: args['poiChoiceViewModel'] as POIViewModel,
            );
          },
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
          '/SmartPlannerView': (context) => const SmartPlannerView(),
          '/GeneratedPlanView': (context) => const GeneratedPlanView(),
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
            );
          },
          '/NextClassDirectionsPreview': (context) {
            final routeArgs = ModalRoute.of(context)!.settings.arguments;
            List<Location> locations = [];
            if (routeArgs is List<Location>) {
              locations = routeArgs;
            }
            return NextClassDirectionsPreview(journeyItems: locations);
          },
          '/NavigationJourneyPage': (context) {
            final routeArgs = ModalRoute.of(context)!.settings.arguments;
            String journeyName = "Navigation Journey";
            List<Location> locations = [];

            if (routeArgs is Map<String, dynamic>) {
              journeyName = routeArgs['journeyName'] ?? "Navigation Journey";
              if (routeArgs['journeyItems'] is List<Location>) {
                locations = routeArgs['journeyItems'];
              }
            }

            return NavigationJourneyPage(
                journeyName: journeyName, journeyItems: locations);
          },
          '/NearbyPOIMapView': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            return NearbyPOIMapView(
              poiViewModel: args['poiViewModel'],
              category: args['category'],
            );
          },
        },
      ),
    );
  }
}
