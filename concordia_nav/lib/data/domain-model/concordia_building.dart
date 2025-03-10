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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ConcordiaBuilding) return false;
    return abbreviation == other.abbreviation;
  }

  @override
  int get hashCode => abbreviation.hashCode;
}
