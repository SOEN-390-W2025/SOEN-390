import 'package:flutter/material.dart';

class SearchViewModel extends ChangeNotifier {
  final List<String> buildings;
  List<String> filteredBuildings = [];

  SearchViewModel(this.buildings);

  void filterBuildings(String query) {
    filteredBuildings = buildings
        .where((building) => building.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners(); // Notify listeners that the state has changed
  }
}
