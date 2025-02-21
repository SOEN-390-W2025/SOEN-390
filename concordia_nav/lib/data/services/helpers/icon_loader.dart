import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A utility class for loading and caching custom marker icons for Google Maps.
///
/// This class loads marker icons from the assets directory, converts them into
/// BitmapDescriptors, and caches them for optimized performance.
class IconLoader {
  static final Map<String, BitmapDescriptor> _cache = {};

  static Map<String, BitmapDescriptor> get cache => _cache;

  static Future<ByteData> Function(String) loadFunction = rootBundle.load;

  /// Loads a [BitmapDescriptor] for the given [iconPath].
  ///
  /// If the icon has been previously loaded, it is retrieved from the cache.
  /// Otherwise, it is loaded from assets, converted to a bitmap, and cached.
  ///
  /// If an error occurs while loading, a default icon is loaded instead
  /// (a FontAwesome Graduation cap.)
  static Future<BitmapDescriptor> loadBitmapDescriptor(String iconPath) async {
    if (_cache.containsKey(iconPath)) {
      return _cache[iconPath]!;
    }

    ByteData data;
    try {
      data = await loadFunction(iconPath);
    } on FlutterError catch (e) {
      debugPrint("Error loading icon $iconPath: $e");
      data = await rootBundle.load('assets/icons/default.png');
    }

    final BitmapDescriptor bitmapDescriptor =
        await _convertToBitmapDescriptor(data);
    _cache[iconPath] = bitmapDescriptor; // Cache the icon
    return bitmapDescriptor;
  }

  /// Converts [ByteData] to a [BitmapDescriptor] for use as a map marker icon.
  ///
  /// This method decodes an image from [ByteData], resizes it to an optimal size,
  /// and converts it into a [BitmapDescriptor].
  ///
  /// Returns a [BitmapDescriptor] that can be used with Google Maps markers.
  static Future<BitmapDescriptor> _convertToBitmapDescriptor(
      ByteData data) async {
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 80,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? byteData =
        await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    return byteData != null
        // .fromBytes is used instead of .bytes due to incorrect image scaling.
        // ignore: deprecated_member_use
        ? BitmapDescriptor.fromBytes(byteData.buffer.asUint8List())
        : BitmapDescriptor.defaultMarker;
  }
}
