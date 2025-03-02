import 'package:flutter/material.dart';
import '../../utils/building_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/indoor_search_bar.dart';
import '../../widgets/selectable_list.dart';
import '../indoor_location/indoor_location_view.dart';

class ClassroomSelection extends StatefulWidget {
  final String building;
  final String floor;
  const ClassroomSelection({super.key, required this.building, required this.floor});

  @override
  ClassroomSelectionState createState() => ClassroomSelectionState();
}

class ClassroomSelectionState extends State<ClassroomSelection> {
  late final List<String> classrooms;
  late List<String> filteredClassrooms;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    classrooms = BuildingViewModel()
        .getRoomsForFloor(widget.building, widget.floor)
        .map((room) => "Room ${room.roomNumber}")
        .toList();
    filteredClassrooms = List.from(classrooms);

    searchController.addListener(filterClassrooms);
  }

  void filterClassrooms() {
    setState(() {
      filteredClassrooms = classrooms
          .where((classroom) => classroom.toLowerCase().contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    searchController.removeListener(filterClassrooms);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, widget.building),
      body: Column(
        mainAxisSize: MainAxisSize.min, // This ensures the Column does not take up unbounded space
        children: [
          IndoorSearchBar(
            controller: searchController,
            hintText: 'Search',
            icon: Icons.location_on,
            iconColor: Theme.of(context).primaryColor,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.floor,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ),
          filteredClassrooms.isEmpty
            ? const Center(child: Text("No classrooms available"))
            : SelectableList<String>(
              items: filteredClassrooms,
              title: 'Select a classroom',
              searchController: searchController,
              onItemSelected: (classroom) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IndoorLocationView(
                      building: widget.building,
                      floor: widget.floor,
                      room: classroom,
                    ),
                  ),
                  (route) => route.isFirst,
                );
              },
            ),
        ],
      ),
    );
  }
}
