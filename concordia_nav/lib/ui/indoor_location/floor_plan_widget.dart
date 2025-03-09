import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/indoor_directions_viewmodel.dart';
import '../../utils/indoor_map_viewmodel.dart';
import '../../widgets/indoor/indoor_path.dart';

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
    this.showStepView = false

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
            ],
          ),
        ),
      ),
    );
  }
}