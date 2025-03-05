import 'package:flutter/material.dart';
import '../../utils/building_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import 'search_selectable_list.dart';
import 'classroom_selection.dart';

class FloorSelection extends StatefulWidget {
  final String building;
  const FloorSelection({super.key, required this.building});

  @override
  FloorSelectionState createState() => FloorSelectionState();
}

class FloorSelectionState extends State<FloorSelection> {
  late Future<List<String>> floorsFuture;
  List<String> allFloors = [];
  List<String> filteredFloors = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    floorsFuture = BuildingViewModel().getFloorsForBuilding(widget.building);
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
      body: FutureBuilder<List<String>>(
        future: floorsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Not available'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No floors available"));
          } else {
            // Update the floors list only once
            if (allFloors.isEmpty) {
              allFloors = snapshot.data!;
              filteredFloors = List.from(allFloors);
            }

            return SearchSelectableList<String>(
              items: filteredFloors,
              title: 'Select a floor',
              building: widget.building,
              searchController: searchController,
              onItemSelected: (floor) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClassroomSelection(
                      building: widget.building,
                      floor: floor,
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
