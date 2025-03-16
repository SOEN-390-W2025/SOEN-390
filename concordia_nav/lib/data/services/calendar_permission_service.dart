import 'package:flutter/material.dart';
import 'package:device_calendar/device_calendar.dart';

class CalendarPermissionService {
  final DeviceCalendarPlugin plugin;

  CalendarPermissionService({DeviceCalendarPlugin? plugin})
      : plugin = plugin ?? DeviceCalendarPlugin();

  Future<void> checkCalendarPermission(BuildContext context) async {
    final hasPermissions = await plugin.hasPermissions();

    if (!context.mounted) return;

    if (hasPermissions.isSuccess && hasPermissions.data == true) {
      // If permissions are granted, navigate to CalendarView
      await Navigator.pushNamed(context, '/CalendarSelectionView');
    } else {
      await Navigator.pushNamed(context, '/CalendarLinkView');
    }
  }
}
