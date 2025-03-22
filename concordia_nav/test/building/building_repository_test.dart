import 'package:concordia_nav/data/domain-model/concordia_building.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/mockito.dart';

class MockRootBundle extends Mock {
  Future<String> loadString(String? path) async {
    throw Exception('Failed to load asset');
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  group('test building repository', () {
    test('loadBuildingPolygonsAndLabels handles error when loading JSON',
        () async {
      // Call the method
      final result =
          await BuildingRepository.loadBuildingPolygonsAndLabels('sgww');

      // Check if the method returns the fallback value in case of error
      expect(result, {'polygons': {}, 'labels': {}});
    });

    test('loadBuildingPolygonsAndLabels for specific campus loads properly', () async {
      // Call the method
      final result = await BuildingRepository.loadBuildingPolygonsAndLabels('sgw');

      // Check that the polygons map has the right type
      expect(result['polygons'], isA<Map<String, List<LatLng>>>());
      expect(result['polygons']['H'][0], const LatLng(45.49672, -73.578786));
      // Check that the labels map has the right type
      expect(result['labels'], isA<Map<String, LatLng>>());
    });

    test('loadAllBuildingPolygonsAndLabels loads properly', () async {
      // Call the method
      final result = await BuildingRepository.loadAllBuildingPolygonsAndLabels();

      // Check that the polygons map has the right type
      expect(result['polygons'], isA<Map<String, List<LatLng>>>());
      expect(result['polygons']['H'][0], const LatLng(45.49672, -73.578786));
      expect(result['polygons']['AD'][0], const LatLng(45.457967, -73.640003));
      // Check that the labels map has the right type
      expect(result['labels'], isA<Map<String, LatLng>>());
      expect(result['labels']['AD'], const LatLng(45.45806941176471, -73.63977700000001));
    });

    test('get list of buildings by sgw campus abbreviation', () {
      final List<ConcordiaBuilding>? buildings = BuildingRepository
          .buildingByCampusAbbreviation[ConcordiaCampus.sgw.abbreviation];
      // list of sgw buildings is fetched
      expect(buildings, [
        BuildingRepository.h,
        BuildingRepository.lb,
        BuildingRepository.er,
        BuildingRepository.ls,
        BuildingRepository.gm,
        BuildingRepository.ev,
        BuildingRepository.mb,
        BuildingRepository.fb,
        BuildingRepository.fg,
        BuildingRepository.cl
      ]);
      expect(buildings?[0],
          BuildingRepository.h); // first item in list is H building
      expect(buildings?[1].name, "J.W. McConnell Building");
    });

    test('get list of buildings by loy campus abbreviation', () {
      final List<ConcordiaBuilding>? buildings = BuildingRepository
          .buildingByCampusAbbreviation[ConcordiaCampus.loy.abbreviation];
      // list of loyola buildings is fetched
      expect(buildings, [
        BuildingRepository.vl,
        BuildingRepository.fc,
        BuildingRepository.ad,
        BuildingRepository.cj,
        BuildingRepository.sp,
        BuildingRepository.cc,
        BuildingRepository.hu
      ]);
      // list has the CC building
      expect(buildings?.contains(BuildingRepository.cc), true);
      expect(buildings?[2].name,
          "Administration Building"); // list has the AD building
    });

    test('get building by its abbreviation', () {
      // should get building by its abbreviation
      expect(BuildingRepository.buildingByAbbreviation["CC"],
          BuildingRepository.cc);
      expect(BuildingRepository.buildingByAbbreviation["MB"],
          BuildingRepository.mb);
      // can get attributes of buildings
      expect(
          BuildingRepository.buildingByAbbreviation["EV"]?.name, "EV Building");
      expect(BuildingRepository.buildingByAbbreviation["EV"]?.campus,
          ConcordiaCampus.sgw);
    });

    test('get building by its name', () {
      // should get building by its name
      expect(BuildingRepository.buildingByName["Central Building"],
          BuildingRepository.cc);
      expect(
          BuildingRepository.buildingByName["John Molson School of Business"],
          BuildingRepository.mb);

      // can get attributes of buildings
      expect(
          BuildingRepository.buildingByName["EV Building"]?.abbreviation, "EV");
      expect(BuildingRepository.buildingByName["EV Building"]?.campus,
          ConcordiaCampus.sgw);
    });
  });
}
