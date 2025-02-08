import 'package:flutter/material.dart';
import '../../widgets/settings_tile.dart';
import 'accessibility/accessibility_page.dart';
import 'calendar/calandar_view.dart';
import 'calendar/calendar_link_view.dart';
import 'package:device_calendar/device_calendar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  Future<void> checkCalendarPermission() async {
    final plugin = DeviceCalendarPlugin();
    final hasPermissions = await plugin.hasPermissions();

    if (mounted) {
      if (hasPermissions.isSuccess && hasPermissions.data == true) {
      // If permissions are granted, navigate to CalendarView
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CalendarView()),
        );
      } else {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CalendarLinkView()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        children: [
          SettingsTile(
            icon: Icons.calendar_today,
            title: 'My calendar',
            onTap: () => checkCalendarPermission()
          ),
          SettingsTile(
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () {
              // TODO: Implement navigation to Notifications page.
            },
          ),
          SettingsTile(
            icon: Icons.tune,
            title: 'Preferences',
            onTap: () {
              // TODO: Implement navigation to Preferences page.
            },
          ),
          SettingsTile(
            icon: Icons.accessibility,
            title: 'Accessibility',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (BuildContext context) {
                  return const AccessibilityPage();
                }),
              );
            },
          ),
          SettingsTile(
            icon: Icons.phone,
            title: 'Contact',
            onTap: () {
              // TODO: Implement navigation to Contact page.
            },
          ),
          SettingsTile(
            icon: Icons.info_outline,
            title: 'Guide',
            onTap: () {
              // TODO: Implement navigation to Guide page.
            },
          ),
        ],
      ),
    );
  }
}
