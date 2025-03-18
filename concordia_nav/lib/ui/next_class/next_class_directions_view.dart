import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/domain-model/concordia_campus.dart';
import '../../data/domain-model/concordia_floor.dart';
import '../../data/domain-model/location.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../data/domain-model/concordia_room.dart';
import '../../data/domain-model/room_category.dart';
import '../../data/repositories/navigation_decision_repository.dart';
import '../../utils/next_class/next_class_directions_viewmodel.dart';
import '../../widgets/compact_location_search_widget.dart';
import '../../widgets/custom_appbar.dart';
import '../journey/journey_view.dart';
import '../../widgets/next_class/location_selection.dart';

/*
There are three cases as to how directions are provided to the next class,
represented by the enum below:

CASE 1: Source and Destination belong to the same ConcordiaBuilding.
This means that only one IndoorDirectionsView will be required for the
single-floor or multi-floor routing.

CASE 2: Source and Destination are NOT inside the same ConcordiaBuilding.
This means that:
- An IndoorDirectionsView will start at Source with directions to the
  ConcordiaBuilding's exit.
- An OutdoorDirectionsView will show directions for the user from the exit
  of that building to the entrance of the next ConcordiaBuilding.
- Another IndoorDirectionsView will handle the remaining indoor directions,
  from the entrance on the main floor (always floor 1) to the ConcordiaRoom.

CASE 3: Source is a non-ConcordiaRoom Location.
The non-ConcordiaRoom location can be the user's outdoor location, like
somewhere completely off-campus. This means that:
- An OutdoorDirectionsView will show directions for the user from the Source
  to the entrance of the next ConcordiaBuilding.
- An IndoorDirectionsView will handle the remaining indoor directions,
  from the entrance on the main floor (always floor 1) to the ConcordiaRoom.

The user has the option to set their own Source to a ConcordiaFloor, which
falls under Case 1 or Case 2. The user can also select "My Location"
as a Source which falls under Case 3.

Regarding Case 3, let's scope down to assume that "My Location" is always
somewhere outdoors. Yes, you could argue that using the rounded geolocation
would tell us if the user's within a Campus building, but even then the indoor
position will never be accurate (actual floor that the user's on, exact
position, are they inside or outside the building, etc.)
*/
enum NextClassScenario {
  sameBuildingClassroom, // Case 1
  differentBuildingClassroom, // Case 2
  outdoorToClassroom, // Case 3
  awaitingDirectionInputs, // This value is used as a placeholder.
}

class NextClassDirectionsPreview extends StatefulWidget {
  final List<Location> journeyItems;
  final NextClassViewModel? viewModel;

  const NextClassDirectionsPreview({
    super.key,
    required this.journeyItems,
    this.viewModel,
  });

  @override
  NextClassDirectionsPreviewState createState() =>
      NextClassDirectionsPreviewState();
}

