import 'package:flutter/material.dart';
import '../../widgets/settings_tile.dart';
import 'package:device_calendar/device_calendar.dart';

import 'common_app_bart.dart';

class SettingsPage extends StatefulWidget {
  final DeviceCalendarPlugin?
      plugin; // Optional parameter for dependency injection

  const SettingsPage({super.key, this.plugin});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  late final DeviceCalendarPlugin plugin; // Initialize this field

  @override
  void initState() {
    super.initState();
    // If no plugin is provided, create a new one
    plugin = widget.plugin ?? DeviceCalendarPlugin();
  }

  Future<void> checkCalendarPermission() async {
    final hasPermissions = await plugin.hasPermissions();

    if (mounted) {
      if (hasPermissions.isSuccess && hasPermissions.data == true) {
        // If permissions are granted, navigate to CalendarView
        await Navigator.pushNamed(context, '/CalendarSelectionView');
      } else {
        await Navigator.pushNamed(context, '/CalendarLinkView');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Settings"),
      body: Semantics(
        label: 'Customize the preferences of the application.',
        child: ListView(
          children: [
            SettingsTile(
              icon: Icons.calendar_today,
              title: 'My calendar',
              onTap: () => checkCalendarPermission(),
            ),
            SettingsTile(
              icon: Icons.tune,
              title: 'Preferences',
              onTap: () {
                Navigator.pushNamed(context, '/PreferencesPage');
              },
            ),
            SettingsTile(
              icon: Icons.accessibility,
              title: 'Accessibility',
              onTap: () {
                Navigator.pushNamed(context, '/AccessibilityPage');
              },
            ),
            SettingsTile(
              icon: Icons.phone,
              title: 'Contact',
              onTap: () {
                Navigator.pushNamed(context, '/ContactPage');
              },
            ),
            SettingsTile(
              icon: Icons.info_outline,
              title: 'Guide',
              onTap: () {
                Navigator.pushNamed(context, '/GuidePage');
              },
            ),
          ],
        ),
      ),
    );
  }
}
