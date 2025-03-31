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
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.bodyLarge?.color;
    final secondaryTextColor = theme.textTheme.bodyMedium?.color;
    final searchList =
        ModalRoute.of(context)?.settings.arguments as List<String>? ?? [];

    return ChangeNotifierProvider.value(
      value: _searchViewModel,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: customAppBar(context, 'Search'),
        body: Consumer<SearchViewModel>(
          builder: (context, viewModel, child) {
            final List<String> buildings = viewModel.filteredBuildings.isEmpty
                ? searchList
                : viewModel.filteredBuildings;

            return Semantics(
              label:
                  'Type to filter and select a building from those available.',
              child: Column(
                children: [
                  _buildSearchField(
                      viewModel, primaryColor, textColor, secondaryTextColor),
                  const SizedBox(height: 20),
                  _buildBuildingList(buildings, primaryColor, textColor),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchField(SearchViewModel viewModel, Color primaryColor,
      Color? textColor, Color? secondaryTextColor) {
    return TextField(
      style: TextStyle(color: textColor),
      onChanged: viewModel.filterBuildings,
      decoration: InputDecoration(
        labelText: 'Search for a building',
        prefixIcon: Icon(Icons.search, color: primaryColor),
        labelStyle: TextStyle(color: secondaryTextColor),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: secondaryTextColor?.withAlpha(150) ?? Colors.grey),
        ),
      ),
    );
  }

  Widget _buildBuildingList(
      List<String> buildings, Color primaryColor, Color? textColor) {
    return Expanded(
      child: ListView.builder(
        itemCount: buildings.length,
        itemBuilder: (context, index) {
          final building = buildings[index];
          final bool isSelected = _selectedBuilding == building;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedBuilding = building;
              });
              Navigator.pop(context, [building, _currentLocation]);
            },
            child: _buildBuildingTile(
                building, isSelected, primaryColor, textColor),
          );
        },
      ),
    );
  }

  Widget _buildBuildingTile(
      String building, bool isSelected, Color primaryColor, Color? textColor) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withAlpha(100) : null,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 0.5,
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
        trailing:
            isSelected ? Icon(Icons.check_circle, color: primaryColor) : null,
      ),
    );
  }
}