class NextClassDirectionsPreviewState
    extends State<NextClassDirectionsPreview> {
  static const String startingPointPlaceholder = "Add a starting point";
  static const String nextClassPlaceholder = "Add your next class";

  late Location _source;
  late ConcordiaRoom _destination;
  late NextClassViewModel viewModel;
  bool _hasFetchedSize = false;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isFetchingInitialLocation = false;
  // ignore: unused_field
  String? _staticMapUrl;

  @override
  void initState() {
    super.initState();

    // In the context of getting Next Class directions, we always assume that
    // the destination is a ConcordiaRoom.
    switch (widget.journeyItems.length) {
      case 0: // Nothing was passed to this page.
        _source = _buildEmptyRoom(startingPointPlaceholder);
        _destination = _buildEmptyRoom(nextClassPlaceholder);
        break;
      case 1: // 1 Location was passed to this page, which could only come from
        // the Calendar view after having requested to get directions.
        _destination = widget.journeyItems.first as ConcordiaRoom;
        _source = _buildEmptyRoom(startingPointPlaceholder);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _attemptSetSourceToMyLocation();
        });
        break;
      default: // Assume that 2 Locations were passed properly.
        _source = widget.journeyItems.first;
        _destination = widget.journeyItems.last as ConcordiaRoom;
        break;
    }

    viewModel = widget.viewModel ??
        NextClassViewModel(
          startLocation: _source,
          endLocation: _destination,
        );
  }

  /// Creates a dummy placeholder room, associated with the Location inputs.
  ConcordiaRoom _buildEmptyRoom(String placeholder) {
    final dummyBuilding = ConcordiaBuilding(
      0.0,
      0.0,
      placeholder,
      "",
      "",
      "",
      "",
      "",
      ConcordiaCampus.sgw,
    );
    final dummyFloor = ConcordiaFloor("0", dummyBuilding);
    return ConcordiaRoom(placeholder, RoomCategory.classroom, dummyFloor, null);
  }

  /// Retrieves the user’s location by using the last known or the low-accuracy
  /// location. Shows an error if something went wrong trying to get it.
  Future<LatLng> _fetchFastLocation() async {
    final lastPos = await Geolocator.getLastKnownPosition();
    if (lastPos != null) {
      return LatLng(lastPos.latitude, lastPos.longitude);
    }
    final position = await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.low,
      // ignore: deprecated_member_use
      timeLimit: const Duration(seconds: 5),
    );
    return LatLng(position.latitude, position.longitude);
  }

  /// Attempts to update the source Location to the user's current location.
  Future<void> _attemptSetSourceToMyLocation() async {
    setState(() => _isFetchingInitialLocation = true);
    try {
      final LatLng fastLoc = await _fetchFastLocation();
      setState(() {
        _source = Location(
          fastLoc.latitude,
          fastLoc.longitude,
          "Your Location",
          "",
          "",
          "",
          "",
        );
        viewModel.updateLocations(
          startLocation: _source,
          endLocation: _destination,
        );
      });

      // ignore: use_build_context_synchronously
      final mediaQuery = MediaQuery.of(context);
      final availableWidth = mediaQuery.size.width.toInt();
      final availableHeight =
          (mediaQuery.size.height - kToolbarHeight - 120).toInt();

      final String? newMapUrl = mounted
          ? await viewModel.fetchStaticMapWithSize(
              availableWidth,
              availableHeight,
            )
          : "";
      setState(() => _staticMapUrl = newMapUrl);
    } on Error catch (e) {
      debugPrint("Error fetching location: $e");
    } finally {
      setState(() => _isFetchingInitialLocation = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasFetchedSize) {
      if (!_isPlaceholder(_source) && !_isSameBuilding()) {
        final mediaQuery = MediaQuery.of(context);
        final availableWidth = mediaQuery.size.width.toInt();
        final availableHeight =
            (mediaQuery.size.height - kToolbarHeight - 120).toInt();
        viewModel
            .fetchStaticMapWithSize(availableWidth, availableHeight)
            .then((url) {
          setState(() => _staticMapUrl = url);
        });
      }
      _hasFetchedSize = true;
    }
  }

  bool _isPlaceholder(Location loc) {
    if (loc is ConcordiaRoom) {
      return loc.roomNumber == startingPointPlaceholder ||
          loc.roomNumber == nextClassPlaceholder;
    }
    return false;
  }

  bool _isSameBuilding() {
    if (_source is ConcordiaRoom) {
      return (_source as ConcordiaRoom).floor.building.abbreviation ==
          _destination.floor.building.abbreviation;
    }
    if (_source is ConcordiaBuilding && _destination is ConcordiaBuilding) {
      return (_source as ConcordiaBuilding).abbreviation ==
          (_destination as ConcordiaBuilding).abbreviation;
    }
    return false;
  }

  NextClassScenario _determineScenario() {
    if (_isPlaceholder(_source) || _isPlaceholder(_destination)) {
      return NextClassScenario.awaitingDirectionInputs;
    }
    if (_isSameBuilding()) {
      return NextClassScenario.sameBuildingClassroom;
    }
    if (_source is ConcordiaBuilding || _source is ConcordiaRoom) {
      return NextClassScenario.differentBuildingClassroom;
    }
    return NextClassScenario.outdoorToClassroom;
  }

  List<Widget> _buildPagesForScenario(NextClassScenario scenario) {
    switch (scenario) {
      case NextClassScenario.sameBuildingClassroom:
        return _buildSameBuildingPages();
      case NextClassScenario.differentBuildingClassroom:
        return _buildDifferentBuildingsPages();
      case NextClassScenario.outdoorToClassroom:
        return _buildOutsideBuildingPages();
      case NextClassScenario.awaitingDirectionInputs:
        return [_buildPlaceholderPage()];
    }
  }

  Widget _buildPlaceholderPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: _isFetchingInitialLocation
            ? const CircularProgressIndicator(color: Color(0xFF962e42))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.explore, size: 80, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  const Text(
                    "Please select a pair of locations to navigate to your next class.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Choose a starting destination and the location of your next classroom.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
      ),
    );
  }

  List<Widget> _buildSameBuildingPages() {
    return [
      SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Follow Indoor Directions",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 5),
            Center(
              child: Text(
                "Since your next class is in the same building, you’ll just be following directions around ${_destination.name}.",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            _buildFloorPlanWidget((_source) as ConcordiaRoom),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildDifferentBuildingsPages() {
    return [
      SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Step 1: Exit ${_source.name}",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 5),
            Center(
              child: Text(
                "You’ll start by leaving ${_source.name} from the nearest exit in order to start your journey.",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            _buildFloorPlanWidget(((_source) as ConcordiaRoom)),
          ],
        ),
      ),
      SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Step 2: Follow Outdoor Directions",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 5),
            Center(
              child: Text(
                "From ${_source.name} towards ${_destination.name}, you’ll select the best transport method to get to your next class.",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            _buildStaticMapWidget(),
          ],
        ),
      ),
      SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Step 3: Enter ${_destination.name}",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 5),
            Center(
              child: Text(
                "Once you’re inside ${_destination.name}, follow the indoor directions to reach your next class at ${_destination.floor.floorNumber}.${_destination.roomNumber}!",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            _buildFloorPlanWidget(_destination),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildOutsideBuildingPages() {
    return [
      SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Step 1: Follow Outdoor Directions",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 5),
            const Center(
              child: Text(
                "You’ll get to select the best transport method for your next class.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            _buildStaticMapWidget(),
          ],
        ),
      ),
      SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Step 2: Enter ${_destination.name}",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 5),
            Center(
              child: Text(
                "Once inside, follow the indoor directions to reach your next class at ${_destination.floor.floorNumber}.${_destination.roomNumber}!",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            _buildFloorPlanWidget(_destination),
          ],
        ),
      ),
    ];
  }

  Widget _buildStaticMapWidget() {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        final url = viewModel.staticMapUrl;
        if (url == null) {
          return const CircularProgressIndicator(color: Color(0xFF962e42));
        }
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF962e42), width: 2),
          ),
          child: Image.network(url, fit: BoxFit.cover),
        );
      },
    );
  }

  Widget _buildFloorPlanWidget(ConcordiaRoom location) {
    final String abbreviation = location.floor.building.abbreviation;
    const String floorNumber = "1";
    final floorPlanPath =
        'assets/maps/indoor/floorplans/$abbreviation$floorNumber.svg';

    final screenHeight = MediaQuery.of(context).size.height;
    final widgetHeight = screenHeight * 0.5;

    return SizedBox(
      height: widgetHeight,
      child: SvgPicture.asset(
        floorPlanPath,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF962e42)),
        ),
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.meeting_room, size: 150),
        ),
      ),
    );
  }

  Future<void> _editSource() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return LocationSelection(
          isSource: true,
          onSelectionComplete: (selectedRoom) async {
            if (selectedRoom != null) {
              setState(() {
                _source = selectedRoom;
                _resetNavigation();
                viewModel.updateLocations(
                  startLocation: _source,
                  endLocation: _destination,
                );
              });
              final mediaQuery = MediaQuery.of(context);
              final availableWidth = mediaQuery.size.width.toInt();
              final availableHeight =
                  (mediaQuery.size.height - kToolbarHeight - 120).toInt();
              if (context.mounted) {
                await viewModel.fetchStaticMapWithSize(
                    availableWidth, availableHeight);
              }
            }
            if (context.mounted) Navigator.pop(context);
          },
        );
      },
    );
  }

  Future<void> _editDestination() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return LocationSelection(
          isSource: false,
          onSelectionComplete: (selectedRoom) async {
            if (selectedRoom != null) {
              setState(() {
                _destination = selectedRoom;
                _resetNavigation();
                viewModel.updateLocations(
                  startLocation: _source,
                  endLocation: _destination,
                );
              });
              final mediaQuery = MediaQuery.of(context);
              final availableWidth = mediaQuery.size.width.toInt();
              final availableHeight =
                  (mediaQuery.size.height - kToolbarHeight - 120).toInt();
              if (context.mounted) {
                await viewModel.fetchStaticMapWithSize(
                    availableWidth, availableHeight);
              }
            }
            if (context.mounted) Navigator.pop(context);
          },
        );
      },
    );
  }

  void _resetNavigation() {
    setState(() => _currentPage = 0);
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildLocationInfo() {
    final sourceText = _formatLocationText(_source);
    final destinationText = _formatLocationText(_destination);

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
                SizedBox(height: 4),
                VerticalDottedLine(
                  height: 20,
                  color: Colors.grey,
                  dashHeight: 3,
                  dashSpace: 3,
                  strokeWidth: 2,
                ),
                SizedBox(height: 4),
                Icon(
                  Icons.location_on,
                  color: Color(0xFFDA3A16),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Column(
                  children: [
                    InkWell(
                      onTap: _editSource,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          sourceText,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Colors.grey[300],
                    ),
                    InkWell(
                      onTap: _editDestination,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          destinationText,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
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

  String _formatLocationText(Location location) {
    if (location is ConcordiaRoom && _isPlaceholder(location)) {
      return location.roomNumber;
    }
    if (location is ConcordiaRoom) {
      return "${location.name}, ${location.floor.floorNumber}.${location.roomNumber} (${location.campus.abbreviation} Campus)";
    }
    return location.name;
  }

  Widget _buildBottomBar(int totalPages) {
    final bool isPrevButtonDisabled = _currentPage == 0;
    final bool isNextButtonDisabled = _currentPage == totalPages - 1;
    final bool isBeginNavigationButtonEnabled = _currentPage == totalPages - 1;

    final VoidCallback? prevButtonCallback =
        isPrevButtonDisabled ? null : _prevPage;
    final VoidCallback? nextButtonCallback =
        isNextButtonDisabled ? null : _nextPage;
    final VoidCallback? beginNavigationCallback =
        isBeginNavigationButtonEnabled ? _nextPage : null;

    return Container(
      color: const Color(0xFF962E42),
      padding: const EdgeInsets.all(8.0),
      child: totalPages == 1
          ? ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF962E42),
              ),
              child: const Text("Begin Navigation"),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: prevButtonCallback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF962E42),
                  ),
                  child: const Text("Prev"),
                ),
                ElevatedButton(
                  onPressed: nextButtonCallback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF962E42),
                  ),
                  child: const Text("Next"),
                ),
                ElevatedButton(
                  onPressed: beginNavigationCallback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF962E42),
                  ),
                  child: const Text("Begin Navigation"),
                ),
              ],
            ),
    );
  }

  void _nextPage() {
    final pages = _buildPagesForScenario(_determineScenario());
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final updatedJourneyItems = <Location>[];
      updatedJourneyItems.add(_source);
      updatedJourneyItems.add(_destination);

      final navigationDecision =
          NavigationDecisionRepository.determineNavigationDecision(
              updatedJourneyItems);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => NavigationJourneyPage(
            journeyName: "Next Class Directions",
            journeyItems: updatedJourneyItems,
            decision: navigationDecision,
          ),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    final scenario = _determineScenario();
    final pages = _buildPagesForScenario(scenario);

    return Scaffold(
      appBar: customAppBar(context, "Next Class Directions Preview"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildLocationInfo(),
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
      bottomNavigationBar: scenario == NextClassScenario.awaitingDirectionInputs
          ? null
          : _buildBottomBar(pages.length),
    );
  }
}
