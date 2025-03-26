import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/settings/preferences_viewmodel.dart';

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
    return Consumer<PreferencesModel>(
      builder: (context, preferences, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: const Text(
              'Preferences',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          body: Semantics(
            label: 'Explore general preference options.',
            child: ListView(
              children: [
                ListTile(
                  title: const Text('Transportation Method'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButton<String>(
                        value: preferences.selectedTransportation,
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
                                Icon(_transportationIcons[value]),
                                const SizedBox(width: 8),
                                Text(value),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Measurement Unit'),
                  trailing: DropdownButton<String>(
                    value: preferences.selectedMeasurementUnit,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        preferences.updateMeasurementUnit(newValue);
                      }
                    },
                    items: _measurementOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child:
                            Text("$value (${_measurementIndicators[value]})"),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(),
              ],
            ),
          ),
        );
      },
    );
  }
}
