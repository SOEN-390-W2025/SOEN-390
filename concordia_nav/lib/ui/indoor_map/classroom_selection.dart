import 'package:flutter/material.dart';
import '../../utils/building_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/indoor_search_bar.dart';
import '../../widgets/select_indoor_destination.dart';
import '../../widgets/selectable_list.dart';
import '../indoor_location/indoor_directions_view.dart';
import '../indoor_location/indoor_location_view.dart';

class ClassroomSelection extends StatefulWidget {
  final String building;
  final String floor;

  final String? currentRoom;
  final bool isSource;
  final bool isSearch;
  final bool isDisability;

  const ClassroomSelection(
      {super.key,
      required this.building,
      required this.floor,
      this.currentRoom,
      this.isSource = false,
      this.isSearch = false,
      this.isDisability = false});

  @override
  ClassroomSelectionState createState() => ClassroomSelectionState();
}

class ClassroomSelectionState extends State<ClassroomSelection> {
  late Future<List<String>> classroomsFuture;
  late String floorNumber;
  late String currentRoom;
  List<String> allClassrooms = [];
  List<String> filteredClassrooms = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCurrentRoom();
    classroomsFuture = _loadClassrooms();
    searchController.addListener(filterClassrooms);
    floorNumber = widget.floor.replaceAll('Floor ', '');
  }

  void _initializeCurrentRoom() {
    if (widget.currentRoom != null && widget.currentRoom != 'Your Location') {
      currentRoom = widget.currentRoom!;
    } else {
      currentRoom = 'Your Location';
    }
  }

  Future<List<String>> _loadClassrooms() async {
    final List<String> classrooms = await BuildingViewModel()
        .getRoomsForFloor(widget.building, widget.floor)
        .then((rooms) {
      return rooms
        .where((room) => !room.roomNumber.startsWith('0'))
        .map((room) {
        final String hyphen = room.roomNumber.split('-').first;
        String roomNumber = room.roomNumber;
        if (hyphen.length == 1) {
          roomNumber = '0$roomNumber';
        }
        return '$floorNumber$roomNumber';
      }).toList();
    });
    setState(() {
      allClassrooms = classrooms;
      filteredClassrooms = List.from(classrooms);
    });
    return classrooms;
  }

  void filterClassrooms() {
    setState(() {
      filteredClassrooms = allClassrooms
          .where((classroom) => classroom
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
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
    // Get theme colors
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: customAppBar(context, widget.building),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSearchBar(),
          _buildSelectIndoorDestination(),
          _buildFloorLabel(),
          _buildClassroomList(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return IndoorSearchBar(
      controller: searchController,
      hintText: 'Search',
      icon: Icons.location_on,
      iconColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildSelectIndoorDestination() {
    if (widget.isSearch) return Container();
    return SelectIndoorDestination(
      building: widget.building,
      floor: widget.floor,
      endRoom: currentRoom,
      isSource: widget.isSource,
    );
  }

  Widget _buildFloorLabel() {
    // Get the secondary text color from theme
    final secondaryTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
    
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          widget.floor,
          style: TextStyle(fontSize: 14, color: secondaryTextColor.withAlpha(150)),
        ),
      ),
    );
  }

  Widget _buildClassroomList() {
    // Get the primary color for loading indicator
    final primaryColor = Theme.of(context).primaryColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    
    return FutureBuilder<List<String>>(
      future: classroomsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: primaryColor));
        } else if (snapshot.hasError) {
          return Expanded(
            child: Center(child: Text('Not available', style: TextStyle(color: textColor))),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Expanded(
            child: Center(child: Text("No classrooms available", style: TextStyle(color: textColor))),
          );
        } else {
          return SelectableList<String>(
            items: filteredClassrooms,
            title: 'Select a classroom',
            searchController: searchController,
            onItemSelected: _onClassroomSelected,
          );
        }
      },
    );
  }

  void _onClassroomSelected(String classroom) {
    if (widget.isSearch) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => IndoorLocationView(
            building: BuildingViewModel().getBuildingByName(widget.building)!,
            floor: floorNumber,
            room: classroom,
          ),
        ),
        (route) {
          return route.settings.name == '/HomePage' ||
              route.settings.name == '/CampusMapPage';
        },
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => IndoorDirectionsView(
            sourceRoom: widget.isSource ? classroom : currentRoom,
            building: widget.building,
            endRoom: widget.isSource ? currentRoom : classroom,
            isDisability: widget.isDisability,
          ),
        ),
        (route) => route.isFirst,
      );
    }
  }
}