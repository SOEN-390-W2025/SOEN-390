import 'package:flutter/material.dart';

class PreferencesModel extends ChangeNotifier {
  String _selectedTransportation = 'Driving';
  String _selectedMeasurementUnit = 'Metric';

  String get selectedTransportation => _selectedTransportation;
  String get selectedMeasurementUnit => _selectedMeasurementUnit;

  void updateTransportation(String newTransportation) {
    if (newTransportation != _selectedTransportation) {
      _selectedTransportation = newTransportation;
      notifyListeners();
    }
  }

  void updateMeasurementUnit(String newMeasurementUnit) {
    if (newMeasurementUnit != _selectedMeasurementUnit) {
      _selectedMeasurementUnit = newMeasurementUnit;
      notifyListeners();
    }
  }
}
