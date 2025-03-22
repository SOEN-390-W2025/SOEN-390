import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../data/repositories/building_repository.dart';
import '../../data/services/smart_planner_service.dart';
import '../../utils/map_viewmodel.dart';
import '../../data/domain-model/location.dart';
import '../../data/domain-model/travelling_salesman_request.dart';
import '../setting/common_app_bart.dart';
import 'generated_plan_view.dart';

class SmartPlannerView extends StatefulWidget {
  final MapViewModel? mapViewModel;

  const SmartPlannerView({super.key, this.mapViewModel});

  @override
  State<SmartPlannerView> createState() => _SmartPlannerViewState();
}

class _SmartPlannerViewState extends State<SmartPlannerView> {
  late final MapViewModel _mapViewModel;
  late final SmartPlannerService _smartPlannerService;
  bool isFetchingNearestBuilding = false;

  final TextEditingController _planController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  List<String> buildings = [];
  bool locationEnabled = false;
  bool useCurrentLocation = false;
  bool _isLoading = false;
  String? _errorMessage;
  TravellingSalesmanRequest? _plannerRequest;

  @override
  void initState() {
    super.initState();
    _mapViewModel = widget.mapViewModel ?? MapViewModel();
    _smartPlannerService = SmartPlannerService();
    buildings = BuildingRepository.buildingByAbbreviation.values
        .map((building) => building.name)
        .toList();
    _checkLocationEnabled();
    _planController.addListener(_updateButtonState);
    _sourceController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _planController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {});
  }

  Future<void> _checkLocationEnabled() async {
    final isEnabled = await _mapViewModel.checkLocationAccess();
    setState(() {
      locationEnabled = isEnabled;
    });
    if (isEnabled) {
      await _getNearestBuilding();
    }
  }

  Future<void> _getNearestBuilding() async {
    setState(() {
      isFetchingNearestBuilding = true;
    });
    try {
      final currentPosition = await Geolocator.getCurrentPosition();
      ConcordiaBuilding? nearestBuilding;
      double bestDistance = double.infinity;
      for (var building in BuildingRepository.buildingByAbbreviation.values) {
        final distance = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          building.lat,
          building.lng,
        );
        if (distance < bestDistance) {
          nearestBuilding = building;
          bestDistance = distance;
        }
      }
      setState(() {
        if (nearestBuilding != null && bestDistance <= 1000) {
          _sourceController.text = nearestBuilding.name;
          useCurrentLocation = false;
        } else {
          _sourceController.text = "Your location";
          useCurrentLocation = true;
        }
      });
      dev.log("Nearest building determined: ${_sourceController.text}");
    } on Error catch (e, stackTrace) {
      dev.log("Error getting location", error: e, stackTrace: stackTrace);
    } finally {
      setState(() {
        isFetchingNearestBuilding = false;
      });
    }
  }

  /// Send a request to generate a plan based on user inputs.
  /// Handles geolocation, input parsing, and planner service call. Navigates
  /// to the Generated Plan view on success, otherwise throws an error.
  Future<void> _generatePlan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final startTime = DateTime.now();

    final sourceText = _sourceController.text.trim();
    Location startLocation;
    final currentPosition = await Geolocator.getCurrentPosition();
    if (sourceText.toLowerCase() == "your location") {
      startLocation = Location(
        currentPosition.latitude,
        currentPosition.longitude,
        sourceText,
        null,
        null,
        null,
        null,
      );
    } else {
      final building = BuildingRepository.buildingByName[sourceText];
      if (building != null) {
        startLocation = building;
      } else {
        startLocation = Location(
          currentPosition.latitude,
          currentPosition.longitude,
          sourceText,
          null,
          null,
          null,
          null,
        );
      }
    }

    dev.log("Start location runtime type: ${startLocation.runtimeType}");
    if (startLocation is ConcordiaBuilding) {
      dev.log("Start location is a ConcordiaBuilding: ${startLocation.name}");
    } else {
      dev.log("Start location is a plain Location: ${startLocation.name}");
    }

    try {
      dev.log("Generating plan with prompt: ${_planController.text}");
      _plannerRequest = await _smartPlannerService.generatePlannerData(
        prompt: _planController.text,
        startTime: startTime,
        startLocation: startLocation,
      );
      if (!mounted) return;
      dev.log(
          "Plan generated with ${_plannerRequest!.events.length} events and ${_plannerRequest!.todoLocations.length} todoLocations");
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GeneratedPlanView(plan: _plannerRequest!),
        ),
      );
    } on Error catch (e) {
      _errorMessage = e.toString();
      dev.log("Error generating plan: $_errorMessage");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _buildingSelector(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: buildings.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(buildings[index]),
            onTap: () => Navigator.pop(context, buildings[index]),
          );
        },
      ),
    );

    if (result != null) {
      setState(() {
        _sourceController.text = result;
        useCurrentLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Smart Planner"),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Optimize your campus route by minimizing walking time and outdoor exposure. "
              "Enter your tasks, get an efficient plan, and follow step-by-step directions.",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 0.5,
                  ),
                ],
              ),
              child: TextField(
                controller: _planController,
                textAlignVertical: TextAlignVertical.top,
                keyboardType: TextInputType.multiline,
                cursorColor: const Color(0xFF962e42),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: "Create new plan...",
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(
                    "Source location",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                GestureDetector(
                  onTap: () => _buildingSelector(context),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 0.5,
                        ),
                      ],
                    ),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _sourceController,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: "Pick a source location...",
                          hintStyle:
                              TextStyle(color: Colors.grey[500], fontSize: 14),
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.location_on,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (isFetchingNearestBuilding)
                  const Padding(
                    padding: EdgeInsets.only(left: 10.0, top: 5.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Detecting nearby building...",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                if (locationEnabled && !useCurrentLocation)
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _sourceController.text = "Your location";
                          useCurrentLocation = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 4.0,
                        ),
                        minimumSize: const Size(0, 30),
                      ),
                      child: const Text(
                        "Use current location",
                        style: TextStyle(
                          fontSize: 10.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Error: $_errorMessage",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20),
                _buildSmartPlannerGuide(context),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
        child: ElevatedButton(
          onPressed: _planController.text.isNotEmpty &&
                  _sourceController.text.isNotEmpty &&
                  !_isLoading
              ? _generatePlan
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            minimumSize: const Size(150, 40),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Color(0xFF962e42))
              : const Text("Make Plan", style: TextStyle(color: Colors.white)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

Widget _buildSmartPlannerGuide(BuildContext context) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      // ignore: deprecated_member_use
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Smart Planner Input Guide',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '• For events, provide both a start and an end time (e.g. "from 10:00 am to 11:00 am").',
          style: TextStyle(fontSize: 14),
        ),
        const Text(
          '• For free-time tasks, please provide a duration (e.g. "for 30 minutes").',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        const Text(
          'Indoor & Outdoor Locations:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const Text(
          ' • Enter the name and we’ll take care of the rest!',
          style: TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 8),
        const Text(
          'Example:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const Text.rich(
          TextSpan(
            text:
                'I have to attend a seminar at the J.W. McConnell Building from 9 am to 10 am, then grab lunch at a Grocery Store and stay around there from 12:00 pm to 12:30 pm, and at some point I want to workout at a Gym for an hour.',
          ),
          style: TextStyle(fontSize: 13),
        ),
      ],
    ),
  );
}
