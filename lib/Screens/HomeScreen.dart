import 'package:flutter/material.dart';
import '../Components/Toolbar.dart';
import 'ScanOptionsScreen.dart';
import './objectdetectionscan.dart';
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedFeatureIndex = 0;
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _cardKeys = {
    1: GlobalKey(), // Transport
    2: GlobalKey(), // Clothing
    3: GlobalKey(), // Food
    4: GlobalKey(), // Energy
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCard(int index) {
    if (_cardKeys.containsKey(index)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_cardKeys[index]?.currentContext != null) {
          Scrollable.ensureVisible(
            _cardKeys[index]!.currentContext!,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar with logo on right and text on left
              Container(
                height: MediaQuery.of(context).size.height * 0.35,
                decoration: BoxDecoration(
                  color: Color(0xFF4D8B6F),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Stack(
                  children: [
                    // Search icon at top right
                    Positioned(
                      top: 15,
                      right: 15,
                      child: IconButton(
                        icon: Icon(Icons.search, color: Colors.white, size: 30),
                        onPressed: () {},
                      ),
                    ),

                    // Text on left
                    Positioned(
                      left: 20,
                      top: 60,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Reduce",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Your",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Carbon",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bigger logo on right
                    Positioned(
                      right: 40,
                      top: 60,
                      child: Image.asset(
                        "assets/logo.png",
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 25),

              // Welcome Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Carbon",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      "Tracker",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Track and reduce your carbon footprint",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 25),

              // Feature Categories
              Container(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  children: [
                    _buildCategoryButton("All", 0, () {
                      _scrollController.animateTo(
                        0,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }),
                    _buildCategoryButton("Transport", 1, () => _scrollToCard(1)),
                    _buildCategoryButton("Clothing", 2, () => _scrollToCard(2)),
                    _buildCategoryButton("Food", 3, () => _scrollToCard(3)),
                    _buildCategoryButton("Energy", 4, () => _scrollToCard(4)),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Feature Cards
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Transport Card
                    KeyedSubtree(
                      key: _cardKeys[1],
                      child: _buildFeatureCard(
                        title: "Transport Emissions",
                        description: "Track your transport carbon footprint",
                        iconData: Icons.directions_car,
                        imagePath: "assets/transport.png",
                        color: Color(0xFF8FB996),
                        onTap: () {},
                      ),
                    ),

                    // Clothing Card
                    KeyedSubtree(
                      key: _cardKeys[2],
                      child: _buildFeatureCard(
                        title: "Outfit Scan",
                        description: "Scan clothes to check carbon footprint",
                        iconData: Icons.qr_code_scanner,
                        imagePath: "assets/Hanger_icon.png",
                        color: Color(0xFF4D8B6F),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ScanOptionsScreen()),
                          );
                        },
                      ),
                    ),

                    // Food Card
                    KeyedSubtree(
                      key: _cardKeys[3],
                      child: _buildFeatureCard(
                        title: "Food Tracker",
                        description: "Analyze your food's carbon footprint",
                        iconData: Icons.restaurant_menu,
                        imagePath: "assets/food.png",
                        color: Color(0xFF6A8D73),
                        onTap: () {},
                      ),
                    ),

                    // Object Detection Card
KeyedSubtree(
  key: _cardKeys[5],
  child: _buildFeatureCard(
    title: "Object Detection",
    description: "Detect how much carbon the object you scanned emits in real time with your camera",
    iconData: Icons.search_rounded,
    imagePath: "assets/object_detection.png",
    color: Color(0xFF90BE6D),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ObjectDetectionScanScreen()),
      );
    },
  ),
),

                    // Energy Card
                    KeyedSubtree(
                      key: _cardKeys[4],
                      child: _buildFeatureCard(
                        title: "Energy Usage",
                        description: "Track your home energy consumption",
                        iconData: Icons.bolt,
                        imagePath: "assets/energy.png",
                        color: Color(0xFFB5E48C),
                        onTap: () {},
                      ),
                    ),

                    SizedBox(height: 20),

                    // About Us Section
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "WHO ARE WE",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildNumberedItem(
                                      "1",
                                      "Track your transport emissions",
                                      "Compare travel emissions in real-time",
                                    ),
                                    SizedBox(height: 15),
                                    _buildNumberedItem(
                                      "2",
                                      "Analyze your food's carbon footprint",
                                      "Get recommendations for sustainable alternatives",
                                    ),
                                    SizedBox(height: 15),
                                    _buildNumberedItem(
                                      "3",
                                      "Energy Consumption Tracking",
                                      "Monitor energy use and get saving tips",
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomToolbar(
        context: context,
        currentIndex: 0,
      ),
    );
  }

  Widget _buildCategoryButton(String title, int index, VoidCallback onTap) {
    bool isSelected = _selectedFeatureIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFeatureIndex = index;
        });
        onTap();
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF4D8B6F) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ]
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData iconData,
    required String imagePath,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
              child: Center(
                child: Image.asset(
                  imagePath,
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberedItem(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: Color(0xFF4D8B6F),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 3),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}