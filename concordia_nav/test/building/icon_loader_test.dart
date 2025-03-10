import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:concordia_nav/data/services/helpers/icon_loader.dart';

class MockAssetBundle extends Mock implements AssetBundle {
  @override
  Future<ByteData> load(String key) {
    return super.noSuchMethod(
      Invocation.method(#load, [key]),
      returnValue: Future<ByteData>.value(ByteData(10)),
      returnValueForMissingStub: Future<ByteData>.value(ByteData(10)),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAssetBundle mockAssetBundle;

  setUp(() {
    IconLoader.loadFunction = (String key) => mockAssetBundle.load(key);
    mockAssetBundle = MockAssetBundle();
  });

  test('loadBitmapDescriptor uses default icon when loading fails', () async {
    // Simulate a FlutterError when loading the icon
    when(mockAssetBundle.load('assets/icons/AD.png')).thenThrow(
      FlutterError('Failed to load asset'),
    );

    // Mock default icon path loading
    final ByteData defaultData = ByteData(10);
    when(mockAssetBundle.load('assets/icons/default.png')).thenAnswer(
      (_) async => defaultData,
    );

    BitmapDescriptor? bitmapDescriptor;
    BitmapDescriptor? bitmapDescriptor2;

    try {
      // Attempt to load the custom icon (should fall back to default)
      bitmapDescriptor =
          await IconLoader.loadBitmapDescriptor('assets/icons/AD.png');

      // Ensure that the method uses the default icon if the loading fails
      expect(bitmapDescriptor, isA<BitmapDescriptor>());
      expect(IconLoader.cache.containsKey('assets/icons/AD.png'), true);

      // Test that subsequent calls retrieve the cached icon
      bitmapDescriptor2 =
          await IconLoader.loadBitmapDescriptor('assets/icons/AD.png');

      // Ensure that the second call returns the cached BitmapDescriptor
      expect(bitmapDescriptor2, bitmapDescriptor);
    } catch (e) {
      fail('Exception thrown during loadBitmapDescriptor: $e');
    }
  });
}
