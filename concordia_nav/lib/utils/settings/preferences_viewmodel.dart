import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesModel extends ChangeNotifier {
  static const String _keySelectedTransportation = 'selected_transportation';
  static const String _keySelectedMeasurementUnit = 'selected_measurement_unit';

  String _selectedTransportation = 'Driving';
  String _selectedMeasurementUnit = 'Metric';

  String get selectedTransportation => _selectedTransportation;
  String get selectedMeasurementUnit => _selectedMeasurementUnit;

  PreferencesModel() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedTransportation =
        prefs.getString(_keySelectedTransportation) ?? 'Driving';
    _selectedMeasurementUnit =
        prefs.getString(_keySelectedMeasurementUnit) ?? 'Metric';
    notifyListeners();
  }

  Future<void> updateTransportation(String newTransportation) async {
    if (newTransportation != _selectedTransportation) {
      _selectedTransportation = newTransportation;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySelectedTransportation, newTransportation);
      notifyListeners();
    }
  }

  Future<void> updateMeasurementUnit(String newMeasurementUnit) async {
    if (newMeasurementUnit != _selectedMeasurementUnit) {
      _selectedMeasurementUnit = newMeasurementUnit;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySelectedMeasurementUnit, newMeasurementUnit);
      notifyListeners();
    }
  }
}
