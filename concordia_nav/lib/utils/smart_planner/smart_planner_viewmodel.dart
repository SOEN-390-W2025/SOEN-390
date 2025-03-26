import 'package:flutter/foundation.dart';
import '../../data/domain-model/location.dart';
import '../../data/services/smart_planner_service.dart';

class SmartPlannerViewModel extends ChangeNotifier {
  final SmartPlannerService _service;
  List<(String, Location, DateTime, DateTime)>? _optimizedRoute;
  bool _isLoading = false;
  String? _errorMessage;

  SmartPlannerViewModel({SmartPlannerService? service})
      : _service = service ?? SmartPlannerService();

  List<(String, Location, DateTime, DateTime)>? get optimizedRoute =>
      _optimizedRoute;
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
      _optimizedRoute = await _service.generateOptimizedRoute(
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
