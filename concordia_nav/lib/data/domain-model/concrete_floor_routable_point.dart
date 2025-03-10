import 'concordia_floor.dart';
import 'floor_routable_point.dart';

class ConcreteFloorRoutablePoint implements FloorRoutablePoint {
  ConcordiaFloor _floor;

  double _positionX;

  double _positionY;

  @override
  ConcordiaFloor get floor => _floor;
  @override
  set floor(ConcordiaFloor value) => _floor = value;

  @override
  double get positionX => _positionX;
  @override
  set positionX(double value) => _positionX = value;

  @override
  double get positionY => _positionY;
  @override
  set positionY(double value) => _positionY = value;

  ConcreteFloorRoutablePoint({
    required ConcordiaFloor floor,
    required double positionX,
    required double positionY,
  })  : _floor = floor,
        _positionX = positionX,
        _positionY = positionY;
}
