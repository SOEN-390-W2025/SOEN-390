import 'dart:developer';

import 'package:flutter/material.dart';
import '../../data/repositories/indoor_feature_repository.dart';
import '../../data/services/indoor_routing_service.dart';
import '../../widgets/settings_tile.dart';
import 'package:device_calendar/device_calendar.dart';

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
        await Navigator.pushNamed(context, '/CalendarView');
      } else {
        await Navigator.pushNamed(context, '/CalendarLinkView');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    log("hello there");

    // var elevatorToHanna = IndoorRoutingService.getIndoorRoute(
    //     IndoorFeatureRepository
    //         .connectionsByBuilding["H"]![0].floorPoints["8"]!,
    //     IndoorFeatureRepository.roomsByFloor["H"]!["8"]![0].entrancePoint!,
    //     true);

    var entranceToHanna = IndoorRoutingService.getIndoorRoute(
        IndoorFeatureRepository.outdoorExitPointsByBuilding["H"]!,
        IndoorFeatureRepository.roomsByFloor["H"]!["8"]![0].entrancePoint!,
        false);

    log(entranceToHanna.firstBuilding.abbreviation);
    log(entranceToHanna.firstIndoorConnection?.name ?? "no connection");
    int i = 0;
    for (var point in entranceToHanna.firstIndoorPortionFromConnection ?? []) {
      log(i.toString() +
          " " +
          point.positionX.toString() +
          " " +
          point.positionY.toString());
      i += 1;
    }

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
            onTap: () => checkCalendarPermission(),
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
              Navigator.pushNamed(context, '/AccessibilityPage');
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
