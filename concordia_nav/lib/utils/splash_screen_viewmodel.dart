// ignore_for_file: prefer_final_locals, use_build_context_synchronously, avoid_catches_without_on_clauses

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/domain-model/concordia_campus.dart';
import 'map_viewmodel.dart';

class SplashScreenViewModel {
  final MapViewModel _mapViewModel = MapViewModel();

  /// Navigates to the closest campus map if the user is within 1km of either campus,
  /// otherwise navigates to the home page.
  Future<void> navigateBasedOnLocation(BuildContext context) async {
    try {
      bool hasAccess = await _mapViewModel.checkLocationAccess();
      if (!hasAccess) {
        // Navigate to home page if the user has denied location access
        await _navigateToHome(context);
        return;
      }

      // Fetch the user's current location
      LatLng? currentLocation = await _mapViewModel.fetchCurrentLocation();
      if (currentLocation == null) {
        // Navigate to home page if the user's location cannot be determined
        await _navigateToHome(context);
        return;
      }

      // Determine the distance between the user's current location
      // and both campuses
      double distanceToSGW = _mapViewModel.getDistance(
        currentLocation,
        LatLng(ConcordiaCampus.sgw.lat, ConcordiaCampus.sgw.lng),
      );
      double distanceToLOY = _mapViewModel.getDistance(
        currentLocation,
        LatLng(ConcordiaCampus.loy.lat, ConcordiaCampus.loy.lng),
      );

      // Navigate to the closest campus map if the user is within 1km
      // of either campus, otherwise navigate to the home page
      if (distanceToSGW < 1000) {
        await _navigateToCampus(context, ConcordiaCampus.sgw);
      } else if (distanceToLOY < 1000) {
        await _navigateToCampus(context, ConcordiaCampus.loy);
      } else {
        await _navigateToHome(context);
      }
    } catch (e) {
      // Navigate to home page if there is an error determining the user's location
      await _navigateToHome(context);
    }
  }

  /// Navigates to the specified campus map page.
  Future<void> _navigateToCampus(BuildContext context, ConcordiaCampus campus) async {
    // Push a replacement route to the CampusMapPage with the specified campus
    await Navigator.pushReplacementNamed(context, '/CampusMapPage', arguments: campus);
  }

  /// Navigates to the home page.
  Future<void> _navigateToHome(BuildContext context) async {
    // Push a replacement route to the HomePage
    await Navigator.pushReplacementNamed(context, '/HomePage');
  }
}
