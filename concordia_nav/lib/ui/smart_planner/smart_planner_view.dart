import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../data/repositories/building_repository.dart';
import '../../data/services/smart_planner_service.dart';
import '../../utils/map_viewmodel.dart';
import '../../data/domain-model/location.dart';
import '../../widgets/custom_appbar.dart';
import 'generated_plan_view.dart';

class SmartPlannerView extends StatefulWidget {
  final MapViewModel? mapViewModel;
  final SmartPlannerService? smartPlannerService;

  const SmartPlannerView(
      {super.key, this.mapViewModel, this.smartPlannerService});

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
  Color get _toastBgColour {
    final baseColor = Theme.of(context).primaryColor;
    final hsl = HSLColor.fromColor(baseColor);
    return hsl.withLightness((hsl.lightness + 0.1).clamp(0.0, 1.0)).toColor();
  }

  @override
  void initState() {
    super.initState();
    _mapViewModel = widget.mapViewModel ?? MapViewModel();
    _smartPlannerService = widget.smartPlannerService ?? SmartPlannerService();
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
      final optimizedRoute = await _smartPlannerService.generateOptimizedRoute(
        prompt: _planController.text,
        startTime: startTime,
        startLocation: startLocation,
      );
      if (!mounted) return;
      dev.log("Optimized plan generated with ${optimizedRoute.length} stops");
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GeneratedPlanView(
            startLocation: startLocation,
            optimizedRoute: optimizedRoute,
          ),
        ),
      );
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      _errorMessage = e.toString();
      dev.log("Error generating plan: $_errorMessage");

      if (mounted) {
        Overlay.of(context);
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message:
                "Error generating your plan. Please retry and kindly follow our input guide.",
            backgroundColor: _toastBgColour,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _buildingSelector(BuildContext context) async {
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: cardColor,
      builder: (context) => ListView.builder(
        itemCount: buildings.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              buildings[index],
              style: TextStyle(color: textColor),
            ),
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
    // Get theme colors
    final primaryColor = Theme.of(context).primaryColor;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
    final dividerColor = Theme.of(context).dividerColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: customAppBar(context, "Smart Planner"),
      body: Semantics(
        label:
            'Enter your tasks into the Smart Planner with a starting location to generate an optimized plan.',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Optimize your campus route by minimizing walking time and outdoor exposure. "
                "Enter your tasks, get an efficient plan, and follow step-by-step directions.",
                style: TextStyle(fontSize: 14, color: textColor),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: dividerColor,
                      blurRadius: 1.0,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _planController,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  cursorColor: primaryColor,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: "Create new plan...",
                    hintStyle:
                        TextStyle(color: secondaryTextColor, fontSize: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      "Source location",
                      style: TextStyle(fontSize: 12, color: secondaryTextColor),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _buildingSelector(context),
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: dividerColor,
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _sourceController,
                          textAlignVertical: TextAlignVertical.center,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: "Pick a source location...",
                            hintStyle: TextStyle(
                                color: secondaryTextColor, fontSize: 14),
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.location_on,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isFetchingNearestBuilding)
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(primaryColor),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Detecting nearby building...",
                            style: TextStyle(
                                fontSize: 12, color: secondaryTextColor),
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
                          backgroundColor: primaryColor,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 4.0,
                          ),
                          minimumSize: const Size(0, 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          "Use current location",
                          style: TextStyle(
                            fontSize: 10.0,
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(),
                  const SizedBox(height: 20),
                  _buildSmartPlannerGuide(context),
                ],
              ),
            ],
          ),
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
            backgroundColor: primaryColor,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            disabledBackgroundColor: primaryColor.withAlpha(100),
            disabledForegroundColor:
                Theme.of(context).colorScheme.onPrimary.withAlpha(100),
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            minimumSize: const Size(150, 40),
          ),
          child: _isLoading
              ? CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onPrimary)
              : Text("Make Plan",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

Widget _buildSmartPlannerGuide(BuildContext context) {
  // Get theme colors
  final primaryColor = Theme.of(context).primaryColor;
  final secondaryColor = Theme.of(context).colorScheme.secondary;
  final textColor = Theme.of(context).textTheme.bodyLarge?.color;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: secondaryColor.withAlpha(100),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: secondaryColor.withAlpha(100),
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Smart Planner Input Guide',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '• For events, provide both a start and an end time (e.g. "from 10:00 am to 11:00 am").',
          style: TextStyle(fontSize: 14, color: textColor),
        ),
        Text(
          '• For free-time tasks, please provide a duration (e.g. "for 30 minutes").',
          style: TextStyle(fontSize: 14, color: textColor),
        ),
        Text(
          '• For classrooms, make sure to add a "." between floor and room number (e.g. H 9.27).',
          style: TextStyle(fontSize: 13, color: textColor),
        ),
        const SizedBox(height: 8),
        Text(
          'Example:',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
        ),
        Text.rich(
          const TextSpan(
            text:
                'I have to attend a seminar at the J.W. McConnell Building from 9 am to 9:30 am, I have a lecture in H 9.27 from 10:00 am to 11:00 am, and go to a coffee shop for 30 minutes, and I also have to go to Hall Building for 20 minutes.',
          ),
          style: TextStyle(fontSize: 13, color: textColor?.withAlpha(150)),
        ),
      ],
    ),
  );
}
