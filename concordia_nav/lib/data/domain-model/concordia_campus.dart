import 'location.dart';

/// Represents a university campus with a name, abbreviation, and coordinates.
class ConcordiaCampus extends Location {
  /// The abbreviated identifier for the campus.
  final String abbreviation;

  const ConcordiaCampus(super.lat, super.lng, super.name, super.streetAddress,
      super.city, super.province, super.postalCode, this.abbreviation);

  static const ConcordiaCampus sgw = ConcordiaCampus(
      45.49721130711485,
      -73.5787529114208,
      "Sir George Williams Campus",
      "1455 boul. de Maisonneuve O",
      "Montreal",
      "QC",
      "H3G 1M8",
      "SGW");

  static const ConcordiaCampus loy = ConcordiaCampus(
      45.45887506989712,
      -73.6404461142605,
      "Loyola Campus",
      "7141 rue Sherbrooke O",
      "Montreal",
      "QC",
      "H4B 1R6",
      "LOY");

  /// A list containing all predefined campuses.
  static const List<ConcordiaCampus> campuses = [sgw, loy];

  /// Returns the [ConcordiaCampus] instance that matches the given [abbr].
  ///
  /// If no match is found, throws an [ArgumentError]
  static ConcordiaCampus fromAbbreviation(String abbr) {
    return campuses.firstWhere(
      (c) => c.abbreviation.toLowerCase() == abbr.toLowerCase(),
      orElse: () => throw ArgumentError("Invalid campus abbreviation"),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ConcordiaCampus) return false;
    return abbreviation == other.abbreviation;
  }

  @override
  int get hashCode => abbreviation.hashCode;
}
