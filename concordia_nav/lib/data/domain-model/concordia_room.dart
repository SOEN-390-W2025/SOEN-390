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
}
