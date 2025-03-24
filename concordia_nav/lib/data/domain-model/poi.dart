enum POICategory {
  washroom,
  waterFountain,
  restaurant,
  elevator,
  escalator,
  stairs,
  exit,
  police,
  other,
}

class POI {
  final String id;
  final String name;
  final String buildingId;
  final String floor;
  final POICategory category;
  final double x;
  final double y;

  POI({
    required this.id,
    required this.name,
    required this.buildingId,
    required this.floor,
    required this.category,
    required this.x,
    required this.y,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is POI &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          buildingId == other.buildingId;

  @override
  int get hashCode => id.hashCode ^ buildingId.hashCode;

  @override
  String toString() => 'POI(name: $name, floor: $floor, building: $buildingId)';
}