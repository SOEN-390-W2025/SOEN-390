import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/settings/preferences_viewmodel.dart';
import '../../../widgets/custom_appbar.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  static const List<String> _transportationOptions = [
    'Driving',
    'Walking',
    'Biking',
    'Transit'
  ];

  static const Map<String, IconData> _transportationIcons = {
    'Driving': Icons.directions_car,
    'Walking': Icons.directions_walk,
    'Biking': Icons.directions_bike,
    'Transit': Icons.directions_transit,
  };

  static const List<String> _measurementOptions = [
    'Metric',
    'Imperial',
  ];

  static const Map<String, String> _measurementIndicators = {
    'Metric': 'm',
    'Imperial': 'yd',
  };

  @override
  Widget build(BuildContext context) {
    // Get theme colors
    final primaryColor = Theme.of(context).primaryColor;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final dividerColor = Theme.of(context).dividerColor;
    
    return Consumer<PreferencesModel>(
      builder: (context, preferences, child) {
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: customAppBar(context, 'Preferences'),
          body: Semantics(
            label: 'Explore general preference options.',
            child: ListView(
              children: [
                ListTile(
                  title: Text('Transportation Method', 
                      style: TextStyle(color: textColor)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButton<String>(
                        value: preferences.selectedTransportation,
                        icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            preferences.updateTransportation(newValue);
                          }
                        },
                        items: _transportationOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Icon(_transportationIcons[value], color: primaryColor),
                                const SizedBox(width: 8),
                                Text(value, style: TextStyle(color: textColor)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Divider(color: dividerColor),
                ListTile(
                  title: Text('Measurement Unit',
                      style: TextStyle(color: textColor)),
                  trailing: DropdownButton<String>(
                    value: preferences.selectedMeasurementUnit,
                    icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        preferences.updateMeasurementUnit(newValue);
                      }
                    },
                    items: _measurementOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          "$value (${_measurementIndicators[value]})",
                          style: TextStyle(color: textColor),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Divider(color: dividerColor),
              ],
            ),
          ),
        );
      },
    );
  }
}