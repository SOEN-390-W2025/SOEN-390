import 'package:flutter/material.dart';
import '../../data/repositories/building_repository.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/indoor_search_bar.dart';
import '../../widgets/selectable_list.dart';
import 'floor_selection.dart';

class IndoorMapView extends StatefulWidget {
  const IndoorMapView({super.key});

  @override
  IndoorMapViewState createState() => IndoorMapViewState();
}

class IndoorMapViewState extends State<IndoorMapView> {
  late List<String> buildings;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    buildings = BuildingRepository.buildingByAbbreviation.values
        .map((building) => building.name)
        .toList();
    searchController.addListener(() {
      setState(() {});
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
      appBar: customAppBar(context, 'Indoor Directions'),
      body: Column(
        children: [
          IndoorSearchBar(
            controller: searchController,
            hintText: 'Search',
            icon: Icons.location_on,
            iconColor: Theme.of(context).primaryColor,
          ),
          SelectableList<String>(
            items: buildings,
            title: 'Select a building',
            searchController: searchController,
            onItemSelected: (building) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // TODO: Implement floor selection
                  builder: (context) => FloorSelection(building: building),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
