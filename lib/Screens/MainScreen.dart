import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eco_track/Screens/HomeScreen.dart';
import 'package:flutter_eco_track/Screens/distance_map.dart';
import 'package:flutter_eco_track/Screens/food/food_screen.dart';
import 'package:flutter_eco_track/Screens/profile_screen.dart';
import 'package:flutter_eco_track/Screens/rapport.dart';
import 'package:flutter_eco_track/Screens/realTimeScan.dart';
import 'EcoFriendlyFashionScan.dart';
import 'ScanOptionsScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    ScanOptionsScreen(),
    FoodScreen(),
    DailyRapportScreen(),
    ProfileScreen()
  ];

  final Color activeColor = const Color(0xFF4D8B6F);
  final Color inactiveColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home_outlined,
                  color: _currentIndex == 0 ? activeColor : inactiveColor,
                  size: 28),
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.checkroom_outlined,
                  color: _currentIndex == 1 ? activeColor : inactiveColor,
                  size: 28),
              onPressed: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.restaurant_menu_outlined,
                  color: _currentIndex == 2 ? activeColor : inactiveColor,
                  size: 28),
              onPressed: () {
                setState(() {
                  _currentIndex = 2;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.alt_route_outlined,
                  color: _currentIndex == 3 ? activeColor : inactiveColor,
                  size: 28),
              onPressed: () {
                setState(() {
                  _currentIndex = 3;
                });
              },
            ),
            IconButton(
  icon: Icon(Icons.qr_code_scanner_outlined,
      color: Colors.grey, size: 28),
  onPressed: () async {
                          final cameras = await availableCameras();

    Navigator.push(context,
      MaterialPageRoute(builder: (_) => RealTimeScanScreen(cameras: cameras))); // Replace with your actual screen
  },
),
          ],
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title, style: TextStyle(fontSize: 35)),
    );
  }
}