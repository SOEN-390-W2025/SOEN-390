// ignore_for_file: avoid_catches_without_on_clauses

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/domain-model/poi.dart';
import '../../utils/building_viewmodel.dart';
import '../../utils/indoor_directions_viewmodel.dart';
import '../../utils/indoor_map_viewmodel.dart';
import '../../utils/poi/poi_map_viewmodel.dart';
import '../../utils/poi/poi_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/floor_button.dart';
import '../../widgets/poi_bottom_sheet.dart';
import '../../widgets/radius_bar.dart';
import '../indoor_location/floor_plan_widget.dart';
import 'dart:developer' as dev;

class POIMapView extends StatefulWidget {
  final String? initialBuilding;
  final String? initialFloor;
  final String poiName;
  final POIViewModel poiChoiceViewModel;
  final POIMapViewModel? poiMapViewModel;

  const POIMapView(
      {super.key,
      required this.poiName,
      required this.poiChoiceViewModel,
      this.initialBuilding,
      this.initialFloor,
      this.poiMapViewModel});

  @override
  State<POIMapView> createState() => POIMapViewState();
}

class POIMapViewState extends State<POIMapView>
    with SingleTickerProviderStateMixin {
  late IndoorMapViewModel _indoorMapViewModel;
  late POIMapViewModel _poiMapViewModel;
  bool _showUserGuide = true;
  Timer? _guideTimer;

  @override
  void initState() {
    super.initState();
    // Initialize ViewModels
    _indoorMapViewModel = IndoorMapViewModel(vsync: this);

    // Create the POIMapViewModel with its dependencies including IndoorMapViewModel
    // unless provided with one
    _poiMapViewModel = widget.poiMapViewModel ??
        POIMapViewModel(
          poiName: widget.poiName,
          buildingViewModel: BuildingViewModel(),
          indoorDirectionsViewModel: IndoorDirectionsViewModel(),
          indoorMapViewModel: _indoorMapViewModel,
        );

    // Load data after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _poiMapViewModel
          .loadPOIData(
              initialBuilding: widget.initialBuilding,
              initialFloor: widget.initialFloor)
          .then((_) {
        // After data is loaded, apply max zoom out
        if (!mounted) return;

        if (_poiMapViewModel.floorPlanExists) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            final screenSize = MediaQuery.of(context).size;
            _indoorMapViewModel.setInitialCameraPosition(
              viewportSize: screenSize,
              contentWidth: _poiMapViewModel.width,
              contentHeight: _poiMapViewModel.height,
            );
          });
        }
      });
    });

    // Auto-hide the user guide after 10 seconds
    _guideTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _showUserGuide = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _guideTimer?.cancel();
    _indoorMapViewModel.dispose();
    _poiMapViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get theme colors
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    // Use ChangeNotifierProvider for reactive UI updates
    return ChangeNotifierProvider.value(
      value: _poiMapViewModel,
      child: Consumer<POIMapViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: customAppBar(
              context,
              '${viewModel.nearestBuilding?.name ?? "Building"} - ${widget.poiName}',
            ),
            body: Semantics(
              label:
                  'Points of interest pertaining to floor plan. Adjust the search radius to present different results.',
              child: _buildBody(viewModel),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(POIMapViewModel viewModel) {
    // Get theme colors
    final primaryColor = Theme.of(context).primaryColor;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    if (viewModel.isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    } else if (viewModel.errorMessage.isNotEmpty) {
      return _buildErrorView(viewModel);
    } else if (!viewModel.floorPlanExists) {
      return Center(
        child: Text(
          'No floor plans exist at this time.',
          style: TextStyle(fontSize: 18, color: textColor),
        ),
      );
    } else {
      // If data is loaded and floor plan exists, show the floor plan
      return _buildFloorPlanView(viewModel);
    }
  }

  Widget _buildErrorView(POIMapViewModel viewModel) {
    // Get theme colors
    final primaryColor = Theme.of(context).primaryColor;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final errorColor = Theme.of(context).colorScheme.error;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            viewModel.errorMessage,
            style: TextStyle(color: errorColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.retry(
                initialBuilding: widget.initialBuilding,
                initialFloor: widget.initialFloor),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: onPrimaryColor,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorPlanView(POIMapViewModel viewModel) {
    // Get theme colors
    final cardColor = Theme.of(context).cardColor;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final shadowColor = Theme.of(context).shadowColor;
    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // Floor plan
              FloorPlanWidget(
                indoorMapViewModel: _indoorMapViewModel,
                floorPlanPath: viewModel.floorPlanPath,
                semanticsLabel:
                    'Floor plan of ${viewModel.nearestBuilding!.abbreviation}-${viewModel.selectedFloor}',
                width: viewModel.width,
                height: viewModel.height,
                pois: viewModel.poisOnCurrentFloor,
                onPoiTap: (poi) => showPOIDetails(poi, viewModel),
                currentLocation: viewModel.userPosition,
              ),

              // Floor selector button
              Positioned(
                top: 80,
                right: 16,
                child: FloorButton(
                  floor: viewModel.selectedFloor,
                  building: viewModel.nearestBuilding!,
                  poiName: widget.poiName,
                  poiChoiceViewModel: widget.poiChoiceViewModel,
                ),
              ),

              // User guide tooltip - shows initially and can be dismissed
              if (_showUserGuide && viewModel.poisOnCurrentFloor.isNotEmpty)
                Positioned(
                  top: 140,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showUserGuide = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: shadowColor.withAlpha(100),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tap an icon to select',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.close,
                              color: primaryColor,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // No POIs message overlay
              if (viewModel.noPoisOnCurrentFloor)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor.withAlpha(150),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor.withAlpha(100),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      'No ${widget.poiName} within ${viewModel.searchRadius} meters on floor ${viewModel.selectedFloor}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Radius Bar
        RadiusBar(
          initialValue: viewModel.searchRadius,
          minValue: 10.0,
          maxValue: 200.0,
          showMeters: true, // Use meters for indoor
          onRadiusChanged: (value) => viewModel.setSearchRadius(value),
          onRadiusChangeEnd: (value) {
            // Animate to max zoom out after radius adjustment is complete
            _animateToMaxZoomOut();
          },
        ),
      ],
    );
  }

  void showPOIDetails(POI poi, POIMapViewModel viewModel) {
    // Hide user guide when a POI is tapped
    if (_showUserGuide) {
      setState(() {
        _showUserGuide = false;
      });
    }

    showModalBottomSheet(
        context: context,
        builder: (context) => POIBottomSheet(
            buildingName: viewModel.nearestBuilding!.name, poi: poi));
  }

  // Helper method to animate to maximum zoom out
  void _animateToMaxZoomOut() {
    // Check if the widget is still mounted before accessing context
    if (!mounted) return;

    try {
      final screenSize = MediaQuery.of(context).size;

      // Use the minimum scale value from IndoorMapViewModel
      const minScale = 0.64;

      // Center the map in the viewport
      final offsetX =
          (screenSize.width - (_poiMapViewModel.width * minScale)) / 2;
      final offsetY =
          (screenSize.height - (_poiMapViewModel.height * minScale)) / 10;

      // Create the target matrix for animation
      final targetMatrix = Matrix4.identity()
        ..translate(offsetX, offsetY)
        ..scale(minScale);

      // Animate to the maximum zoom out
      _indoorMapViewModel.animateTo(targetMatrix);
    } catch (e) {
      // Handle any errors that might occur if the context is no longer valid
      dev.log('Error during max zoom out animation: $e');
    }
  }
}
