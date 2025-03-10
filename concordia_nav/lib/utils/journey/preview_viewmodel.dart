import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../data/services/building_service.dart';
import '../../data/services/outdoor_directions_service.dart';

class PreviewViewModel extends ChangeNotifier {
  final String sourceBuildingName;
  final String destBuildingName;
  ConcordiaBuilding? sourceBuilding;
  ConcordiaBuilding? destinationBuilding;
  String? staticMapUrl;

  PreviewViewModel({
    required this.sourceBuildingName,
    required this.destBuildingName,
  }) {
    sourceBuilding = BuildingService.getBuildingByName(sourceBuildingName);
    destinationBuilding = BuildingService.getBuildingByName(destBuildingName);
  }

  /// Fetch the static map URL using some hard-coded, default fixed size.
  Future<void> fetchStaticMap() async {
    await fetchStaticMapWithSize(600, 300);
  }

  /// Fetch the static map URL dynamically sized to the device's screen.
  Future<void> fetchStaticMapWithSize(int width, int height) async {
    if (sourceBuilding == null || destinationBuilding == null) {
      if (kDebugMode) {
        print(
            "fetchStaticMapWithSize: Building not found for one of the provided names.");
      }
      return;
    }
    final originAddress = "${sourceBuilding!.lat},${sourceBuilding!.lng}";
    final destinationAddress =
        "${destinationBuilding!.lat},${destinationBuilding!.lng}";
    final sourceLabel = sourceBuilding!.abbreviation[0];
    final destinationLabel = destinationBuilding!.abbreviation[0];

    staticMapUrl = await ODSDirectionsService().fetchStaticMapUrl(
      originAddress: originAddress,
      destinationAddress: destinationAddress,
      width: width,
      height: height,
      sourceLabel: sourceLabel,
      destinationLabel: destinationLabel,
    );
    notifyListeners();
  }
}
