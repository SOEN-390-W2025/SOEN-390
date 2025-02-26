import 'package:concordia_nav/utils/search_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

//import 'map/map_viewmodel_test.mocks.dart';

void main () {
  /*late MockMapViewModel mockMapViewModel;
  
  setUp(() {
    mockMapViewModel = MockMapViewModel();
  });*/

  test('filterBuildings', () {
    // Assemble
    final buildings = ["Hall Building", "EV Building"];
    final searchViewModel = SearchViewModel(buildings);

    // Act
    searchViewModel.filterBuildings("EV");

    // Assert
    expect(searchViewModel.filteredBuildings, ["EV Building"]);
  });

}