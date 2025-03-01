import 'package:flutter/material.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/indoor_search_bar.dart';
import '../../widgets/selectable_list.dart';
import 'search_selectable_list.dart';

class ClassroomSelection extends StatefulWidget {
  final String building;
  final String floor;
  const ClassroomSelection(
      {super.key, required this.building, required this.floor});

  @override
  ClassroomSelectionState createState() => ClassroomSelectionState();
}

class ClassroomSelectionState extends State<ClassroomSelection> {
  final List<String> classrooms = [
    'Classroom 101',
    'Classroom 102',
    'Classroom 103'
  ];
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
        mainAxisSize: MainAxisSize
            .min, // This ensures the Column does not take up unbounded space
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
          SelectableList<String>(
            items: classrooms,
            title: 'Select a classroom',
            searchController: searchController,
            onItemSelected: (classroom) {
              // TODO: Handle classroom selection logic
            },
          ),
        ],
      ),
    );
  }
}
