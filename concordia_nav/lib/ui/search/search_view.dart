import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../utils/map_viewmodel.dart';
import '../../utils/search_viewmodel.dart';
import '../../widgets/custom_appbar.dart';

class SearchView extends StatefulWidget {
  final MapViewModel? mapViewModel;
  final SearchViewModel? searchViewModel;

  const SearchView({
    super.key,
    this.mapViewModel,
    this.searchViewModel,
  });

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  String? _selectedBuilding; // To keep track of the selected building
  LatLng? _currentLocation;
  late MapViewModel _mapViewModel;
  late SearchViewModel _searchViewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize mapViewModel and fetch current location after the widget's dependencies are set
    _mapViewModel = widget.mapViewModel ?? MapViewModel();
    _searchViewModel = widget.searchViewModel ?? SearchViewModel([]);
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    _currentLocation = await _mapViewModel.fetchCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    // Get theme colors
    final primaryColor = Theme.of(context).primaryColor;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodyMedium?.color;

    // Get the buildings list from the arguments passed to the page
    final searchList =
        ModalRoute.of(context)?.settings.arguments as List<String>? ?? [];

    return ChangeNotifierProvider<SearchViewModel>.value(
      value: _searchViewModel, // Use the provided or created ViewModel
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: customAppBar(context, 'Search'),
        body: Consumer<SearchViewModel>(
          builder: (context, viewModel, child) {
            return Semantics(
              label: 'Type to filter and select a building from those available.',
              child: Column(
                children: [
                  TextField(
                    style: TextStyle(color: textColor),
                    onChanged: (query) {
                      viewModel.filterBuildings(query); // Filter buildings on input
                    },
                    decoration: InputDecoration(
                      labelText: 'Search for a building',
                      prefixIcon: Icon(Icons.search, color: primaryColor),
                      labelStyle: TextStyle(
                        color: secondaryTextColor,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: primaryColor), // Color when focused
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: secondaryTextColor?.withOpacity(0.5) ?? Colors.grey), // Color when not focused
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // List of filtered buildings
                  Expanded(
                    child: ListView.builder(
                      itemCount: viewModel.filteredBuildings.isEmpty
                          ? searchList.length
                          : viewModel.filteredBuildings.length,
                      itemBuilder: (context, index) {
                        final String building =
                            viewModel.filteredBuildings.isEmpty
                                ? searchList[index]
                                : viewModel.filteredBuildings[index];

                        final bool isSelected = _selectedBuilding == building;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedBuilding = building; // Update the selected building
                            });

                            Navigator.pop(context, [
                              building,
                              _currentLocation
                            ]); // Return the selected building
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor.withAlpha(100)
                                  : null, // Use theme-aware selection color
                              border: Border(
                                bottom: BorderSide(
                                  color: Theme.of(context).dividerColor, // Theme-aware border color
                                  width: 0.5, // Border thickness
                                ),
                              ),
                            ),
                            child: ListTile(
                              title: Text(
                                building,
                                style: TextStyle(
                                  color: isSelected ? primaryColor : textColor,
                                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                ),
                              ),
                              trailing: isSelected 
                                ? Icon(Icons.check_circle, color: primaryColor)
                                : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}