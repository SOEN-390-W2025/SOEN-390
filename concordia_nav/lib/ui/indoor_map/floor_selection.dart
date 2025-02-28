import 'package:flutter/material.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/indoor_search_bar.dart';
import '../../widgets/selectable_list.dart';
import 'classroom_selection.dart';

class FloorSelection extends StatefulWidget {
  final String building;
  const FloorSelection({super.key, required this.building});

  @override
  FloorSelectionState createState() => FloorSelectionState();
}

class FloorSelectionState extends State<FloorSelection> {
  // Mock floor data
  final List<String> floors = ['Floor 1', 'Floor 2', 'Floor 3'];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
      appBar: customAppBar(context, widget.building),
      body: Column(
        children: [
          IndoorSearchBar(
            controller: searchController,
            hintText: 'Search',
            icon: Icons.location_on,
            iconColor: Theme.of(context).primaryColor,
          ),
          SelectableList<String>(
            items: floors,
            title: 'Select a floor',
            searchController: searchController,
            onItemSelected: (floor) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // TODO: Implement classroom selection
                  builder: (context) => ClassroomSelection(
                    building: widget.building,
                    floor: floor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
