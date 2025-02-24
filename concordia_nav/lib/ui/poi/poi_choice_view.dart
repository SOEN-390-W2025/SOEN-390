import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/poi/poi_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/poi_box.dart';


/// View that allows users to search and select nearby facilities (POIs).
/// Uses `POIViewModel` to fetch and filter data dynamically.
class POIChoiceView extends StatelessWidget {
  final POIViewModel? viewModel;

  const POIChoiceView({super.key, this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          viewModel ??
          POIViewModel(), // Use injected viewModel or create a new one
      child: Scaffold(
        appBar: customAppBar(context, 'Nearby Facilities'),
        body: Consumer<POIViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (viewModel.errorMessage != null) {
              return Center(child: Text(viewModel.errorMessage!));
            }

            final pois = viewModel.poiList;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SearchBarWidget(
                    controller: viewModel.searchController,
                    hintText: 'Search location...',
                    icon: Icons.search,
                    iconColor: Colors.black,
                    searchList: const [],
                  ),
                ),
                const SizedBox(height: 10),
                if (pois.isEmpty) const Center(child: Text("No results found")),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: pois.length,
                    itemBuilder: (context, index) {
                      final poi = pois[index];

                      return PoiBox(
                        title: poi.title,
                        icon: Icon(poi.icon),
                        onPress: () {
                          if (poi.route.isNotEmpty) {
                            Navigator.pushNamed(context, poi.route);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("No route available for this POI.")),
                            );
                          }
                        },
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
