import 'package:flutter/foundation.dart';

import '../../data/domain-model/location.dart';
import '../../data/domain-model/travelling_salesman_request.dart';
import '../../data/services/smart_planner_service.dart';

class SmartPlannerViewModel extends ChangeNotifier {
  final SmartPlannerService _service;
  TravellingSalesmanRequest? _plannerRequest;
  bool _isLoading = false;
  String? _errorMessage;

  SmartPlannerViewModel({SmartPlannerService? service})
      : _service = service ?? SmartPlannerService();

  TravellingSalesmanRequest? get plannerRequest => _plannerRequest;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Calls the service to generate planner data using the given natural
  /// language prompt, start time, and start location. If, for any reason,
  /// any of the three values are considered invalid, an error is thrown.
  Future<void> generatePlan({
    required String prompt,
    required DateTime startTime,
    required Location startLocation,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _plannerRequest = await _service.generatePlannerData(
        prompt: prompt,
        startTime: startTime,
        startLocation: startLocation,
      );
    } on Error catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
