import 'package:flutter/foundation.dart';
import '../../data/domain-model/location.dart';
import '../../data/services/outdoor_directions_service.dart';

class NextClassViewModel extends ChangeNotifier {
  Location _startLocation;
  Location _endLocation;
  String? staticMapUrl;
  final ODSDirectionsService _odsDirectionsService;

  // Updated constructor to accept ODSDirectionsService
  NextClassViewModel({
    required Location startLocation,
    required Location endLocation,
    ODSDirectionsService? odsDirectionsService,
  })  : _startLocation = startLocation,
        _endLocation = endLocation,
        _odsDirectionsService = odsDirectionsService ?? ODSDirectionsService();

  Location get startLocation => _startLocation;
  Location get endLocation => _endLocation;

  void updateLocations({
    required Location startLocation,
    required Location endLocation,
  }) {
    _startLocation = startLocation;
    _endLocation = endLocation;
    notifyListeners();
  }

  Future<String?> fetchStaticMapWithSize(int width, int height) async {
    final origin = "${_startLocation.lat},${_startLocation.lng}";
    final destination = "${_endLocation.lat},${_endLocation.lng}";

    staticMapUrl = await _odsDirectionsService.fetchStaticMapUrl(
      originAddress: origin,
      destinationAddress: destination,
      width: width,
      height: height,
    );
    notifyListeners();
    return staticMapUrl;
  }
}
