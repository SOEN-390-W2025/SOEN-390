import 'concordia_building.dart';
import 'concordia_campus.dart';
import 'concordia_floor.dart';
import 'concordia_floor_point.dart';
import 'location.dart';
import 'room_category.dart';

class ConcordiaRoom extends Location {
  final String roomNumber;
  final RoomCategory category;
  final ConcordiaFloor floor;
  final ConcordiaFloorPoint? entrancePoint;

  ConcordiaRoom(this.roomNumber, this.category, this.floor, this.entrancePoint)
      : super(floor.lat, floor.lng, floor.name, floor.streetAddress, floor.city,
            floor.province, floor.postalCode);

  ConcordiaCampus get campus => floor.building.campus;

  ConcordiaBuilding get building => floor.building;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ConcordiaRoom) return false;
    return roomNumber == other.roomNumber && floor == other.floor;
  }

  @override
  int get hashCode => Object.hashAll([floor, roomNumber]);
}
