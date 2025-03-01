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
  late final List<String> floors;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    floors = BuildingViewModel().getFloorsForBuilding(widget.building);
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
      body: floors.isEmpty
        ? const Center(child: Text("No floors available"))
        : SearchSelectableList<String>(
          items: floors,
          title: 'Select a floor',
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
        ),
    );
  }
}