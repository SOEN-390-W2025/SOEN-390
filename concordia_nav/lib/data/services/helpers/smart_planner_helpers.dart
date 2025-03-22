import '../../domain-model/location.dart';
import '../../domain-model/place.dart';

/// Generates a UUID based on [base] by appending a counter suffix if needed.
String generateUniqueId(String base, Set<String> usedIds) {
  var id = base;
  var i = 1;
  while (usedIds.contains(id)) {
    // ignore: unnecessary_string_escapes
    id = '$base\_$i';
    i++;
  }
  usedIds.add(id);
  return id;
}

/// Rebases [parsedTime] onto the day of [planDay].
/// Returns a new DateTime with the year, month, and day from [planDay] and the
/// time from [parsedTime].
DateTime rebaseTime(DateTime parsedTime, DateTime planDay) => DateTime(
    planDay.year,
    planDay.month,
    planDay.day,
    parsedTime.hour,
    parsedTime.minute,
    parsedTime.second);

/// Validates and filters a list of events so that:
/// - Each event is on the same day as [planDay],
/// - Each event's start is before its end,
/// - And events do not overlap (i.e. each event starts at or after the previous
///  event ends).
List<(String, Location, DateTime, DateTime)> validateEvents(
    List<(String, Location, DateTime, DateTime)> events, DateTime planDay) {
  events.sort((a, b) => a.$3.compareTo(b.$3));
  final valid = <(String, Location, DateTime, DateTime)>[];
  DateTime? lastEnd;
  for (var e in events) {
    if (DateTime(e.$3.year, e.$3.month, e.$3.day) != planDay) continue;
    if (lastEnd != null && e.$3.isBefore(lastEnd)) continue;
    valid.add(e);
    lastEnd = e.$4;
  }
  return valid;
}

/// Parses a [Place] object's' attributes to create a valid [Location] object.
Location parseLocationFromPlace(Place place) {
  // Based on the results shown in the Places API test screen we can do a split
  // by commas.
  // Ex. "5590 Rue Laurendeau, Montréal, QC H4E 3W3, Canada"
  // -> ["5590 Rue Laurendeau", " Montréal", " QC H4E 3W3", " Canada"]
  //
  // We then parse to fill in streetAddress, city, province, postalCode.
  // The final piece is usually the country, which we can be ignored.

  String? streetAddress;
  String? city;
  String? province;
  String? postalCode;

  if (place.address != null) {
    final rawParts = place.address!.split(',');
    final parts = rawParts.map((s) => s.trim()).toList();
    // where parts = ["5590 Rue Laurendeau", "Montréal", "QC H4E 3W3", "Canada"]

    if (parts.isNotEmpty) {
      streetAddress = parts[0]; // "5590 Rue Laurendeau"
    }
    if (parts.length > 1) {
      city = parts[1]; // "Montréal"
    }
    if (parts.length > 2) {
      // something like "QC H4E 3W3" can be further split on whitespace to
      // separate province from postal code.
      final provincePostal = parts[2].split(RegExp(r'\s+'));
      // e.g. provincePostal = ["QC", "H4E", "3W3"]

      if (provincePostal.isNotEmpty) {
        province = provincePostal.first; // "QC"
      }
      if (provincePostal.length > 1) {
        // The rest is the postal code. e.g. ["H4E", "3W3"] -> "H4E 3W3"
        postalCode = provincePostal.sublist(1).join(' ');
      }
    }
  }

  return Location(
    place.location.latitude,
    place.location.longitude,
    place.name,
    streetAddress,
    city,
    province,
    postalCode,
  );
}
