import 'package:concordia_nav/data/repositories/poi_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Create a Mock class for rootBundle
class MockRootBundle extends Mock {
  Future<String>? loadString(String? path);
}

void main() {
  group('POIRepository', () {
    late POIRepository poiRepository;
    late MockRootBundle mockRootBundle;

    setUp(() {
      mockRootBundle = MockRootBundle();
      // Use the custom loadString function (mocked) in the constructor
      poiRepository = POIRepository(loadString: mockRootBundle.loadString);
    });

    test('fetchPOIData throws Exception when there is an error loading data',
        () async {
      // Arrange: Mock the rootBundle.loadString to throw an error
      when(mockRootBundle.loadString(any))
          .thenThrow(PlatformException(code: '404', message: 'Not Found'));

      // Act & Assert: Verify that calling fetchPOIData throws an exception
      expect(() async => await poiRepository.fetchPOIData(),
          throwsA(isA<Exception>()));
    });
  });
}
