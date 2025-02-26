import 'concordia_building.dart';
import 'location.dart';

class ConcordiaFloor extends Location {
  final String floorNumber;
  final ConcordiaBuilding building;
  double pixelsPerSecond;

  ConcordiaFloor(this.floorNumber, this.building, [this.pixelsPerSecond = 1.0])
      : super(building.lat, building.lng, building.name, building.streetAddress,
            building.city, building.province, building.postalCode);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ConcordiaFloor) return false;
    return other.floorNumber == floorNumber &&
        other.building.abbreviation == building.abbreviation;
  }

  @override
  int get hashCode => floorNumber.hashCode ^ building.abbreviation.hashCode;
}
