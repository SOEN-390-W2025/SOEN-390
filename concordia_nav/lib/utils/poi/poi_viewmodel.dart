import 'package:flutter/material.dart';
import '../../data/domain-model/poi.dart';
import '../../data/repositories/poi_repository.dart';

/// ViewModel responsible for managing POI data and search functionality.
class POIViewModel extends ChangeNotifier {
  final POIRepository _repository = POIRepository();
  List<POIModel> _poiList = []; // Stores all POIs
  List<POIModel> _filteredPOIList = []; // Stored for search results
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController searchController = TextEditingController();

  /// Getter for filtered POI list (used in UI)
  List<POIModel> get poiList => _filteredPOIList;

  /// Getter for loading state
  bool get isLoading => _isLoading;

  /// Getter for error messages
  String? get errorMessage => _errorMessage;

  /// Constructor - Initializes POI data and sets up search listener.
  POIViewModel() {
    loadPOIData();
    searchController.addListener(_filterPOIs); // Listen for search input
  }

  /// Fetches POI data from repository
  Future<void> loadPOIData() async {
    try {
      _isLoading = true;
      notifyListeners(); // Lets us notify UI that loading has started..

      _poiList = await _repository.fetchPOIData();
      _filteredPOIList = _poiList;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Failed to load data. Try again later.";
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI that data is ready.
    }
  }

  /// Search filter logic for POI list, based on the search bar input
  void _filterPOIs() {
    String query = searchController.text.toLowerCase();

    if (query.isEmpty) {
      _filteredPOIList = _poiList;
    } else {
      _filteredPOIList = _poiList
          .where((poi) => poi.title.toLowerCase().contains(query))
          .toList();
    }

    notifyListeners();
  }

  /// Dispose method to clean up resources
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
