import 'concordia_floor.dart';
import 'location.dart';
import 'room_category.dart';

class ConcordiaRoom extends Location {
  final String roomNumber;
  final RoomCategory category;
  final ConcordiaFloor floor;

  ConcordiaRoom(this.roomNumber, this.category, this.floor)
      : super(floor.lat, floor.lng, floor.name, floor.streetAddress, floor.city,
            floor.province, floor.postalCode);
}
