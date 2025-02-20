import 'package:concordia_nav/data/domain-model/concordia_building.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/data/services/building_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main () {
  group('test building service', () {
    final BuildingService buildingService = BuildingService();
    test('getAllBuildings retrieves all buildings', () {
      // get list of buildings
      final result = buildingService.getAllBuildings();

      // check that buildings from both campuses are present
      expect(result, isA<List<ConcordiaBuilding>>());
      expect(result.contains(BuildingRepository.fb), true);
      expect(result.contains(BuildingRepository.ad), true);
    });

    test('getBuildingsByCampus returns buildings in a specific campus', () {
      // get list of buildings in sgw
      var result = buildingService.getBuildingsByCampus('SGW');

      // check that building from only sgw is present
      expect(result, isA<List<ConcordiaBuilding>>());
      expect(result.contains(BuildingRepository.ls), true);
      expect(result.contains(BuildingRepository.cj), false);

      // get list of buildings in loyola
      result = buildingService.getBuildingsByCampus('LOY');

      // check that building from only loy is present
      expect(result, isA<List<ConcordiaBuilding>>());
      expect(result.contains(BuildingRepository.h), false);
      expect(result.contains(BuildingRepository.sp), true);
    });

    test('getBuildingByAbbreviation returns the building', () {
      // get the H concordia building
      var result = buildingService.getBuildingByAbbreviation('H');

      // check that we got the right building object
      expect(result, isA<ConcordiaBuilding>());
      expect(result, BuildingRepository.h);

      // get the CC concordia building
      result = buildingService.getBuildingByAbbreviation('CC');

      // check that we got the right building object
      expect(result, isA<ConcordiaBuilding>());
      expect(result, BuildingRepository.cc);
    });

    test('getBuildingNamesForCampus returns list of names of buildings in campus', () {
      // get a list of names of buildings in sgw campus
      var result = buildingService.getBuildingNamesForCampus(ConcordiaCampus.sgw);

      // check that we got the right names of buildings in sgw
      expect(result, isA<List<String>>());
      expect(result.contains('GM Building'), true);
      expect(result.contains('Vanier Library'), false);

      // get a list of names of buildings in loy campus
      result = buildingService.getBuildingNamesForCampus(ConcordiaCampus.loy);

     // check that we got the right names of buildings in loy
      expect(result, isA<List<String>>());
      expect(result.contains('Faubourg Tower'), false);
      expect(result.contains('Loyola Chapel'), true);
    });

    test('getBuildingLocationByAbbreviation returns location of building', () {
      // get location of MB building
      var result = buildingService.getBuildingLocationByAbbreviation('MB');

      // check that we got the right location
      expect(result, isA<LatLng>());
      expect(result, LatLng(BuildingRepository.mb.lat, BuildingRepository.mb.lng));

      // get location of FC building
      result = buildingService.getBuildingLocationByAbbreviation('FC');

      // check that we got the right location
      expect(result, isA<LatLng>());
      expect(result, LatLng(BuildingRepository.fc.lat, BuildingRepository.fc.lng));
    });

    test('getbuildingByName returns a building by its name', () {
      // get VL building by its name
      var result = BuildingService.getbuildingByName('Vanier Library');

      // check that we got the right building
      expect(result, isA<ConcordiaBuilding>());
      expect(result,BuildingRepository.vl);

      // get GM builing by its name
      result = BuildingService.getbuildingByName('GM Building');

      // check that we got the right building
      expect(result, isA<ConcordiaBuilding>());
      expect(result,BuildingRepository.gm);
    });
  });
}