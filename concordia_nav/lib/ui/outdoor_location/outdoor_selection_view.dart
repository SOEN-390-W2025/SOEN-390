import 'package:flutter/material.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/search_bar.dart';
import '../../../data/domain-model/campus.dart';
import 'outdoor_location_map_view.dart';

class OutdoorSelectionView extends StatelessWidget {
  const OutdoorSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    // Create controllers for the text fields
    final TextEditingController destinationController = TextEditingController();

    return Scaffold(
      appBar: customAppBar(context, 'Outdoor Location'),
      body: Center(
        child: Column(
          children: [
            // Search Bar for user to input destination
            SearchBarWidget(
              controller: destinationController,
              hintText: 'Search location ...',
              icon: Icons.search,
              iconColor: Colors.black,
            ),
            const SizedBox(height: 15),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  'Recent',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            // A Place holder Button to navigate to the map view
            ElevatedButton(
              onPressed: () {
                // On press, navigate to the map screen, passing the destination text
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OutdoorLocationMapView(
                      campus: Campus.sgw,
                      destination: destinationController.text,
                    ),
                  ),
                );
              },
              child: const Text('Go to Map'),
            ),
          ],
        ),
      ),
    );
  }
}
