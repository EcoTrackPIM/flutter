import 'package:flutter/material.dart';
import 'package:flutter_eco_track/Screens/LoginScreen.dart';
import 'homeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreens extends StatefulWidget {
  @override
  _OnboardingScreensState createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens> {



  final PageController _pageController = PageController();
  int _currentPage = 0;
  double _currentOffset = 0.0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: " Smart Transport Tracking",
      description: "Track and optimize your transportation emissions with AI-powered insights\n\n"
          "• Real-time CO₂ calculations for all transport modes\n",
      imagePath: "assets/transport222.jpg",
      color: Color(0xFFB9DB7E),
    ),
    OnboardingPage(
      title: " Sustainable Fashion Advisor",
      description: "Transform your wardrobe with ethical fashion intelligence\n\n"
          "• Scan clothes to check carbon footprint\n",
      imagePath: "assets/Clothes.png",
      color: Color(0xFFB9DB7E),
    ),
    OnboardingPage(
      title: " Nutritional Carbon Analyst",
      description: "Optimize your diet for health and sustainability\n\n"
          "• Food production lifecycle analysis\n"
          "Plant-based diets can reduce food emissions by up to 73%",
      imagePath: "assets/food222.jpg",
      color: Color(0xFFB9DB7E),
    ),
    OnboardingPage(
      title: " Energy Optimization Suite",
      description: "Master energy efficiency with smart home integration\n\n"
          "• Renewable energy transition roadmap\n"
          "Homes using our system save 2.4 tons CO₂ annually on average",
      imagePath: "assets/energy222.jpg",
      color: Color(0xFFB5E48C),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentOffset = _pageController.offset;
      });
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true); // Still save the flag

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 800),
        pageBuilder: (_, __, ___) => LoginScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              final page = _pages[index];
              final delta = (index - _currentPage).toDouble();
              final offset = _currentOffset;

              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                  }
                  return Transform.scale(
                    scale: Curves.easeOut.transform(value),
                    child: child,
                  );
                },
                child: _buildParallaxPage(page, delta, offset, index),
              );
            },
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                _buildAnimatedIndicators(),
                SizedBox(height: 15),
                _currentPage == _pages.length - 1
                    ? _buildGetStartedButton()
                    : _buildAnimatedNextButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParallaxPage(OnboardingPage page, double delta, double offset, int index) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.only(top: 30),
              child: Transform.translate(
                offset: Offset(offset * delta * 0.5, 0),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  width: 280,
                  height: 280,
                  child: Center(
                    child: Hero(
                      tag: page.imagePath,
                      child: Image.asset(
                        page.imagePath,
                        width: 320,
                        height: 320,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: 20, bottom: 10),
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    child: Text(
                      page.title,
                      key: Key(page.title),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey[800],
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 12),
                  AnimatedOpacity(
                    duration: Duration(milliseconds: 500),
                    opacity: _currentPage == index ? 1.0 : 0.0,
                    child: Text(
                      page.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIndicators() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_pages.length, (index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _currentPage == index ? 24 : 8,
            height: 8,
            margin: EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: _currentPage == index
                  ? Color(0xFFB9DB7E)
                  : Colors.grey[300]!.withOpacity(0.5),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAnimatedNextButton() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: _currentPage == _pages.length - 2 ? 130 : 110,
      child: Material(
        borderRadius: BorderRadius.circular(25),
        color: Color(0xFFB9DB7E),
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () {
            _pageController.nextPage(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Next",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.only(left: 6),
                  width: _currentPage == _pages.length - 2 ? 16 : 0,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        child: ElevatedButton(
          onPressed: _completeOnboarding,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFB9DB7E),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25)),
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            elevation: 4,
            shadowColor: Color(0xFFB9DB7E).withOpacity(0.3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Get Started",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String imagePath;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.color,
  });
}