import 'package:flutter/material.dart';

class IndoorDirectionsView extends StatefulWidget {
  final String currentLocation;
  final String destination;

  const IndoorDirectionsView({
    super.key,
    required this.currentLocation,
    required this.destination,
  });

  @override
  State<IndoorDirectionsView> createState() => _IndoorDirectionsViewState();
}

class _IndoorDirectionsViewState extends State<IndoorDirectionsView> {
  String _selectedMode = 'Walking';
  final String _eta = '5 min';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // White back arrow
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Indoor Directions',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(146, 35, 56, 1),
      ),
      body: Column(
        children: [
          // Top Bar: Current Location and Destination
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // From: Your Location in a lightly outlined box
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'From: ${widget.currentLocation}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // To: H-120 in a lightly outlined box
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'To: ${widget.destination}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Mode Selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButton<String>(
              value: _selectedMode,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMode = newValue!;
                });
              },
              items: <String>['Walking', 'Accessibility', 'X']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),

          // Use Expanded to push the bottom Container to the bottom
          Expanded(
            child: Container(), // Empty container to fill the remaining space
          ),

          // Bottom Container with ETA and Start Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'ETA: $_eta',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(146, 35, 56, 1),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                  ),
                  child: const Text(
                    'Start',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}