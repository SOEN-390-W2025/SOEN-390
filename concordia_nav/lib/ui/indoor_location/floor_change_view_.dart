import 'package:flutter/material.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../utils/building_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/indoor_search_bar.dart';
import '../../widgets/selectable_list.dart';
import 'indoor_location_view.dart';

class FloorChange extends StatefulWidget {
  final ConcordiaBuilding building;
  const FloorChange({super.key, required this.building});

  @override
  FloorChangeState createState() => FloorChangeState();
}

class FloorChangeState extends State<FloorChange> {
  late Future<List<String>> floorsFuture;
  List<String> allFloors = [];
  List<String> filteredFloors = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    floorsFuture = BuildingViewModel().getFloorsForBuilding(widget.building.name);
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
      appBar: customAppBar(context, widget.building.name),
      body: Column(
        children: [
          IndoorSearchBar(
            controller: searchController,
            hintText: 'Search',
            icon: Icons.location_on,
            iconColor: Theme.of(context).primaryColor,
          ),
          FutureBuilder<List<String>>(
            future: floorsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Expanded(
                  child: Center(
                    child: Text('Not available')
                  )
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Expanded(
                  child: Center(
                    child: Text("No floors available")
                  )
                );
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
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IndoorLocationView(
                          building: widget.building,
                          floor: floor.replaceAll('Floor ', ''),
                        ),
                        settings: const RouteSettings(name: '/IndoorLocationView'),
                      ),
                      (route )=> route.isFirst,
                    );
                  },
                );
              }
            },
          ),
        ]
      ),
    );
  }
}
