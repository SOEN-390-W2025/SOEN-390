import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/building_viewmodel.dart';
import '../../utils/journey/preview_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../indoor_map/building_selection.dart';
import '../journey/journey_view.dart';

enum NavigationRouteType {
  indoor,
  preview,
}

class NextClassDirectionsPreview extends StatefulWidget {
  final String sourceRoom;
  final String sourceBuilding;
  final String sourceFloor;
  final String destRoom;
  final String destBuilding;
  final String destFloor;
  final NavigationRouteType routeType;

  const NextClassDirectionsPreview({
    super.key,
    required this.sourceRoom,
    required this.sourceBuilding,
    required this.sourceFloor,
    required this.destRoom,
    required this.destBuilding,
    required this.destFloor,
    this.routeType = NavigationRouteType.indoor,
  });

  @override
  NextClassDirectionsPreviewState createState() =>
      NextClassDirectionsPreviewState();
}

class NextClassDirectionsPreviewState
    extends State<NextClassDirectionsPreview> {
  late String _sourceRoom;
  late String _sourceBuilding;
  late String _sourceFloor;
  late String _destRoom;
  late String _destBuilding;
  late String _destFloor;

  final PageController _pageController = PageController();
  int _currentPage = 0;
  late PreviewViewModel viewModel;
  bool _hasFetchedSize = false;

  @override
  void initState() {
    super.initState();
    _sourceRoom = widget.sourceRoom;
    _sourceBuilding = widget.sourceBuilding;
    _sourceFloor = widget.sourceFloor;
    _destRoom = widget.destRoom;
    _destBuilding = widget.destBuilding;
    _destFloor = widget.destFloor;

    viewModel = PreviewViewModel(
      sourceBuildingName: _sourceBuilding,
      destBuildingName: _destBuilding,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasFetchedSize &&
        _sourceBuilding.toLowerCase() != _destBuilding.toLowerCase()) {
      final mediaQuery = MediaQuery.of(context);
      const bottomHeight = 120.0;
      final availableWidth = mediaQuery.size.width;
      final availableHeight =
          (mediaQuery.size.height - kToolbarHeight - bottomHeight).toInt();
      viewModel.fetchStaticMapWithSize(availableWidth.toInt(), availableHeight);
      _hasFetchedSize = true;
    }
  }

  Future<void> _editSource() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => const BuildingSelection(
          routeType: NavigationRouteType.preview,
          isSource: true,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _sourceRoom = result['room']!;
        _sourceBuilding = result['building']!;
        _sourceFloor = result['floor']!;
      });
    }
  }

  Future<void> _editDestination() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => const BuildingSelection(
          routeType: NavigationRouteType.preview,
          isSource: false,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _destRoom = result['room']!;
        _destBuilding = result['building']!;
        _destFloor = result['floor']!;
      });
    }
  }

  void _nextPage() {
    if (widget.routeType == NavigationRouteType.preview) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Preview mode active: not routing to indoor navigation."),
        ),
      );
      return;
    }
    final bool isSameBuilding =
        _sourceBuilding.toLowerCase() == _destBuilding.toLowerCase();
    if (isSameBuilding) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => NavigationJourneyPage(
            sourceRoom: _sourceRoom,
            sourceBuilding: _sourceBuilding,
            sourceFloor: _sourceFloor,
            destRoom: _destRoom,
            destBuilding: _destBuilding,
            destFloor: _destFloor,
          ),
        ),
      );
    } else {
      if (_currentPage < 2) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NavigationJourneyPage(
              sourceRoom: _sourceRoom,
              sourceBuilding: _sourceBuilding,
              sourceFloor: _sourceFloor,
              destRoom: _destRoom,
              destBuilding: _destBuilding,
              destFloor: _destFloor,
            ),
          ),
        );
      }
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildLocationInfoWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Icon(Icons.radio_button_checked,
                  color: Theme.of(context).primaryColor),
              const SizedBox(height: 4),
              Container(
                height: 20,
                width: 2,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Icon(Icons.location_on, color: Colors.red),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationBox(
                    context,
                    'From: $_sourceBuilding, Floor $_sourceFloor, Room: $_sourceRoom',
                    true),
                const SizedBox(height: 10),
                _buildLocationBox(
                    context,
                    'To: $_destBuilding, Floor $_destFloor, Room: $_destRoom',
                    false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationBox(BuildContext context, String text, bool isSource) {
    return GestureDetector(
      onTap: () {
        if (isSource) {
          _editSource();
        } else {
          _editDestination();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSameBuilding =
        _sourceBuilding.toLowerCase() == _destBuilding.toLowerCase();
    final buildingViewModel = BuildingViewModel();
    final sourceAbbrev =
        buildingViewModel.getBuildingAbbreviation(_sourceBuilding) ?? '';
    final destAbbrev =
        buildingViewModel.getBuildingAbbreviation(_destBuilding) ?? '';
    final sourceFloorPlanPath =
        'assets/maps/indoor/floorplans/$sourceAbbrev$_sourceFloor.svg';
    final destFloorPlanPath =
        'assets/maps/indoor/floorplans/$destAbbrev$_destFloor.svg';

    final List<Widget> pages = isSameBuilding
        ? [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Indoor Navigation within $_sourceBuilding",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Navigate from room $_sourceRoom (Floor $_sourceFloor) to room $_destRoom (Floor $_destFloor).",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 500,
                    child: SvgPicture.asset(
                      sourceFloorPlanPath,
                      fit: BoxFit.contain,
                      placeholderBuilder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child: Icon(
                          Icons.meeting_room,
                          size: 150,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]
        : [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Step 1: Exit the $_sourceBuilding building",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "You've set $_sourceBuilding - Floor $_sourceFloor as your current location.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 500,
                    child: SvgPicture.asset(
                      sourceFloorPlanPath,
                      fit: BoxFit.contain,
                      placeholderBuilder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child: Icon(
                          Icons.meeting_room,
                          size: 150,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Step 2: Follow the Outdoor Directions",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "From $_sourceBuilding on your way to $_destBuilding, you'll select between transport methods to get to your next class.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  viewModel.staticMapUrl == null
                      ? const CircularProgressIndicator()
                      : Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF962e42),
                              width: 2,
                            ),
                          ),
                          child: Image.network(
                            viewModel.staticMapUrl!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Step 3: After reaching $_destBuilding, navigate to floor $_destFloor.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Your next class is in room $_destFloor.$_destRoom.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 500,
                    child: SvgPicture.asset(
                      destFloorPlanPath,
                      fit: BoxFit.contain,
                      placeholderBuilder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child: Icon(
                          Icons.meeting_room,
                          size: 150,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ];

    return Scaffold(
      appBar: customAppBar(context, "Next Class Directions Preview"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildLocationInfoWidget(),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: viewModel,
              builder: (context, _) {
                return PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  children: pages,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isSameBuilding
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF962e42),
                  foregroundColor: Colors.white,
                ),
                onPressed: _nextPage,
                child: const Text("Begin Navigation"),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _currentPage == 0 ? null : _prevPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF962e42),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Prev"),
                  ),
                  ElevatedButton(
                    onPressed: _currentPage == 2 ? null : _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF962e42),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Next"),
                  ),
                  ElevatedButton(
                    onPressed: _currentPage == 2 ? _nextPage : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF962e42),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Begin Navigation"),
                  ),
                ],
              ),
      ),
    );
  }
}
