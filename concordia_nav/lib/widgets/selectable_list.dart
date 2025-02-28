import 'package:flutter/material.dart';

class SelectableList<T> extends StatelessWidget {
  final List<T> items;
  final String title;
  final String hintText;
  final Function(T) onItemSelected;
  final TextEditingController searchController;

  const SelectableList({
    super.key,
    required this.items,
    required this.title,
    required this.hintText,
    required this.onItemSelected,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    final List<T> filteredItems = items.where((item) {
      final String query = searchController.text.toLowerCase();
      return item.toString().toLowerCase().contains(query);
    }).toList();

    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
          ),
          const SizedBox(height: 16),
          ...filteredItems.map(
            (item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: ElevatedButton(
                  onPressed: () {
                    onItemSelected(item);
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  child: Text(
                    item.toString(),
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
