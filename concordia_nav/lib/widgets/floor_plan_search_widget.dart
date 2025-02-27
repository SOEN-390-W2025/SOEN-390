import 'package:flutter/material.dart';

class FloorPlanSearchWidget extends StatelessWidget {
  final TextEditingController searchController;
  final List<String> searchList;
  final Function(String) onFloorSelected;

  const FloorPlanSearchWidget({
    super.key,
    required this.searchController,
    required this.searchList,
    required this.onFloorSelected,
  });

  Future<void> handleSelection(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context,
      '/SearchView',
      arguments: searchList,
    );

    if (result != null) {
      final selectedFloor = result as String;
      searchController.text = selectedFloor;
      onFloorSelected(selectedFloor);
    }
  }

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
                  hintText: 'Search for a floor plan',
                  border: InputBorder.none,
                  isDense: true,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onTap: () => handleSelection(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}