import 'package:concordia_nav/data/domain-model/concordia_building.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';

void main() {
  group('test building repository', () {
    test('get list of buildings by sgw campus abbreviation', () {
      final List<ConcordiaBuilding>? buildings = BuildingRepository.buildingByCampusAbbreviation[ConcordiaCampus.sgw.abbreviation];
      // list of sgw buildings is fetched
      expect(buildings, [BuildingRepository.h, BuildingRepository.lb, BuildingRepository.er, BuildingRepository.ls, BuildingRepository.gm, BuildingRepository.ev, BuildingRepository.mb, BuildingRepository.fb, BuildingRepository.fg, BuildingRepository.cl]);
      expect(buildings?[0], BuildingRepository.h); // first item in list is H building
      expect(buildings?[1].name, "J.W. McConnell Building");
    });

    test('get list of buildings by loy campus abbreviation', () {
      final List<ConcordiaBuilding>? buildings = BuildingRepository.buildingByCampusAbbreviation[ConcordiaCampus.loy.abbreviation];
      // list of loyola buildings is fetched
      expect(buildings, [BuildingRepository.vl, BuildingRepository.fc, BuildingRepository.ad, BuildingRepository.cj, BuildingRepository.sp, BuildingRepository.cc, BuildingRepository.hu]);
      // list has the CC building
      expect(buildings?.contains(BuildingRepository.cc), true);
      expect(buildings?[2].name, "Administration Building"); // list has the AD building
    });

    test('get building by its abbreviation', () {
      // should get building by its abbreviation
      expect(BuildingRepository.buildingByAbbreviation["CC"], BuildingRepository.cc);
      expect(BuildingRepository.buildingByAbbreviation["MB"], BuildingRepository.mb);
      // can get attributes of buildings
      expect(BuildingRepository.buildingByAbbreviation["EV"]?.name, "EV Building");
      expect(BuildingRepository.buildingByAbbreviation["EV"]?.campus, ConcordiaCampus.sgw);
    });
  });
}