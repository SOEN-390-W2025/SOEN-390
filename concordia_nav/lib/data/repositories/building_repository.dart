import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  static const ConcordiaBuilding lb = ConcordiaBuilding(
      45.496909873751406,
      -73.57820044547981,
      "J.W. McConnell Building",
      "1400 boul. de Maisonneuve O",
      "Montreal",
      "QC",
      "H3H 2V8",
      "LB",
      ConcordiaCampus.sgw);

  static const ConcordiaBuilding er = ConcordiaBuilding(
      45.49619409650501,
      -73.58011045898733,
      "ER Building",
      "2155 rue Guy",
      "Montreal",
      "QC",
      "H3H 2R9",
      "ER",
      ConcordiaCampus.sgw);

  static const ConcordiaBuilding ls = ConcordiaBuilding(
      45.496347030223696,
      -73.57946998915067,
      "Learning Square",
      "1535 boul. de Maisonneuve O",
      "Montreal",
      "QC",
      "H3G 1N1",
      "LS",
      ConcordiaCampus.sgw);

  static const ConcordiaBuilding gm = ConcordiaBuilding(
      45.4959178096258,
      -73.57897610264354,
      "GM Building",
      "1550 boul. de Maisonneuve O",
      "Montreal",
      "QC",
      "H3G 1N2",
      "GM",
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

  static const ConcordiaBuilding mb = ConcordiaBuilding(
      45.49527779650513,
      -73.57905504549471,
      "John Molson School of Business",
      "1450 rue Guy",
      "Montreal",
      "QC",
      "H3H 0A1",
      "MB",
      ConcordiaCampus.sgw);

  static const ConcordiaBuilding fb = ConcordiaBuilding(
      45.49473996868246,
      -73.57762971101944,
      "Faubourg Tower",
      "1250 rue Guy",
      "Montreal",
      "QC",
      "H3H 2T4",
      "FB",
      ConcordiaCampus.sgw);

  static const ConcordiaBuilding fg = ConcordiaBuilding(
      45.49434704276696,
      -73.57844868364542,
      "Faubourg Sainte-Catherine Building",
      "1610 rue Sainte-Catherine O",
      "Montreal",
      "QC",
      "H3H 2S2",
      "FG",
      ConcordiaCampus.sgw);

  static const ConcordiaBuilding cl = ConcordiaBuilding(
      45.49423833241474,
      -73.57900293630135,
      "CL Building",
      "1665 rue Sainte-Catherine O",
      "Montreal",
      "QC",
      "H3H 1L9",
      "CL",
      ConcordiaCampus.sgw);

  static const loyolaAddress = "7141 rue Sherbrooke O";
  static const loyolaPC = "H4B 1R6";

  static const ConcordiaBuilding vl = ConcordiaBuilding(
      45.45881661941029,
      -73.63891116452257,
      "Vanier Library",
      loyolaAddress,
      "Montreal",
      "QC",
      loyolaPC,
      "VL",
      ConcordiaCampus.loy);

  static const ConcordiaBuilding fc = ConcordiaBuilding(
      45.45857671826826,
      -73.6393076015194,
      "Loyola Chapel",
      loyolaAddress,
      "Montreal",
      "QC",
      loyolaPC,
      "FC",
      ConcordiaCampus.loy);

  static const ConcordiaBuilding ad = ConcordiaBuilding(
      45.458044368765385,
      -73.63968809327562,
      "Administration Building",
      loyolaAddress,
      "Montreal",
      "QC",
      loyolaPC,
      "AD",
      ConcordiaCampus.loy);

  static const ConcordiaBuilding cj = ConcordiaBuilding(
      45.45741387037214,
      -73.64013744595343,
      "Communications and Journalism Building",
      loyolaAddress,
      "Montreal",
      "QC",
      loyolaPC,
      "CJ",
      ConcordiaCampus.loy);

  static const ConcordiaBuilding sp = ConcordiaBuilding(
      45.458185975854676,
      -73.64150755341804,
      "Richard J. Renaud Science Complex",
      loyolaAddress,
      "Montreal",
      "QC",
      loyolaPC,
      "SP",
      ConcordiaCampus.loy);

  static const ConcordiaBuilding cc = ConcordiaBuilding(
      45.45849250395193,
      -73.64063728872931,
      "Central Building",
      loyolaAddress,
      "Montreal",
      "QC",
      loyolaPC,
      "CC",
      ConcordiaCampus.loy);

  static const ConcordiaBuilding hu = ConcordiaBuilding(
      45.4585463918007,
      -73.6418677962107,
      "Applied Science Hub",
      loyolaAddress,
      "Montreal",
      "QC",
      loyolaPC,
      "hu",
      ConcordiaCampus.loy);

  static Map<String, List<ConcordiaBuilding>> buildingByCampusAbbreviation = {
    (ConcordiaCampus.sgw.abbreviation): [h, lb, er, ls, gm, ev, mb, fb, fg, cl],
    (ConcordiaCampus.loy.abbreviation): [vl, fc, ad, cj, sp, cc, hu]
  };

  static Map<String, ConcordiaBuilding> buildingByAbbreviation = {
    (BuildingRepository.h.abbreviation): h,
    (BuildingRepository.lb.abbreviation): lb,
    (BuildingRepository.er.abbreviation): er,
    (BuildingRepository.ls.abbreviation): ls,
    (BuildingRepository.gm.abbreviation): gm,
    (BuildingRepository.ev.abbreviation): ev,
    (BuildingRepository.mb.abbreviation): mb,
    (BuildingRepository.fb.abbreviation): fb,
    (BuildingRepository.fg.abbreviation): fg,
    (BuildingRepository.cl.abbreviation): cl,
    (BuildingRepository.vl.abbreviation): vl,
    (BuildingRepository.fc.abbreviation): fc,
    (BuildingRepository.ad.abbreviation): ad,
    (BuildingRepository.cj.abbreviation): cj,
    (BuildingRepository.sp.abbreviation): sp,
    (BuildingRepository.cc.abbreviation): cc,
    (BuildingRepository.hu.abbreviation): hu,
  };

  /// Loads polygons and label positions (centroids for markers) from assets.
  static Future<Map<String, dynamic>> loadBuildingPolygonsAndLabels(
      String campusName) async {
    final String path = 'assets/maps/outdoor/$campusName/polygons.json';

    try {
      final String jsonString = await rootBundle.loadString(path);
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final Map<String, List<LatLng>> polygons = {};
      final Map<String, LatLng> labelPositions = {};

      jsonData.forEach((abbr, coordinates) {
        if (buildingByAbbreviation.containsKey(abbr)) {
          final List<LatLng> points = (coordinates as List)
              .map((coord) => LatLng(coord[0], coord[1]))
              .toList();

          polygons[abbr] = points;
          labelPositions[abbr] = _calculateBoundsCenter(points);
        }
      });

      return {"polygons": polygons, "labels": labelPositions};
    } on Error catch (e) {
      if (kDebugMode) {
        print('Error loading building polygons and labels: $e');
      }
      return {"polygons": {}, "labels": {}};
    }
  }

  /// Uses LatLngBounds to find the center (centroid) of a polygon.
  static LatLng _calculateBoundsCenter(List<LatLng> points) {
    double sumLat = 0;
    double sumLng = 0;
    for (LatLng point in points) {
      sumLat += point.latitude;
      sumLng += point.longitude;
    }
    return LatLng(sumLat / points.length, sumLng / points.length);
  }
}
