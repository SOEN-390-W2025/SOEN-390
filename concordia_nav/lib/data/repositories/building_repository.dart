import '../domain-model/concordia_building.dart';
import '../domain-model/concordia_campus.dart';

class BuildingRepository {
  static const ConcordiaBuilding h = ConcordiaBuilding(
      45.49721130711485,
      -73.5787529114208,
      "Hall Building",
      "1455 boul. de Maisonneuve O",
      "Montreal",
      "QC",
      "H3G 1M8",
      "H",
      ConcordiaCampus.sgw);

  static const ConcordiaBuilding ev = ConcordiaBuilding(
      45.49542095329432,
      -73.5779627198065,
      "EV Building",
      "1515 rue Sainte-Catherine O",
      "Montreal",
      "QC",
      "H3G 2H7",
      "EV",
      ConcordiaCampus.sgw);

  static Map<String, List<ConcordiaBuilding>> buildingByCampusAbbreviation = {
    (ConcordiaCampus.sgw.abbreviation): [h, ev],
    (ConcordiaCampus.loy.abbreviation): []
  };

  static Map<String, ConcordiaBuilding> buildingByAbbreviation = {
    (BuildingRepository.h.abbreviation): h,
    (BuildingRepository.ev.abbreviation): ev
  };
}
