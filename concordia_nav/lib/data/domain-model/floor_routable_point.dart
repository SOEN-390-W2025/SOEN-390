import 'concordia_floor.dart';

abstract interface class FloorRoutablePoint {
  late final ConcordiaFloor floor;

  /// The X coordinate, where the top-left point of the image file is 0, 0
  late final double positionX;

  /// The Y coordinate, where the top-left point of the image file is 0, 0
  late final double positionY;
}
