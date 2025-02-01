/// Represents a university campus with a name, abbreviation, and coordinates.
class Campus {
  /// The full name of the campus.
  final String name;

  /// The abbreviated identifier for the campus.
  final String abbreviation;

  /// The latitude coordinate of the campus in the **WGS 84** geographic coordinate system.
  final double lat;

  /// The longitude coordinate of the campus in the **WGS 84** geographic coordinate system.
  final double lng;

  /// Private constructor to create predefined campus instances.
  const Campus._(this.name, this.abbreviation, this.lat, this.lng);

  /// The SGW (Sir George Williams) campus.
  static const Campus sgw = Campus._(
    "SGW Campus",
    "sgw",
    45.4973,
    -73.5793,
  );

  /// The LOY (Loyola) campus.
  static const Campus loy = Campus._(
    "LOY Campus",
    "loy",
    45.4582,
    -73.6405,
  );

  /// Represents an unknown or unsupported campus.
  static const Campus unknown = Campus._(
    "Unknown",
    "unknown",
    45.4582, // Preset Latitude (Concordia LOY Campus)
    -73.6405, // Preset Longitude (Concordia LOY Campus)
  );

  /// A list containing all predefined campuses.
  static const List<Campus> campuses = [sgw, loy];

  /// Returns the [Campus] instance that matches the given [abbr].
  ///
  /// If no match is found, returns [Campus.unknown].
  static Campus fromAbbreviation(String abbr) {
    return campuses.firstWhere(
      (c) => c.abbreviation == abbr,
      orElse: () => unknown,
    );
  }
}
