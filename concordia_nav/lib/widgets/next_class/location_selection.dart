import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/domain-model/concordia_room.dart';
import '../../data/domain-model/location.dart';
import '../../data/repositories/calendar.dart';
import '../../utils/building_viewmodel.dart';
import '../../utils/map_viewmodel.dart';

class LocationSelection extends StatefulWidget {
  final bool isSource;

  /// Callback gets invoked upon selection of a location.
  /// - If using "My Location", a `Location` object is returned.
  /// - If using "Outdoor Location", a `Location` object is passed.
  /// - If using "Select Classroom", a `ConcordiaRoom` object is passed.
  final Function(dynamic) onSelectionComplete;

  const LocationSelection({
    super.key,
    required this.isSource,
    required this.onSelectionComplete,
  });

  @override
  // ignore: library_private_types_in_public_api
  _LocationSelectionState createState() => _LocationSelectionState();
}

class _LocationSelectionState extends State<LocationSelection> {
  String _selectionMode = 'selectClassroom';
  bool _isMyLocationAvailable = false;
  bool _isLoading = false;
  final String yourLocationString = "Your Location";

  String? _selectedBuilding;
  String? _selectedFloor;
  ConcordiaRoom? _selectedRoom;

  List<String> _buildings = [];
  List<String> _floors = [];
  List<ConcordiaRoom> _rooms = [];

  final BuildingViewModel _buildingViewModel = BuildingViewModel();
  final MapViewModel _mapViewModel = MapViewModel();
  final calendarRepo = CalendarRepository();

  @override
  void initState() {
    super.initState();
    _loadBuildings();
    _checkMyLocationAvailability();
  }

  Future<void> _loadBuildings() async {
    final buildings = await _buildingViewModel.getAvailableBuildings();
    setState(() {
      _buildings = buildings;
    });
  }

