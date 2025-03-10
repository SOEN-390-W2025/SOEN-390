import 'package:flutter/material.dart';
import '../utils/map_viewmodel.dart';
import '../utils/splash_screen_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  final SplashScreenViewModel viewModel;

  SplashScreen({super.key, SplashScreenViewModel? viewModel})
      : viewModel =
            viewModel ?? SplashScreenViewModel(mapViewModel: MapViewModel());

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateBasedOnLocation();
  }

  Future<void> _navigateBasedOnLocation() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.navigateBasedOnLocation(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash_screen.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
