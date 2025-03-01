import 'package:flutter/material.dart';
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
      body: SearchSelectableList<String>(
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
