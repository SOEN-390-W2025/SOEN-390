import 'package:flutter/material.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../data/domain-model/concordia_campus.dart';
import '../../data/services/building_service.dart';
import '../../widgets/custom_appbar.dart';
import '../indoor_location/indoor_directions_view.dart';
import '../outdoor_location/outdoor_location_map_view.dart';

class NavigationJourneyPage extends StatefulWidget {
  final String sourceRoom;
  final String sourceBuilding;
  final String sourceFloor;
  final String destRoom;
  final String destBuilding;
  final String destFloor;

  const NavigationJourneyPage({
    super.key,
    required this.sourceRoom,
    required this.sourceBuilding,
    required this.sourceFloor,
    required this.destRoom,
    required this.destBuilding,
    required this.destFloor,
  });

  @override
  State<NavigationJourneyPage> createState() => NavigationJourneyPageState();
}

class NavigationJourneyPageState extends State<NavigationJourneyPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  late final List<Widget> _navPages;

  @override
  void initState() {
    super.initState();
    final bool isSameBuilding = widget.sourceBuilding.toLowerCase() ==
        widget.destBuilding.toLowerCase();
    if (isSameBuilding) {
      // For same-building navigation, only a single indoor view is required.
      _navPages = [
        IndoorDirectionsView(
          sourceRoom: widget.sourceRoom,
          building: widget.sourceBuilding,
          endRoom: widget.destRoom,
          isDisability: false,
          hideAppBar: true,
          hideIndoorInputs: true,
        ),
      ];
    } else {
      final ConcordiaBuilding? destBuildingObj =
          BuildingService.getBuildingByName(widget.destBuilding);
      final campus = destBuildingObj?.campus ?? ConcordiaCampus.sgw;

      // Unique Building to Unique Building case:
      // Show indoor and outdoor directions between both classes.
      _navPages = [
        IndoorDirectionsView(
          sourceRoom: widget.sourceRoom,
          building: widget.sourceBuilding,
          endRoom: "Your Location",
          isDisability: false,
          hideAppBar: true,
          hideIndoorInputs: true,
        ),
        OutdoorLocationMapView(
          campus: campus,
          building: destBuildingObj,
          hideAppBar: true,
          hideInputs: true,
        ),
        IndoorDirectionsView(
          sourceRoom: "Your Location",
          building: widget.destBuilding,
          endRoom: widget.destRoom,
          isDisability: false,
          hideAppBar: true,
          hideIndoorInputs: true,
        ),
      ];
    }

    _controller.addListener(() {
      final page = _controller.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
        });
      }
    });
  }

  void _nextPage() {
    if (_currentPage < _navPages.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, "Next Class Directions"),
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: _navPages,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF962e42),
            foregroundColor: Colors.white,
          ),
          onPressed: _nextPage,
          child: Text(_currentPage == _navPages.length - 1
              ? "Complete Journey"
              : "Proceed to the Next Direction Step"),
        ),
      ),
    );
  }
}
