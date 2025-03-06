import 'package:flutter/material.dart';
import '../../utils/building_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/indoor_search_bar.dart';
import '../../widgets/select_indoor_destination.dart';
import '../../widgets/selectable_list.dart';
import '../indoor_location/indoor_directions_view.dart';

class ClassroomSelection extends StatefulWidget {
  final String building;
  final String floor;
  const ClassroomSelection({super.key, required this.building, required this.floor});

  @override
  ClassroomSelectionState createState() => ClassroomSelectionState();
}

class ClassroomSelectionState extends State<ClassroomSelection> {
  late Future<List<String>> classroomsFuture;
  late String floorNumber;
  List<String> allClassrooms = [];
  List<String> filteredClassrooms = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    classroomsFuture = _loadClassrooms();
    searchController.addListener(filterClassrooms);
    floorNumber = widget.floor.replaceAll('Floor ', '');
  }

  Future<List<String>> _loadClassrooms() async {
    final List<String> classrooms =
        await BuildingViewModel().getRoomsForFloor(widget.building, widget.floor)
        .then((rooms) => rooms.map((room) => floorNumber + room.roomNumber).toList());

    setState(() {
      allClassrooms = classrooms;
      filteredClassrooms = List.from(classrooms);
    });

    return classrooms;
  }

  void filterClassrooms() {
    setState(() {
      filteredClassrooms = allClassrooms
          .where((classroom) =>
              classroom.toLowerCase().contains(searchController.text.toLowerCase()))
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
        mainAxisSize: MainAxisSize.min,
        children: [
          IndoorSearchBar(
            controller: searchController,
            hintText: 'Search',
            icon: Icons.location_on,
            iconColor: Theme.of(context).primaryColor,
          ),
          // Buttons for selecting building and floor
          SelectIndoorDestination(building: widget.building, floor: widget.floor),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.floor,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ),
          FutureBuilder<List<String>>(
            future: classroomsFuture,
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
                    child: Text("No classrooms available")
                  )
                );
              } else {
                return SelectableList<String>(
                  items: filteredClassrooms,
                  title: 'Select a classroom',
                  searchController: searchController,
                  onItemSelected: (classroom) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IndoorDirectionsView(
                          currentLocation: 'Your Location',
                          building: widget.building,
                          floor: floorNumber,
                          room: classroom,
                        ),
                      ),
                      (route) => route.isFirst,
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
