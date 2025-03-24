import 'package:flutter/material.dart';
import '../../utils/building_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/indoor_search_bar.dart';
import '../../widgets/selectable_list.dart';
import 'floor_selection.dart';

/// View for building selection
class BuildingSelection extends StatefulWidget {
  final String? endRoom;
  final bool isSource;
  final bool isDisability;
  
  const BuildingSelection({
    super.key,
    this.endRoom,
    this.isSource = false,
    this.isDisability = false
  });

  @override
  BuildingSelectionState createState() => BuildingSelectionState();
}

class BuildingSelectionState extends State<BuildingSelection> {
  final BuildingViewModel _viewModel = BuildingViewModel();
  late Future<List<String>> _buildingsFuture;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load buildings with data using the ViewModel
    _buildingsFuture = _viewModel.getAvailableBuildings();
    
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
      appBar: customAppBar(context, 'Floor Navigation'),
      body: Column(
        children: [
          IndoorSearchBar(
            controller: searchController,
            hintText: 'Search',
            icon: Icons.location_on,
            iconColor: Theme.of(context).primaryColor,
          ),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _buildingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading buildings: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No buildings with floor data available'),
                  );
                } else {
                  return SelectableList<String>(
                    items: snapshot.data!,
                    title: 'Select a building',
                    searchController: searchController,
                    onItemSelected: (building) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FloorSelection(
                            building: building,
                            endRoom: widget.endRoom,
                            isSource: widget.isSource,
                            isDisability: widget.isDisability,
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}