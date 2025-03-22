import 'package:flutter/material.dart';
import '../data/domain-model/place.dart';
import '../utils/building_viewmodel.dart';
import '../utils/map_viewmodel.dart';

class CompactSearchCardWidget extends StatelessWidget {
  final TextEditingController originController;
  final TextEditingController destinationController;
  final MapViewModel mapViewModel;
  final List<String> searchList;
  final bool drawer;
  final VoidCallback? onDirectionFetched;
  final Place? selectedPlace; // Add this parameter

  const CompactSearchCardWidget({
    super.key,
    required this.originController,
    required this.destinationController,
    required this.mapViewModel,
    required this.searchList,
    this.drawer = false,
    this.onDirectionFetched,
    this.selectedPlace, // Optional parameter for the selected POI
  });

  Future<void> getDirections() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (originController.text.isEmpty || destinationController.text.isEmpty) {
      // Handle empty input case
      return;
    }

    // Get the start and end locations
    final startLocation = originController.text;
    final endLocation = destinationController.text;
    
    await mapViewModel.fetchRoutesForAllModes(startLocation, endLocation);

    onDirectionFetched?.call();
  }

  Future<void> handleSelection(
      BuildContext context, TextEditingController controller) async {
    // If this is the destination controller and we have a selected place, don't do anything
    if (controller == destinationController && selectedPlace != null) {
      return;
    }
    
    final result = await Navigator.pushNamed(
      context,
      '/SearchView',
      arguments: searchList,
    );

    if (result == null) return;

    final selectedBuilding = (result as List)[0];
    final currentLocation = (result)[1];

    controller.text = selectedBuilding;

    if (drawer) {
      if (selectedBuilding != 'Your Location') {
        final building =
            BuildingViewModel().getBuildingByName(selectedBuilding);
        mapViewModel.selectBuilding(building!);
      } else {
        // If the selected building is "Your Location", check for building at current location
        if (context.mounted) {
          await mapViewModel.checkBuildingAtCurrentLocation(context);
        }
      }
      if (context.mounted) {
        await mapViewModel.handleSelection(
          selectedBuilding as String,
          currentLocation,
        );
      }
    } else {
      await getDirections();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.radio_button_checked,
                  color: Color.fromRGBO(146, 35, 56, 1),
                ),
                VerticalDottedLine(
                  height: 20,
                  color: Colors.grey,
                  dashHeight: 3,
                  dashSpace: 3,
                  strokeWidth: 2,
                ),
                Icon(
                  Icons.location_on,
                  color: Color(0xFFDA3A16),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: originController,
                      style: const TextStyle(fontSize: 16),
                      enabled: selectedPlace == null,
                      decoration: InputDecoration(
                        hintText: 'Your Location',
                        border: InputBorder.none,
                        isDense: true,
                        hintStyle: TextStyle(
                          color: selectedPlace != null
                              ? Colors.grey[400]
                              : Colors.black,
                        ),
                      ),
                      onTap: () {
                        if (selectedPlace == null) {
                          if (mapViewModel.selectedBuildingNotifier.value != null) {
                            mapViewModel.unselectBuilding();
                          }
                          handleSelection(context, originController);
                        }
                      },
                    ),
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Colors.grey[300],
                    ),
                    TextField(
                      controller: destinationController,
                      style: const TextStyle(fontSize: 16),
                      enabled: selectedPlace == null,
                      decoration: InputDecoration(
                        hintText: 'Enter Destination',
                        border: InputBorder.none,
                        isDense: true,
                        hintStyle: TextStyle(
                          color: selectedPlace != null
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                      onTap: () {
                        if (selectedPlace == null) {
                          if (mapViewModel.selectedBuildingNotifier.value != null) {
                            mapViewModel.unselectBuilding();
                          }
                          handleSelection(context, destinationController);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  final Color color;
  final double dashHeight;
  final double dashSpace;
  final double strokeWidth;

  DottedLinePainter({
    required this.color,
    this.dashHeight = 4,
    this.dashSpace = 4,
    this.strokeWidth = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(DottedLinePainter oldDelegate) => false;
}

class VerticalDottedLine extends StatelessWidget {
  final double height;
  final Color color;
  final double dashHeight;
  final double dashSpace;
  final double strokeWidth;

  const VerticalDottedLine({
    super.key,
    required this.height,
    this.color = Colors.grey,
    this.dashHeight = 4,
    this.dashSpace = 4,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(1, height),
      painter: DottedLinePainter(
        color: color,
        dashHeight: dashHeight,
        dashSpace: dashSpace,
        strokeWidth: strokeWidth,
      ),
    );
  }
}