import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/domain-model/poi.dart';
import '../../utils/poi/poi_viewmodel.dart';
import '../../widgets/custom_appbar.dart';

class POIChoiceView extends StatefulWidget {
  const POIChoiceView({super.key});

  @override
  State<POIChoiceView> createState() => _POIChoiceViewState();
}

class _POIChoiceViewState extends State<POIChoiceView> {
  late POIChoiceViewModel _poichoiceViewModel;

  @override
  void initState() {
    super.initState();
    _poichoiceViewModel = POIChoiceViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _poichoiceViewModel.loadPOIs();
    });
  }

  @override
  void dispose() {
    _poichoiceViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _poichoiceViewModel,
      child: Consumer<POIChoiceViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: customAppBar(context, 'POI List'),
            body: Column(
              children: [
                Padding(
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
                        suffixIcon: viewModel.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => viewModel.setSearchQuery(''),
                              )
                            : null,
                      ),
                      style: const TextStyle(color: Colors.grey),
                      onChanged: viewModel.setSearchQuery,
                    ),
                  )
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Ensures left alignment
                      children: [
                        Text(
                          'Select a nearby facility',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Indoor',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: _buildPOINameGrid(viewModel),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPOINameGrid(POIChoiceViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${viewModel.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.loadPOIs(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.filteredPOIs.isEmpty) {
      return const Center(
        child: Text(
          'No POIs found. Try changing your search.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Use uniqueFilteredPOINames to show grouped POIs by name
    final uniqueNames = viewModel.uniqueFilteredPOINames;
    
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
          // Get the first POI with this name to get the category for the icon
          final firstPoi = viewModel.filteredPOIs.firstWhere((poi) => poi.name == poiName);

          return Material(
            color: Colors.grey[200], // Light grey background for better readability
            borderRadius: BorderRadius.circular(20),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(8), // Ensures ripple effect matches the border
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/POIMapView',
                  arguments: {
                    'poiName': poiName,
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
                    _getIconForPOICategory(firstPoi.category),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Icon _getIconForPOICategory(POICategory category) {
    switch (category) {
      case POICategory.washroom:
        return const Icon(Icons.wc);
      case POICategory.waterFountain:
        return const Icon(Icons.water_drop);
      case POICategory.restaurant:
        return const Icon(Icons.restaurant);
      case POICategory.police:
        return const Icon(Icons.local_police);
      case POICategory.elevator:
        return const Icon(Icons.elevator);
      case POICategory.escalator:
        return const Icon(Icons.escalator);
      case POICategory.stairs:
        return const Icon(Icons.stairs);
      case POICategory.exit:
        return const Icon(Icons.exit_to_app);
      default:
        return const Icon(Icons.location_on);
    }
  }
}