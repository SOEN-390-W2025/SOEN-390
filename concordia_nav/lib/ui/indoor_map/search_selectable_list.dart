import 'package:flutter/material.dart';
import '../../widgets/indoor_search_bar.dart';
import '../../widgets/select_indoor_destination.dart';
import '../../widgets/selectable_list.dart';

class SearchSelectableList<T> extends StatelessWidget {
  final List<T> items;
  final String title;
  final String? building;
  final TextEditingController searchController;
  final Function(T) onItemSelected;

  const SearchSelectableList({
    super.key,
    required this.items,
    required this.title,
    this.building,
    required this.searchController,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IndoorSearchBar(
          controller: searchController,
          hintText: 'Search',
          icon: Icons.location_on,
          iconColor: Theme.of(context).primaryColor,
        ),
        SelectIndoorDestination(building: building!),
        SelectableList<T>(
          items: items,
          title: title,
          searchController: searchController,
          onItemSelected: onItemSelected,
        ),
      ],
    );
  }
}
