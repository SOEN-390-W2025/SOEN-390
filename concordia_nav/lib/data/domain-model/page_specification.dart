import 'location.dart';

class PageSpec {
  final String key; // either "I" for an IndoorView or "O" for an OutdoorView.
  final int mappingIndex; // keeps track of the total key sequence for a list.
  final String pairType;
  final Location source;
  final Location destination;
  PageSpec({
    required this.key,
    required this.mappingIndex,
    required this.pairType,
    required this.source,
    required this.destination,
  });
}
