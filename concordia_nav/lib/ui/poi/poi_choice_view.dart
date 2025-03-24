import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/poi/poi_viewmodel.dart';
import '../../widgets/custom_appbar.dart';

class POIChoiceView extends StatefulWidget {
  final POIViewModel? viewModel;
  const POIChoiceView({super.key, this.viewModel});

  @override
  State<POIChoiceView> createState() => _POIChoiceViewState();
}

class _POIChoiceViewState extends State<POIChoiceView>
    with SingleTickerProviderStateMixin {
  late POIViewModel _viewModel;
  late TabController _tabController;
  late TextEditingController _searchController;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? POIViewModel();
    _tabController = TabController(length: 2, vsync: this);
    _searchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) {
        _viewModel.init(); // Load both indoor and outdoor POIs
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<POIViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoadingLocation) {
            return _buildLoadingLocationScreen();
          }

          if (!viewModel.hasLocationPermission) {
            return _buildLocationErrorScreen(viewModel);
          }

          return _buildMainScreen(viewModel);
        },
      ),
    );
  }

  // Loading location screen
  Widget _buildLoadingLocationScreen() {
    return Scaffold(
      appBar: customAppBar(context, 'Loading Location'),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Determining your location...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Location error screen
  Widget _buildLocationErrorScreen(POIViewModel viewModel) {
    return Scaffold(
      appBar: customAppBar(context, 'Location Required'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Could not determine your location. Please check location permissions.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => viewModel.refreshLocation(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Main screen with tabs
  Widget _buildMainScreen(POIViewModel viewModel) {
    return Scaffold(
      appBar: customAppBar(context, 'POI List'),
      body: Column(
        children: [
          _buildSearchBar(viewModel),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildIndoorTab(viewModel),
                _buildOutdoorTab(viewModel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab bar
  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'Indoor'),
        Tab(text: 'Outdoor'),
      ],
      labelColor: Theme.of(context).primaryColor,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Theme.of(context).primaryColor,
    );
  }

  // Search bar
  Widget _buildSearchBar(POIViewModel viewModel) {
    // Set the controller's text to match the current query value
    _searchController.text = viewModel.globalSearchQuery;

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
            controller: _searchController,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              labelText: 'Search POIs',
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
              suffixIcon: viewModel.globalSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        viewModel.setGlobalSearchQuery('');
                      },
                    )
                  : null,
            ),
            style: const TextStyle(color: Colors.grey),
            onChanged: (query) => viewModel.setGlobalSearchQuery(query),
          ),
        ));
  }

  // Indoor tab content
  Widget _buildIndoorTab(POIViewModel viewModel) {
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
          child: _buildIndoorContent(viewModel),
        ),
      ],
    );
  }

  // Indoor content (loading, error, or grid)
  Widget _buildIndoorContent(POIViewModel viewModel) {
    if (viewModel.isLoadingIndoor) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorIndoor.isNotEmpty) {
      return _buildErrorState(
          viewModel.errorIndoor, () => viewModel.loadIndoorPOIs());
    }

    if (!viewModel.hasMatchingIndoorPOIs()) {
      return _buildEmptyState(
          'No indoor POIs found. Try changing your search.');
    }

    return _buildIndoorPOIGrid(viewModel);
  }

  // Indoor POI grid
  Widget _buildIndoorPOIGrid(POIViewModel viewModel) {
    final filteredPOIs = viewModel.filterPOIsWithGlobalSearch();
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
          final firstPoi =
              filteredPOIs.firstWhere((poi) => poi.name == poiName);
          final iconData = viewModel.getIconForPOICategory(firstPoi.category);

          return _buildPOICard(
              poiName: poiName,
              iconData: iconData,
              onTap: () => {
                    if (!_disposed)
                      {
                        Navigator.pushNamed(
                          context,
                          '/POIMapView',
                          arguments: {
                            'poiName': poiName,
                            'poiChoiceViewModel': viewModel,
                            'isOutdoor': false,
                          },
                        )
                      }
                  });
        },
      ),
    );
  }

  // Outdoor tab content
  Widget _buildOutdoorTab(POIViewModel viewModel) {
    return Column(
      children: [
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
        Expanded(
          child: _buildOutdoorContent(viewModel),
        ),
      ],
    );
  }

  // Outdoor content (loading, error, or grid)
  Widget _buildOutdoorContent(POIViewModel viewModel) {
    if (viewModel.isLoadingOutdoor) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorOutdoor.isNotEmpty) {
      return _buildErrorState(viewModel.errorOutdoor,
          () => viewModel.loadOutdoorPOIs(viewModel.selectedOutdoorCategory));
    }

    if (!viewModel.hasMatchingCategories()) {
      return _buildEmptyState('No categories match your search.');
    }

    return _buildOutdoorCategoryGrid(viewModel);
  }

  // Outdoor category grid
  Widget _buildOutdoorCategoryGrid(POIViewModel viewModel) {
    final categories = viewModel.getOutdoorCategories();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          return _buildPOICard(
              poiName: category['label'],
              iconData: category['icon'],
              onTap: () =>
                  viewModel.navigateToNearbyPOIMap(context, category['type']));
        },
      ),
    );
  }

  // Reusable POI/category card
  Widget _buildPOICard(
      {required String poiName,
      required IconData iconData,
      required VoidCallback onTap}) {
    return Material(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
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
  }

  // Reusable error state widget
  Widget _buildErrorState(String errorMessage, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error: $errorMessage',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Reusable empty state widget
  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }
}
