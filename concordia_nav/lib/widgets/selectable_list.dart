import 'package:flutter/material.dart';

class SelectableList<T> extends StatelessWidget {
  final List<T> items;
  final String title;
  final Function(T) onItemSelected;
  final TextEditingController searchController;

  const SelectableList({
    super.key,
    required this.items,
    required this.title,
    required this.onItemSelected,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    // Get theme colors
    final primaryColor = Theme.of(context).primaryColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final cardColor = Theme.of(context).cardColor;

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
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.normal,
              color: textColor,
            ),
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
                    backgroundColor: cardColor,
                    foregroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  child: Text(
                    item.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                      fontWeight: FontWeight.normal,
                    ),
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