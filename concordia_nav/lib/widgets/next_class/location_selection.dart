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
    _buildings = _buildingViewModel.getBuildings();
    _checkMyLocationAvailability();
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
    if (!mounted) return;
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
          "Your Location",
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
        "Your Location",
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
        "Your Location",
        null,
        null,
        null,
        null,
      );
      if (mounted) {
        widget.onSelectionComplete(highAccLocation);
      }
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isSource) ...[
              Center(
                child: SegmentedButton(
                  selected: {_selectionMode},
                  segments: [
                    ButtonSegment(
                      value: "myLocation",
                      label: Text(
                        "My Location",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12,
                            color: _isMyLocationAvailable
                                ? Colors.black
                                : Colors.grey),
                      ),
                      icon: Icon(Icons.my_location,
                          color: _isMyLocationAvailable
                              ? Colors.black
                              : Colors.grey),
                      enabled: _isMyLocationAvailable,
                    ),
                    const ButtonSegment(
                      value: "outdoorLocation",
                      label: Text(
                        "Outdoor Location",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                      icon: Icon(Icons.location_on),
                    ),
                    const ButtonSegment(
                      value: "selectClassroom",
                      label: Text(
                        "Select Classroom",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                      icon: Icon(Icons.meeting_room),
                    ),
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
                          ? Colors.white
                          : Colors.black,
                    ),
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (states) => states.contains(WidgetState.selected)
                          ? const Color(0xFF922238)
                          : Colors.grey[300]!,
                    ),
                    iconColor: WidgetStateProperty.resolveWith<Color>(
                      (states) => states.contains(WidgetState.selected)
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_selectionMode == "outdoorLocation") ...[
              _mapViewModel.buildPlaceAutocompleteTextField(
                controller: TextEditingController(),
                onPlaceSelected: (location) {
                  widget.onSelectionComplete(location);
                },
              ),
              const SizedBox(height: 16),
            ],
            if (_selectionMode == "selectClassroom") ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Select Building",
                  labelStyle: TextStyle(color: Colors.black),
                  floatingLabelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF922238)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF922238)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF922238), width: 2),
                  ),
                ),
                value: _selectedBuilding,
                items: _buildings
                    .map((b) => DropdownMenuItem<String>(
                          value: b,
                          child: Text(b),
                        ))
                    .toList(),
                onChanged: (value) async {
                  setState(() {
                    _selectedBuilding = value;
                  });
                  if (value != null) await _loadFloors(value);
                },
              ),
              const SizedBox(height: 16),
              if (_selectedBuilding != null)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Select Floor",
                    labelStyle: TextStyle(color: Colors.black),
                    floatingLabelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF922238)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF922238)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF922238), width: 2),
                    ),
                  ),
                  value: _selectedFloor,
                  items: _floors
                      .map((f) => DropdownMenuItem<String>(
                            value: f,
                            child: Text(f),
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
                ),
              const SizedBox(height: 16),
              if (_selectedFloor != null)
                DropdownButtonFormField<ConcordiaRoom>(
                  decoration: const InputDecoration(
                    labelText: "Select Classroom",
                    labelStyle: TextStyle(color: Colors.black),
                    floatingLabelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF922238)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF922238)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF922238), width: 2),
                    ),
                  ),
                  value: _selectedRoom,
                  items: _rooms
                      .map((room) => DropdownMenuItem<ConcordiaRoom>(
                            value: room,
                            child: Text(_formatRoomNumber(room.roomNumber)),
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
                ),
            ],
            if (!widget.isSource) ...[
              // Given that the application intends to cover a broad range of
              // users, this section is really for new users that don't know
              // building abbreviations, their next class number, etc. So, it
              // offers them the option to refer/link to their calendar.
              const SizedBox(height: 24),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Not sure where your next class is?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Connect your course calendar to let us help you. Or, if you've already linked a calendar, you can access it here:",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon:
                          const Icon(Icons.calendar_today, color: Colors.white),
                      label: const Text("Course Calendar"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF922238),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: checkCalendarPermission,
                    ),
                  ],
                ),
              ),
            ],
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child:
                      CircularProgressIndicator(color: const Color(0xFF962e42)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
