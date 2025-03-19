import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/places_service.dart';
import '../../utils/poi/poi_viewmodel.dart';
import '../../widgets/custom_appbar.dart';

class POIChoiceView extends StatefulWidget {
  const POIChoiceView({super.key});

  @override
  State<POIChoiceView> createState() => _POIChoiceViewState();
}

class _POIChoiceViewState extends State<POIChoiceView> with SingleTickerProviderStateMixin {
  late POIChoiceViewModel _viewModel;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _viewModel = POIChoiceViewModel();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init(); // Load both indoor and outdoor POIs
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<POIChoiceViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: customAppBar(context, 'POI List'),
            body: Column(
              children: [
                // Global search bar - outside both tabs
                _buildSearchBar(
                  labelText: 'Search POIs',
                  query: viewModel.globalSearchQuery,
                  onChanged: (query) => viewModel.setGlobalSearchQuery(query),
                  onClear: () => viewModel.setGlobalSearchQuery(''),
                ),
                
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Indoor'),
                    Tab(text: 'Outdoor'),
                  ],
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).primaryColor,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Indoor POIs Tab
                      _buildIndoorTab(viewModel),
                      
                      // Outdoor POIs Tab
                      _buildOutdoorTab(viewModel),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  // Indoor POIs Tab - Modified to remove separate search bar
  Widget _buildIndoorTab(POIChoiceViewModel viewModel) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
            child: Text(
              'Select a nearby indoor facility',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        
        Expanded(
          child: _buildPOINameGrid(viewModel),
        ),
      ],
    );
  }
  
  // Outdoor POIs Tab - Modified to remove separate search bar and use consistent grid style
  Widget _buildOutdoorTab(POIChoiceViewModel viewModel) {
    return Column(
      children: [
        // Categories header
        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
            child: Text(
              'Select a nearby outdoor facility',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        
        // Grid of category cards with consistent style
        Expanded(
          child: _buildCategoryGrid(viewModel),
        ),
      ],
    );
  }

  // New method to build the category grid with consistent style to indoor grid
  Widget _buildCategoryGrid(POIChoiceViewModel viewModel) {
    // Categories data
    List<Map<String, dynamic>> categories = [
      {'type': PlaceType.foodDrink, 'icon': Icons.restaurant, 'label': 'Restaurants'},
      {'type': PlaceType.coffeeShop, 'icon': Icons.coffee, 'label': 'Coffee Shops'},
      {'type': PlaceType.healthCenter, 'icon': Icons.local_hospital, 'label': 'Health Centers'},
      {'type': PlaceType.studyPlace, 'icon': Icons.book, 'label': 'Study Places'},
      {'type': PlaceType.gym, 'icon': Icons.fitness_center, 'label': 'Gyms'},
      {'type': PlaceType.grocery, 'icon': Icons.shopping_cart, 'label': 'Grocery Stores'},
    ];
    
    // Filter categories based on global search query if it exists
    if (viewModel.globalSearchQuery.isNotEmpty) {
      final query = viewModel.globalSearchQuery.toLowerCase();
      categories = categories.where((category) => 
        category['label'].toString().toLowerCase().contains(query)
      ).toList();
    }
    
    if (categories.isEmpty) {
      return const Center(
        child: Text(
          'No categories match your search.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5, // Same as indoor grid
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          
          // Use same card style as indoor POIs
          return Material(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                // Set the category and navigate to the map view
                viewModel.setOutdoorCategory(category['type'], true);
                Navigator.pushNamed(
                  context,
                  '/OutdoorLocationMapView',
                  arguments: {
                    'campus': null, 
                    'category': category['type'],
                    'fromPOIChoice': true,
                    'poiViewModel': _viewModel,
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        category['label'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(category['icon']),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  // Reusable search bar widget (keeping original style)
  Widget _buildSearchBar({
    required String labelText,
    required String query,
    required Function(String) onChanged,
    required VoidCallback onClear,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[400]!,
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            labelText: labelText,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: onClear,
                )
              : null,
          ),
          style: const TextStyle(color: Colors.grey),
          onChanged: onChanged,
        ),
      )
    );
  }
  
  // Grid for indoor POIs (modified to use global search)
  Widget _buildPOINameGrid(POIChoiceViewModel viewModel) {
    if (viewModel.isLoadingIndoor) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorIndoor.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${viewModel.errorIndoor}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.loadIndoorPOIs(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Filter POIs based on global search
    final filteredPOIs = viewModel.filterPOIsWithGlobalSearch();
    
    if (filteredPOIs.isEmpty) {
      return const Center(
        child: Text(
          'No indoor POIs found. Try changing your search.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    final uniqueNames = viewModel.getUniqueFilteredPOINames(filteredPOIs);
    
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: uniqueNames.length,
        itemBuilder: (context, index) {
          final poiName = uniqueNames[index];
          final firstPoi = filteredPOIs.firstWhere((poi) => poi.name == poiName);
          final iconData = viewModel.getIconForPOICategory(firstPoi.category);

          return Material(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/POIMapView',
                  arguments: {
                    'poiName': poiName,
                    'poiChoiceViewModel': _viewModel,
                    'isOutdoor': false,
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        poiName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(iconData),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}