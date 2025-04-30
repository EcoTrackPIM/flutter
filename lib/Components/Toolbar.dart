import 'package:flutter/material.dart';
import 'package:flutter_eco_track/food/food.dart';
import '../Screens/HomeScreen.dart';
import '../Screens/profile_screen.dart';
import '../Screens/SettingsScreen.dart';
import '../Screens/ScanOptionsScreen.dart';
import '../Screens/rapport.dart';

class CustomToolbar extends StatelessWidget {
  final BuildContext context;
  final int currentIndex;

  const CustomToolbar({
    Key? key,
    required this.context,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.home,
                color: currentIndex == 0 ? Color(0xFF4D8B6F) : Colors.grey[700],
                size: 28),
            onPressed: () {
              if (currentIndex != 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.checkroom,
                color: currentIndex == 1 ? Color(0xFF4D8B6F) : Colors.grey[700],
                size: 28),
            onPressed: () {
              if (currentIndex != 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ScanOptionsScreen()),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.restaurant_menu,
                color: currentIndex == 2 ? Color(0xFF4D8B6F) : Colors.grey[700],
                size: 28),
            onPressed: () {
              if (currentIndex != 2) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => FoodScreen()),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.alt_route,
                color: currentIndex == 3 ? Color(0xFF4D8B6F) : Colors.grey[700],
                size: 28),
            onPressed: () {
              if (currentIndex != 3) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => DailyRapportScreen()),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.person,
                color: currentIndex == 4 ? Color(0xFF4D8B6F) : Colors.grey[700],
                size: 28),
            onPressed: () {
              if (currentIndex != 4) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
