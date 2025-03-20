import 'package:flutter/material.dart';
import '../../utils/building_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/indoor_search_bar.dart';
import '../../widgets/select_indoor_destination.dart';
import '../../widgets/selectable_list.dart';
import '../indoor_location/indoor_location_view.dart';
import '../../utils/poi/poi_viewmodel.dart';
import '../poi/poi_map_view.dart';
import 'classroom_selection.dart';

class FloorSelection extends StatefulWidget {
  final String building;
  final String? endRoom;
  final bool isSource;
  final bool isSearch;
  final bool isDisability;
  final String? poiName;
  final POIChoiceViewModel? poiChoiceViewModel;

  const FloorSelection({
    super.key,
    required this.building,
    this.endRoom,
    this.isSource = false,
    this.isSearch = false,
    this.isDisability = false,
    this.poiName,
    this.poiChoiceViewModel,
  });

  @override
  FloorSelectionState createState() => FloorSelectionState();
}

class FloorSelectionState extends State<FloorSelection> {
  late Future<List<String>> floorsFuture;
  List<String> allFloors = [];
  List<String> filteredFloors = [];
  final TextEditingController searchController = TextEditingController();
  late BuildingViewModel _buildingViewModel;

  @override
  void initState() {
    super.initState();
    _buildingViewModel = BuildingViewModel();
    floorsFuture = _buildingViewModel.getFloorsForBuilding(widget.building);
    searchController.addListener(filterFloors);
  }

  // Filter the list of floors based on the search text
  void filterFloors() {
    setState(() {
      filteredFloors = allFloors
          .where((floor) =>
              floor.toLowerCase().contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, widget.building),
      body: Column(children: [
        IndoorSearchBar(
          controller: searchController,
          hintText: 'Search',
          icon: Icons.location_on,
          iconColor: Theme.of(context).primaryColor,
        ),
        if (!widget.isSearch)
          SelectIndoorDestination(
              building: widget.building,
              isSource: widget.isSource,
              endRoom: widget.endRoom,
              isDisability: widget.isDisability),
        FutureBuilder<List<String>>(
          future: floorsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Expanded(
                  child: Center(child: Text('Not available')));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Expanded(
                  child: Center(child: Text("No floors available")));
            } else {
              // Update the floors list only once
              if (allFloors.isEmpty) {
                allFloors = snapshot.data!;
                filteredFloors = List.from(allFloors);
              }

              return SelectableList(
                items: filteredFloors,
                title: 'Select a floor',
                searchController: searchController,
                onItemSelected: (floor) {
                  // Handle floor selection based on context
                  _handleFloorSelection(context, floor);
                },
              );
            }
          },
        ),
      ]),
    );
  }

  void _handleFloorSelection(BuildContext context, String floor) {
    // Clean the floor string (remove "Floor " prefix if present)
    final cleanFloor = floor.replaceAll('Floor ', '');
    
    // Get the building object
    final building = _buildingViewModel.getBuildingByName(widget.building);
    
    if (building == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Building not found')),
      );
      return;
    }

    // Case 1: Is this a POI view?
    if (widget.poiName != null && widget.poiChoiceViewModel != null) {
      // Navigate to POIMapView with the selected floor
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => POIMapView(
            poiName: widget.poiName!,
            poiChoiceViewModel: widget.poiChoiceViewModel!,
            initialBuilding: widget.building,
            initialFloor: cleanFloor,
          ),
        ),
      );
    }
    // Case 2: Is this a search view?
    else if (widget.isSearch) {
      // Existing navigation for indoor location view
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => IndoorLocationView(
            building: building,
            floor: cleanFloor,
          ),
        ),
        (route) => route.isFirst,
      );
    }
    // Case 3: Regular classroom selection
    else {
      // Existing navigation for classroom selection
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClassroomSelection(
            building: widget.building,
            floor: floor.toString(),
            currentRoom: widget.endRoom,
            isSource: widget.isSource,
            isDisability: widget.isDisability,
          ),
        ),
      );
    }
  }
}