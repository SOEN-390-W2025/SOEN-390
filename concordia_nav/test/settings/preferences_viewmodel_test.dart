import 'package:concordia_nav/utils/settings/preferences_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  group('PreferencesModel tests', () {
    test('updateTransportation changes the default method', () {
      final preferencesModel = PreferencesModel();
      final ogTransportation = preferencesModel.selectedTransportation;

      preferencesModel.updateTransportation('Walking');

      // Verify selected transportation updated
      expect(preferencesModel.selectedTransportation, isNot(ogTransportation));
      expect(preferencesModel.selectedTransportation, 'Walking');
    });

    test('updateMeasurementUnit updates default unit', () {
      final preferencesModel = PreferencesModel();
      final ogMeasurement = preferencesModel.selectedMeasurementUnit;

      preferencesModel.updateMeasurementUnit('Imperial');

      // Verify selected measurement unit updated
      expect(preferencesModel.selectedMeasurementUnit, isNot(ogMeasurement));
      expect(preferencesModel.selectedMeasurementUnit, 'Imperial');
    });
  });
}