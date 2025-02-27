import 'package:flutter/material.dart';

class FloorPlanSearchWidget extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onFloorSelected;

  const FloorPlanSearchWidget({
    super.key,
    required this.searchController,
    required this.onFloorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
           ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: Color.fromRGBO(146, 35, 56, 1),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: searchController,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Room Number',
                  border: InputBorder.none,
                  isDense: true,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (value) {
                  onFloorSelected(value); // Triggers the search dynamically
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
