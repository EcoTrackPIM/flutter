import 'package:flutter/material.dart';
import 'package:flutter_eco_track/Screens/OnboardingScreens.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'MainScreen.dart';
import 'loginScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final rememberMe = await _storage.read(key: "rememberMe");
    final token = await _storage.read(key: "token");

    await Future.delayed(const Duration(seconds: 2)); // Splash delay

    if (rememberMe == 'true' && token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreens()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand, // Makes the stack fill the entire screen
        children: [
          // Full-screen wallpaper background
          Image.asset(
            'assets/splash.jpg', // Your wallpaper path
            fit: BoxFit.cover, // Cover the entire screen
          ),
          // Dark overlay for better content visibility
          Container(
            color: Colors.black.withOpacity(0.3), // Adjust opacity as needed
          ),
          // Content centered on top of the wallpaper

        ],
      ),
    );
  }
}