import 'package:flutter/material.dart';
import '../../data/domain-model/concordia_campus.dart';
import 'ui/campus_map/campus_map_view.dart';
import 'ui/home/homepage_view.dart';
import 'ui/indoor_location/indoor_location_view.dart';
import 'ui/indoor_map/indoor_map_view.dart';
import 'ui/outdoor_location/outdoor_location_map_view.dart';
import 'ui/poi/poi_choice_view.dart';
import 'ui/poi/poi_map_view.dart';
import 'ui/setting/accessibility/accessibility_page.dart';
import 'ui/setting/calendar/calendar_link_view.dart';
import 'ui/setting/calendar/calendar_view.dart';
import 'ui/setting/settings_page.dart';
import 'ui/themes/app_theme.dart';
import 'widgets/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
                ModalRoute.of(context)!.settings.arguments as ConcordiaCampus),
        '/IndoorLocationView': (context) => const IndoorLocationView(),
        '/IndoorMapView': (context) => const IndoorMapView(),
        '/OutdoorLocationMapView': (context) => OutdoorLocationMapView(
            campus:
                ModalRoute.of(context)!.settings.arguments as ConcordiaCampus),
        '/POIChoiceView': (context) => const POIChoiceView(),
        '/POIMapView': (context) => const POIMapView(),
        '/AccessibilityPage': (context) => const AccessibilityPage(),
        '/CalendarLinkView': (context) => const CalendarLinkView(),
        '/CalendarView': (context) => const CalendarView(),
        '/SettingsPage': (context) => const SettingsPage(),
      },
    );
  }
}
