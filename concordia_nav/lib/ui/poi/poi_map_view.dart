// poi_map_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/domain-model/poi.dart';
import '../../utils/building_viewmodel.dart';
import '../../utils/indoor_directions_viewmodel.dart';
import '../../utils/indoor_map_viewmodel.dart';
import '../../utils/poi/poi_map_viewmodel.dart'; // New ViewModel
import '../../utils/poi/poi_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/floor_button.dart';
import '../../widgets/poi_bottom_sheet.dart';
import '../../widgets/radius_bar.dart';
import '../indoor_location/floor_plan_widget.dart';

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
  State<POIMapView> createState() => _POIMapViewState();
}

class _POIMapViewState extends State<POIMapView>
    with SingleTickerProviderStateMixin {
  late IndoorMapViewModel _indoorMapViewModel;
  late POIMapViewModel _poiMapViewModel;

  @override
  void initState() {
    super.initState();
    // Initialize ViewModels
    _indoorMapViewModel = IndoorMapViewModel(vsync: this);
    _indoorMapViewModel.setInitialCameraPosition(
      scale: 1.0,
      offsetX: -50.0,
      offsetY: -50.0,
    );

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
      _poiMapViewModel.loadPOIData(
          initialBuilding: widget.initialBuilding,
          initialFloor: widget.initialFloor);
    });
  }

  @override
  void dispose() {
    _indoorMapViewModel.dispose();
    _poiMapViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use ChangeNotifierProvider for reactive UI updates
    return ChangeNotifierProvider.value(
      value: _poiMapViewModel,
      child: Consumer<POIMapViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
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
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (viewModel.errorMessage.isNotEmpty) {
      return _buildErrorView(viewModel);
    } else if (!viewModel.floorPlanExists) {
      return const Center(
        child: Text(
          'No floor plans exist at this time.',
          style: TextStyle(fontSize: 18),
        ),
      );
    } else {
      // If data is loaded and floor plan exists, show the floor plan
      // Check if we need to pan to the first POI
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (viewModel.poisOnCurrentFloor.isNotEmpty) {
          viewModel.panToFirstPOI(MediaQuery.of(context).size);
        }
      });

      return _buildFloorPlanView(viewModel);
    }
  }

  Widget _buildErrorView(POIMapViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            viewModel.errorMessage,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.retry(
                initialBuilding: widget.initialBuilding,
                initialFloor: widget.initialFloor),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorPlanView(POIMapViewModel viewModel) {
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
                onPoiTap: (poi) => _showPOIDetails(poi, viewModel),
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
                  onFloorChanged: (floor) => viewModel.changeFloor(floor),
                ),
              ),

              // No POIs message overlay
              if (viewModel.noPoisOnCurrentFloor)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(225),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(100),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      'No ${widget.poiName} within ${viewModel.searchRadius} meters on floor ${viewModel.selectedFloor}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
        ),
      ],
    );
  }

  void _showPOIDetails(POI poi, POIMapViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) => POIBottomSheet(
          buildingName: viewModel.nearestBuilding!.name, 
          poi: poi)
    );
  }
}
