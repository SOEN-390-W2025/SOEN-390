import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/domain-model/concordia_campus.dart';
import 'map_viewmodel.dart';

class SplashScreenViewModel {
  final MapViewModel _mapViewModel = MapViewModel();

  Future<void> navigateBasedOnLocation(BuildContext context) async {
    try {
      bool hasAccess = await _mapViewModel.checkLocationAccess();
      if (!hasAccess) {
        await _navigateToHome(context);
        return;
      }

      LatLng? currentLocation = await _mapViewModel.fetchCurrentLocation();
      if (currentLocation == null) {
        await _navigateToHome(context);
        return;
      }

      double distanceToSGW = _mapViewModel.getDistance(
        currentLocation,
        LatLng(ConcordiaCampus.sgw.lat, ConcordiaCampus.sgw.lng),
      );
      double distanceToLOY = _mapViewModel.getDistance(
        currentLocation,
        LatLng(ConcordiaCampus.loy.lat, ConcordiaCampus.loy.lng),
      );

      if (distanceToSGW < 1000) {
        await _navigateToCampus(context, ConcordiaCampus.sgw);
      } else if (distanceToLOY < 1000) {
        await _navigateToCampus(context, ConcordiaCampus.loy);
      } else {
        await _navigateToHome(context);
      }
    } catch (e) {
      print('Error determining location: $e');
      await _navigateToHome(context);
    }
  }

  Future<void> _navigateToCampus(BuildContext context, ConcordiaCampus campus) async {
    await Navigator.pushReplacementNamed(context, '/CampusMapPage', arguments: campus);
  }

  Future<void> _navigateToHome(BuildContext context) async {
    await Navigator.pushReplacementNamed(context, '/HomePage');
  }
}
