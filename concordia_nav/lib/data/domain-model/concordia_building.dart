import 'concordia_campus.dart';
import 'location.dart';

class ConcordiaBuilding extends Location {
  final String abbreviation;
  final ConcordiaCampus campus;

  const ConcordiaBuilding(
      super.lat,
      super.lng,
      super.name,
      super.streetAddress,
      super.city,
      super.province,
      super.postalCode,
      this.abbreviation,
      this.campus);
}