  String _formatRoomNumber(String roomNumber) {
    final String hyphen = roomNumber.split('-').first;
    if (hyphen.length == 1) {
      return '0$roomNumber';
    }
    return roomNumber;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// Retrieves floors for a given building with respect to what is available
  /// from the Building ViewModel.
  Future<void> _loadFloors(String buildingName) async {
    final fetchedFloors =
        await _buildingViewModel.getFloorsForBuilding(buildingName);
    setState(() {
      _floors = fetchedFloors;
      _selectedFloor = null;
      _rooms = [];
      _selectedRoom = null;
    });
  }

  /// Retrieves rooms for a given floorplan with respect to what is available
  /// from the Building ViewModel.
  Future<void> _loadRooms(String buildingName, String floorName) async {
    final fetchedRooms =
        await _buildingViewModel.getRoomsForFloor(buildingName, floorName);
    setState(() {
      _rooms = fetchedRooms;
      _selectedRoom = null;
    });
  }

  /// Handles whether the end user's current location should be selected as the
  /// input. Otherwise, shows an error if something went wrong trying to get it.
  Future<void> _handleMyLocationSelected() async {
    setState(() {
      _isLoading = true;
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          if (mounted) _showError("Location permission denied");
          return;
        }
      }

      // Attempt to get the last position for a fast response on the user's end.
      final Position? lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        final Location myLocation = Location(
          lastPosition.latitude,
          lastPosition.longitude,
          yourLocationString,
          null,
          null,
          null,
          null,
        );
        widget.onSelectionComplete(myLocation);
        // Even though we just set a somewhat approximate "current location",
        // it's still worth trying to get a more accurate one in the background.
        await _updateHighAccuracyLocation();
        return;
      }

      // If no last known position was found, quickly fetch using low accuracy.
      final Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.low,
        // ignore: deprecated_member_use
        timeLimit: const Duration(seconds: 3),
      );
      final Location myLocation = Location(
        position.latitude,
        position.longitude,
        yourLocationString,
        null,
        null,
        null,
        null,
      );
      widget.onSelectionComplete(myLocation);
      await _updateHighAccuracyLocation(); // ..same reasoning as the last call
    } on Error catch (e) {
      if (mounted) _showError("Unable to fetch current location: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Attemps to update the user's current location with improved accuracy.
  Future<void> _updateHighAccuracyLocation() async {
    try {
      final Position highAccPosition = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
        // ignore: deprecated_member_use
        timeLimit: const Duration(seconds: 5),
      );
      final Location highAccLocation = Location(
        highAccPosition.latitude,
        highAccPosition.longitude,
        yourLocationString,
        null,
        null,
        null,
        null,
      );
      widget.onSelectionComplete(highAccLocation);
    } on Error {
      // We'll ignore the attempt to fetch a high accuracy update and fall back
      // to the normal "current location" retrieval.
    }
  }

  /// Determines whether the user has enabled Calendar permissions and routes
  /// to the next Calendar view page accordingly.
  Future<void> checkCalendarPermission() async {
    // The logic for this is exactly the same as the checkCalendarPermission()
    // found in the settings page. For best practice, they should be retrieved
    // from a common helper function file.
    final bool hasPermission = await calendarRepo.checkPermissions();
    if (mounted) {
      if (hasPermission) {
        await Navigator.pushNamed(context, '/CalendarSelectionView');
      } else {
        await Navigator.pushNamed(context, '/CalendarLinkView');
      }
    }
  }

  /// Helper function that determines whether a user has enabled location
  /// services and then sets the value for _isMyLocationAvailable accordingly.
  Future<void> _checkMyLocationAvailability() async {
    final bool hasAccess = await _mapViewModel.checkLocationAccess();
    setState(() {
      _isMyLocationAvailable = hasAccess;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get theme colors
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isSource) _buildSegmentedButton(),
            if (_selectionMode == "outdoorLocation") _buildOutdoorLocation(),
            if (_selectionMode == "selectClassroom") _buildSelectClassroom(),
            if (!widget.isSource) _buildCalendarLink(),
          ],
        ),
      ),
    );
  }

  // Segmented button for source
  ButtonSegment<String> _buildSegment(
      String value, IconData icon, String label, bool isEnabled) {
    // Get theme colors
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final secondaryTextColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    // Explicitly specify that the ButtonSegment is of type String
    return ButtonSegment<String>(
      value: value,
      label: Text(label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: isEnabled ? textColor : secondaryTextColor.withAlpha(100),
          )),
      icon: Icon(icon,
          color: isEnabled ? textColor : secondaryTextColor.withAlpha(100)),
      enabled: isEnabled,
    );
  }

  Widget _buildSegmentedButton() {
    // Get theme colors
    final primaryColor = Theme.of(context).primaryColor;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Center(
      child: SegmentedButton<String>(
        selected: {_selectionMode},
        segments: [
          // Ensure the list is of type List<ButtonSegment<String>>
          _buildSegment("myLocation", Icons.my_location, "My Location",
              _isMyLocationAvailable),
          _buildSegment(
              "outdoorLocation", Icons.location_on, "Outdoor Location", true),
          _buildSegment(
              "selectClassroom", Icons.meeting_room, "Select Classroom", true),
        ],
        onSelectionChanged: (newValue) {
          setState(() {
            _selectionMode = newValue.first;
          });

          if (_selectionMode == "myLocation") {
            _handleMyLocationSelected();
          }
        },
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith<Color>(
            (states) => states.contains(WidgetState.selected)
                ? onPrimaryColor
                : Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (states) => states.contains(WidgetState.selected)
                ? primaryColor
                : secondaryColor.withAlpha(100),
          ),
          iconColor: WidgetStateProperty.resolveWith<Color>(
            (states) => states.contains(WidgetState.selected)
                ? onPrimaryColor
                : Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
          ),
        ),
      ),
    );
  }

  // Builds the select classroom UI
  Widget _buildSelectClassroom() {
    return Column(
      children: [
        _buildBuildingDropdown(),
        const SizedBox(height: 16),
        if (_selectedBuilding != null) _buildFloorDropdown(),
        const SizedBox(height: 16),
        if (_selectedFloor != null) _buildClassroomDropdown(),
      ],
    );
  }

  // Dropdown for selecting the building
  Widget _buildBuildingDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: _buildDropdownDecoration("Select Building"),
      value: _selectedBuilding,
      items: _buildings
          .map((b) => DropdownMenuItem<String>(
                value: b,
                child: Text(
                  b,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ))
          .toList(),
      onChanged: (value) async {
        setState(() {
          _selectedBuilding = value;
        });
        if (value != null) await _loadFloors(value);
      },
    );
  }

  // Dropdown for selecting the floor
  Widget _buildFloorDropdown() {
    return DropdownButtonFormField<String>(
      decoration: _buildDropdownDecoration("Select Floor"),
      value: _selectedFloor,
      items: _floors
          .map((f) => DropdownMenuItem<String>(
                value: f,
                child: Text(
                  f,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ))
          .toList(),
      onChanged: (value) async {
        setState(() {
          _selectedFloor = value;
        });
        if (value != null && _selectedBuilding != null) {
          await _loadRooms(_selectedBuilding!, value);
        }
      },
    );
  }

  // Dropdown for selecting the classroom
  Widget _buildClassroomDropdown() {
    return DropdownButtonFormField<ConcordiaRoom>(
      decoration: _buildDropdownDecoration("Select Classroom"),
      value: _selectedRoom,
      items: _rooms
          .map((room) => DropdownMenuItem<ConcordiaRoom>(
                value: room,
                child: Text(
                  _formatRoomNumber(room.roomNumber),
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedRoom = value;
        });
        if (value != null) {
          widget.onSelectionComplete(value);
        }
      },
    );
  }

  // Helper method for dropdown decoration
  InputDecoration _buildDropdownDecoration(String labelText) {
    final primaryColor = Theme.of(context).primaryColor;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: textColor),
      floatingLabelStyle: TextStyle(color: primaryColor),
      border: OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
      enabledBorder:
          OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2)),
    );
  }

  // Builds the link to the calendar for non-source users
  Widget _buildCalendarLink() {
    // Get theme colors
    final primaryColor = Theme.of(context).primaryColor;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final secondaryTextColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    return Column(
      children: [
        const SizedBox(height: 24),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Not sure where your next class is?",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Connect your course calendar to let us help you. Or, if you've already linked a calendar, you can access it here:",
                style: TextStyle(fontSize: 14, color: secondaryTextColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: Icon(Icons.calendar_today, color: onPrimaryColor),
                label: const Text("Course Calendar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: onPrimaryColor,
                ),
                onPressed: checkCalendarPermission,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOutdoorLocation() {
    return Column(
      children: [
        _mapViewModel.buildPlaceAutocompleteTextField(
          controller: TextEditingController(),
          onPlaceSelected: (location) {
            widget.onSelectionComplete(location);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
