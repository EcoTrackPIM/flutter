import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _page = 2; // Default selected tab
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  // Define active & inactive colors
  final Color activeColor = Colors.green;  // Active icon/text color
  final Color inactiveIconColor = Color.fromARGB(255, 167, 160, 160);
  final Color inactiveTextColor = Color.fromARGB(255, 122, 113, 113);
  final Color backgroundColor = Color(0xFFF8FAFC); // Background color #f8fafc

  // List of screens
  final List<Widget> _screens = [
    Screen1(),
    Screen2(),
    Screen3(),
    Screen4(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // ✅ Apply background color
      body: _screens[_page],

      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _page,
        height: 60,
        backgroundColor: Colors.transparent,
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 300),
        items: <Widget>[
          _buildNavItem(Icons.home, "Home", 0),
          _buildNavItem(Icons.search, "Search", 1),
          _buildNavItem(Icons.shopping_cart, "Favorite", 2),
          _buildNavItem(Icons.person, "Profile", 3),
        ],
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
      ),
    );
  }

  /// Function to build a navigation item dynamically with custom colors
  Widget _buildNavItem(IconData icon, String label, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 25,
          color: (_page == index) ? activeColor : inactiveIconColor,  // Change color dynamically
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: (_page == index) ? activeColor : inactiveTextColor, // Change text color dynamically
          ),
        ),
      ],
    );
  }
}

// Screens (Dummy screens for testing)
class Screen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC), // ✅ Apply background color
      body: Center(child: Text("Home Screen", style: TextStyle(fontSize: 24))),
    );
  }
}

class Screen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC), // ✅ Apply background color
      body: Center(child: Text("Search Screen", style: TextStyle(fontSize: 24))),
    );
  }
}

class Screen3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC), // ✅ Apply background color
      body: Center(child: Text("Favorite Screen", style: TextStyle(fontSize: 24))),
    );
  }
}

class Screen4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC), // ✅ Apply background color
      body: Center(child: Text("Profile Screen", style: TextStyle(fontSize: 24))),
    );
  }
}