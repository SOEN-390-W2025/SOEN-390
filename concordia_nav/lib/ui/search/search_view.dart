import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../utils/map_viewmodel.dart';
import '../../utils/serach_viewmodel.dart';
import '../../widgets/custom_appbar.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  String? _selectedBuilding; // To keep track of the selected building
  LatLng? _currentLocation;
  late MapViewModel _mapViewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize mapViewModel and fetch current location after the widget's dependencies are set
    _mapViewModel = MapViewModel();
    _fetchCurrentLocation();

  }

  Future<void> _fetchCurrentLocation() async {
    _currentLocation = await _mapViewModel.fetchCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    // Get the buildings list from the arguments passed to the page
    final searchList = ModalRoute.of(context)?.settings.arguments as List<String>;

    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(searchList), // Initialize the ViewModel
      child: Scaffold(
        appBar: customAppBar(context, 'Search'),
        body: Consumer<SearchViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                TextField(
                  onChanged: (query) {
                    viewModel.filterBuildings(query); // Filter buildings on input
                  },
                  decoration: const InputDecoration(
                    labelText: 'Search for a building',
                    prefixIcon: Icon(Icons.search),
                    labelStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey), // Color when focused
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey), // Color when not focused
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
                      final String building = viewModel.filteredBuildings.isEmpty
                          ? searchList[index]
                          : viewModel.filteredBuildings[index];

                      final bool isSelected = _selectedBuilding == building;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedBuilding = building; // Update the selected building
                          });
          
                          Navigator.pop(context, [building, _currentLocation]); // Return the selected building
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color.fromARGB(132, 158, 158, 158)
                                : null, // Change color if selected
                            border: const Border(
                              bottom: BorderSide(
                                color: Colors.grey, // Border color between each item
                                width: 0.5, // Border thickness
                              ),
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              building,
                              style: TextStyle(
                                color: isSelected ? Colors.black : null,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
