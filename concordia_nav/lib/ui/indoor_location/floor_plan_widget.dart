import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/domain-model/poi.dart';
import '../../utils/indoor_directions_viewmodel.dart';
import '../../utils/indoor_map_viewmodel.dart';
import '../../widgets/indoor/indoor_path.dart';

import 'dart:developer' as dev;
class FloorPlanWidget extends StatelessWidget {
  final IndoorMapViewModel indoorMapViewModel;
  final String floorPlanPath;
  final String semanticsLabel;
  final IndoorDirectionsViewModel? viewModel;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final bool highlightCurrentStep;
  final Offset? currentStepPoint;
  final bool showStepView;
  final List<POI>? pois;
  final Function(POI)? onPoiTap;
  final Offset? currentLocation;


  const FloorPlanWidget({
    super.key,
    required this.indoorMapViewModel,
    required this.floorPlanPath,
    this.viewModel,
    required this.semanticsLabel,
    required this.width,
    required this.height,
    this.onTap,
    this.highlightCurrentStep = false,
    this.currentStepPoint,
    this.showStepView = false,
    this.pois,
    this.onPoiTap,
    this.currentLocation
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (details) {
        final tapPosition = details.localPosition;
        indoorMapViewModel.panToRegion(
          offsetX: -tapPosition.dx,
          offsetY: -tapPosition.dy,
        );
      },
      child: InteractiveViewer(
        constrained: false,
        panEnabled: true,
        boundaryMargin: const EdgeInsets.all(50.0),
        transformationController: indoorMapViewModel.transformationController,
        minScale: 0.6,
        maxScale: 1.5,
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              SvgPicture.asset(
                floorPlanPath,
                fit: BoxFit.contain,
                semanticsLabel: semanticsLabel,
                placeholderBuilder: (context) =>
                    const Center(child: CircularProgressIndicator()),
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Text(
                    'No floor plans exist at this time.',
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                ),
              ),
              if (viewModel != null)
                CustomPaint(
                  painter: IndoorMapPainter(
                    route: viewModel!.calculatedRoute,
                    startLocation: viewModel!.startLocation,
                    endLocation: viewModel!.endLocation,
                    highlightCurrentStep: highlightCurrentStep,
                    currentStepPoint: currentStepPoint,
                    showStepView: showStepView,
                  ),
                  size: Size(width, height),
                ),
              if (pois != null)
                ...pois!.map((poi) => Positioned(
                      left: poi.x - 24,
                      top: poi.y - 26,
                      child: GestureDetector(
                        onTap: () {
                          dev.log('assets/icons/pois/${poi.category.toString().split('.').last}.png');
                          if (onPoiTap != null) onPoiTap!(poi);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/icons/pois/${poi.category.toString().split('.').last}.png',
                                width: 32,
                                height: 32,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.location_city,
                                  color: Colors.red,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
              // Current user location marker (white circle)
              if (currentLocation != null)
                Positioned(
                  left: currentLocation!.dx - 10,
                  top: currentLocation!.dy - 10,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color.fromARGB(90, 160, 160, 160),
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}