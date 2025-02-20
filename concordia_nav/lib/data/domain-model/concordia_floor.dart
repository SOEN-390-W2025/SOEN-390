import 'concordia_building.dart';
import 'location.dart';

class ConcordiaFloor extends Location {
  final String floorNumber;
  final ConcordiaBuilding building;

  ConcordiaFloor(this.floorNumber, this.building)
      : super(building.lat, building.lng, building.name, building.streetAddress,
            building.city, building.province, building.postalCode);
}
