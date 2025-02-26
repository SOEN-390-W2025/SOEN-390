import 'concordia_floor.dart';
import 'floor_routable_point.dart';

class ConcordiaFloorPoint implements FloorRoutablePoint {
  @override
  ConcordiaFloor floor;

  @override
  double positionX;

  @override
  double positionY;

  ConcordiaFloorPoint(this.floor, this.positionX, this.positionY);
}
