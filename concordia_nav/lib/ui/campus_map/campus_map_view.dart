import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../utils/map_viewmodel.dart';
import '../../data/domain-model/concordia_campus.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/map_layout.dart';

class CampusMapPage extends StatefulWidget {
  final ConcordiaCampus campus;

  const CampusMapPage({super.key, required this.campus});

  @override
  State<CampusMapPage> createState() => CampusMapPageState();
}

class CampusMapPageState extends State<CampusMapPage> {
  final MapViewModel _mapViewModel = MapViewModel();
  final TextEditingController _searchController = TextEditingController();
  late ConcordiaCampus _currentCampus;
  Set<Polygon> _polygons = {};
  Set<Marker> _labelMarkers = {};

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
