import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../utils/map_viewmodel.dart';
import '../../data/domain-model/concordia_campus.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/map_layout.dart';

class CampusMapPage extends StatefulWidget {
  final ConcordiaCampus campus;
  final CampusMapPageState? customState;

  const CampusMapPage({super.key, required this.campus, this.customState});

  @override
  // ignore: no_logic_in_create_state
  State<CampusMapPage> createState() => customState ?? CampusMapPageState();
}

class CampusMapPageState extends State<CampusMapPage> {
  final MapViewModel _mapViewModel;
  final TextEditingController _searchController = TextEditingController();
  late ConcordiaCampus _currentCampus;
  Set<Polygon> _polygons = {};
  Set<Marker> _labelMarkers = {};

  // Modify constructor to allow dependency injection
  CampusMapPageState({MapViewModel? mapViewModel})
      : _mapViewModel = mapViewModel ?? MapViewModel();

  @override
  void initState() {
    super.initState();
    _currentCampus = widget.campus;

    _loadMapData();
  }

  Future<void> _loadMapData() async {
    final data = await _mapViewModel.getCampusPolygonsAndLabels(_currentCampus);
    setState(() {
      _polygons = data["polygons"];
      _labelMarkers = data["labels"];
    });
  }

  Set<Polygon> get polygons => _polygons;
  Set<Marker> get labelMarkers => _labelMarkers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        _currentCampus.name,
        actionIcon: const Icon(Icons.swap_horiz, color: Colors.white),
        onActionPressed: () {
          setState(() {
            _currentCampus = _currentCampus == ConcordiaCampus.sgw
                ? ConcordiaCampus.loy
                : ConcordiaCampus.sgw;
          });
        },
      ),
      body: FutureBuilder<CameraPosition>(
        future: _mapViewModel.getInitialCameraPosition(_currentCampus),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading campus map'));
          }

          return MapLayout(
            searchController: _searchController,
            mapWidget: GoogleMap(
              buildingsEnabled: false,
              onMapCreated: _mapViewModel.onMapCreated,
              initialCameraPosition: snapshot.data!,
              polygons: _polygons,
              markers: _labelMarkers, // Add labels as markers
            ),
          );
        },
      ),
    );
  }
}
