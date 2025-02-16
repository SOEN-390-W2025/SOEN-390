import 'package:flutter/material.dart';
import '../utils/splash_screen_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SplashScreenViewModel _viewModel = SplashScreenViewModel();

  @override
  void initState() {
    super.initState();
    _navigateBasedOnLocation();
  }

  Future<void> _navigateBasedOnLocation() async {
    await _viewModel.navigateBasedOnLocation(context);
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
