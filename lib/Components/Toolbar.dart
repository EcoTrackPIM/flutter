import 'package:flutter/material.dart';
import '../Screens/HomeScreen.dart';
import '../Screens/ScanOptionsScreen.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home - clickable
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

          // Transport - non-clickable
          IconButton(
            icon: Icon(Icons.directions_car,
                color: Colors.grey[400],
                size: 28),
            onPressed: null,
          ),

          // Food - non-clickable
          IconButton(
            icon: Icon(Icons.restaurant,
                color: Colors.grey[400],
                size: 28),
            onPressed: null,
          ),

          // Clothing - clickable
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

          // Energy - non-clickable
          IconButton(
            icon: Icon(Icons.bolt,
                color: Colors.grey[400],
                size: 28),
            onPressed: null,
          ),
        ],
      ),
    );
  }
}