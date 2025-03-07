import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/indoor_map_viewmodel.dart';

class FloorPlanWidget extends StatelessWidget {
  final IndoorMapViewModel indoorMapViewModel;
  final String floorPlanPath;
  final String semanticsLabel;
  final VoidCallback? onTap;

  const FloorPlanWidget({
    super.key,
    required this.indoorMapViewModel,
    required this.floorPlanPath,
    required this.semanticsLabel,
    this.onTap,
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
        scaleEnabled: false,
        panEnabled: true,
        boundaryMargin: const EdgeInsets.all(50.0),
        transformationController: indoorMapViewModel.transformationController,
        child: SizedBox(
          width: 1024,
          height: 1024,
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
            ],
          ),
        ),
      ),
    );
  }
}
