import 'package:flutter/material.dart';
import '../../widgets/settings_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
            onTap: () {
              // TODO: Implement navigation to Calendar page.
            },
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
              // TODO: Implement navigation to Accessibility page
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
