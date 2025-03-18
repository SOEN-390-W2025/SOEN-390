import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../data/repositories/building_repository.dart';
import '../../utils/map_viewmodel.dart';
import '../setting/common_app_bart.dart';

class SmartPlannerView extends StatefulWidget {
  final MapViewModel? mapViewModel;

  const SmartPlannerView({
    super.key,
    this.mapViewModel,
  });

  @override
  State<SmartPlannerView> createState() => _SmartPlannerViewState();
}

class _SmartPlannerViewState extends State<SmartPlannerView> {
  late final MapViewModel _mapViewModel;
  bool isFetchingNearestBuilding = false;

  final TextEditingController _planController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  List<String> buildings = [];
  bool locationEnabled = false;
  bool useCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    _mapViewModel = widget.mapViewModel ?? MapViewModel();
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
    final isLocationEnabled = await _mapViewModel.checkLocationAccess();
    setState(() {
      locationEnabled = isLocationEnabled;
    });

    if (isLocationEnabled) {
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
    } on Exception catch (e, stackTrace) {
      // Optionally handle any errors like permission denial here
      dev.log("Error getting location", error: e, stackTrace: stackTrace);
    } finally {
      setState(() {
        isFetchingNearestBuilding = false;
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
              "Optimize your campus route by minimizing walking time and outdoor exposure. Enter your tasks, get an efficient plan, and follow step-by-step directions.",
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
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
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
                  const SizedBox()
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
        child: ElevatedButton(
          onPressed: _planController.text.isNotEmpty &&
                  _sourceController.text.isNotEmpty
              ? () {
                  // TODO: Implement navigation to generated plan
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            minimumSize: const Size(150, 40),
          ),
          child: const Text("Make Plan", style: TextStyle(color: Colors.white)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
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
      setState(
        () {
          _sourceController.text = result;
          useCurrentLocation = false;
        },
      );
    }
  }
}
