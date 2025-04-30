
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eco_track/Screens/items_list_screen.dart';
import 'package:flutter_eco_track/Screens/rapport.dart';
import 'package:flutter_eco_track/Screens/realTimeScan.dart';
import 'package:flutter_eco_track/food/food.dart';
import 'dart:math';
import './profile_screen.dart';
import './SettingsScreen.dart';
import './ScanOptionsScreen.dart';
import './distance_map.dart';
import './eco_outfit_challenge_screen.dart';
import '../Api/authApi.dart';
import 'CookiesScreen.dart';
import 'package:image_picker/image_picker.dart';

// String extension for capitalizing first letter
extension StringExtension on String {
String capitalize() {
return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
}
}

class Bubble {
double size;
double x;
double y;
double speed;
double direction;
Color color;

Bubble({
required this.size,
required this.x,
required this.y,
required this.speed,
required this.direction,
required this.color,
});

void update() {
x += cos(direction) * speed;
y += sin(direction) * speed;
}
}

class HomeScreen extends StatefulWidget {
@override
_HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
int _selectedFeatureIndex = 0;
late TabController _tabController;
final ScrollController _scrollController = ScrollController();
final Map<int, GlobalKey> _cardKeys = {
1: GlobalKey(),
2: GlobalKey(),
3: GlobalKey(),
4: GlobalKey(),
};
bool _showChallenges = false;

// Bubble animation variables
late AnimationController _bubbleController;
List<Bubble> bubbles = [];
final Random _random = Random();

final List<Map<String, dynamic>> _challenges = [
{
"title": " CO2 Food Challenges",
"icon": Icons.directions_walk,
"color": Color(0xFF8FB996),
"progress": 0.4
},
{
"title": " CO2 Clothes Challenges",
"icon": Icons.eco,
"color": Color(0xFF4D996F),
"progress": 0.0,
"type": "carbon_trend",
"description": "Maintain a decreasing carbon footprint trend",
"target": "5+ consecutive improvements",
"route": "/eco-progress"
},
{
"title": "CO2 Transport Challenges",
"icon": Icons.restaurant,
"color": Color(0xFF4D8B6F),
"progress": 0.7
}
];

// Stats variables
double wasteProgress = 44 / 290;
double recoveryProgress = 3 / 10;
double cookiesProgress = 1 / 3;
final ImagePicker _picker = ImagePicker();

@override
void initState() {
super.initState();
_tabController = TabController(length: 4, vsync: this);

// Initialize bubble animation
_bubbleController = AnimationController(
vsync: this,
duration: Duration(seconds: 30),
)..repeat();

// Create initial bubbles
_generateBubbles();
}

void _generateBubbles() {
bubbles = List.generate(15, (index) {
return Bubble(
size: _random.nextDouble() * 20 + 10,
x: _random.nextDouble() * 300,
y: _random.nextDouble() * 200,
speed: _random.nextDouble() * 0.5 + 0.1,
direction: _random.nextDouble() * 2 * pi,
color: Colors.white.withOpacity(_random.nextDouble() * 0.3 + 0.1),
);
});
}

@override
void dispose() {
_bubbleController.dispose();
_tabController.dispose();
_scrollController.dispose();
super.dispose();
}

Widget _buildChallengeCard(Map<String, dynamic> challenge) {
return GestureDetector(
onTap: () async {
if (challenge['type'] == 'carbon_trend') {
try {
final userId = await ApiService().getUserId();
if (userId == null) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('User not authenticated'),
backgroundColor: Colors.red,
),
);
return;
}
final ecoData = await ApiService().getEcoProgress(userId);
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => EcoProgressScreen(ecoData: ecoData),
),
);
} catch (e) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Error loading data: $e'),
backgroundColor: Colors.red,
),
);
}
}
},
child: Container(
margin: EdgeInsets.only(bottom: 8),
padding: EdgeInsets.all(12),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(12),
boxShadow: [
BoxShadow(
color: Colors.black12,
blurRadius: 4,
offset: Offset(0, 2),
),
],
),
child: Row(
children: [
Container(
width: 36,
height: 36,
decoration: BoxDecoration(
color: challenge["color"].withOpacity(0.2),
shape: BoxShape.circle,
),
child: Icon(
challenge["icon"],
color: challenge["color"],
size: 20,
),
),
SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
challenge["title"],
style: TextStyle(
fontWeight: FontWeight.w600,
fontSize: 14,
),
),
SizedBox(height: 4),
LinearProgressIndicator(
value: challenge["progress"],
backgroundColor: Colors.grey[200],
valueColor: AlwaysStoppedAnimation<Color>(challenge["color"]),
minHeight: 4,
borderRadius: BorderRadius.circular(2),
),
],
),
),
],
),
),
);
}

Widget _buildCarbonFootprintCard() {
return _buildMetricCard(
icon: Icon(Icons.eco, size: 20, color: Color(0xFFFB2C36)),
iconColor: Color(0xFFFB2C36),
title: 'Waste',
value: '${(wasteProgress * 100).toStringAsFixed(0)}',
subtitle: 'kg CO₂ saved',
);
}

Widget _buildWasteReductionCard() {
return _buildMetricCard(
icon: Icon(Icons.eco, size: 20, color: Color(0xFF4D8B6F)),
iconColor: Color(0xFF4D8B6F),
title: 'Recovery',
value: '${(recoveryProgress * 100).toStringAsFixed(0)}',
subtitle: 'activities',
);
}

Widget _buildCookiesCard(BuildContext context) {
return GestureDetector(
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => CookiesScreen(
cookieCount: (cookiesProgress * 20).toInt(),
),
),
).then((value) {
if (value != null) {
setState(() {
cookiesProgress = value / 20;
});
}
});
},
child: _buildMetricCard(
icon: Image.asset(
'assets/cookies.png',
width: 20,
height: 20,
),
iconColor: Colors.transparent,
title: 'Cookies',
value: '${(cookiesProgress * 20).toStringAsFixed(0)}',
subtitle: '/20 cookies',
),
);
}

Widget _buildMetricCard({
required Widget icon,
required Color iconColor,
required String title,
required String value,
required String subtitle,
}) {
return Container(
constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 3.5),
height: 96,
padding: EdgeInsets.all(8),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(12),
boxShadow: [],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
mainAxisSize: MainAxisSize.min,
children: [
Row(
children: [
icon,
SizedBox(width: 4),
Flexible(
child: Text(
title,
style: TextStyle(
fontSize: 12,
fontWeight: FontWeight.w600,
color: Colors.black,
),
overflow: TextOverflow.ellipsis,
),
),
],
),
SizedBox(height: 4),
Text(
value,
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
color: Colors.black,
),
),
SizedBox(height: 2),
Text(
subtitle,
style: TextStyle(
fontSize: 10,
color: Color(0xFF8E8E93),
),
overflow: TextOverflow.ellipsis,
),
],
),
);
}

Widget _buildSleepCard() {
return Expanded(
child: Container(
height: 220,
padding: EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(16),
boxShadow: [
BoxShadow(
color: Colors.black12,
blurRadius: 6,
offset: Offset(0, 2),
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Icon(Icons.checkroom, size: 30, color: Color(0xFF4D8B6F)),
SizedBox(height: 12),
Text(
'Clothing',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
color: Colors.black,
),
),
SizedBox(height: 4),
Text(
'Show textile waste metrics',
style: TextStyle(
fontSize: 14,
color: Color(0xFF8E8E93),
),
),
],
),
),
);
}

Widget _buildTransportCard() {
return Expanded(
child: Container(
height: 220,
padding: EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(16),
boxShadow: [
BoxShadow(
color: Colors.black12,
blurRadius: 6,
offset: Offset(0, 2),
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Icon(Icons.directions_car_outlined, size: 30, color: Color(0xFF4D8B6F)),
SizedBox(height: 12),
Text(
'Transport',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
color: Colors.black,
),
),
SizedBox(height: 4),
Text(
'Get your transport emissions',
style: TextStyle(
fontSize: 14,
color: Color(0xFF8E8E93),
),
),
],
),
),
);
}

Widget _buildFoodCard() {
return Expanded(
child: Container(
height: 220,
padding: EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(16),
boxShadow: [
BoxShadow(
color: Colors.black12,
blurRadius: 6,
offset: Offset(0, 2),
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Icon(Icons.fastfood_outlined, size: 30, color: Color(0xFF4D8B6F)),
SizedBox(height: 12),
Text(
'Food',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
color: Colors.black,
),
),
SizedBox(height: 4),
Text(
'Show food waste metrics',
style: TextStyle(
fontSize: 14,
color: Color(0xFF8E8E93),
),
)
],
),
),
);
}

Widget _buildTrackCard() {
return Expanded(
child: Container(
height: 220,
padding: EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(16),
boxShadow: [
BoxShadow(
color: Colors.black12,
blurRadius: 6,
offset: Offset(0, 2),
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Icon(Icons.track_changes, size: 30, color: Color(0xFF4D8B6F)),
SizedBox(height: 12),
Text(
'Tracking',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
color: Colors.black,
),
),
SizedBox(height: 4),
Text(
'Track your eco journey',
style: TextStyle(
fontSize: 14,
color: Color(0xFF8E8E93),
),
),
],
),
),
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: Color(0xFFF8F9FA),
body: SafeArea(
child: SingleChildScrollView(
controller: _scrollController,
child: Column(
children: [
// Original App Bar with bubbles, logo, and challenges
GestureDetector(
onVerticalDragUpdate: (details) {
if (details.primaryDelta! > 10) {
setState(() {
_showChallenges = true;
});
} else if (details.primaryDelta! < -10) {
setState(() {
_showChallenges = false;
});
}
},
child: AnimatedContainer(
duration: Duration(milliseconds: 300),
height: _showChallenges
? MediaQuery.of(context).size.height * 0.7
    : MediaQuery.of(context).size.height * 0.35,
decoration: BoxDecoration(
color: Color(0xFF4D8B6F),
borderRadius: BorderRadius.only(
bottomLeft: Radius.circular(30),
bottomRight: Radius.circular(30),
),
),
child: Stack(
clipBehavior: Clip.none,
children: [
// Floating bubbles
AnimatedBuilder(
animation: _bubbleController,
builder: (context, child) {
for (var bubble in bubbles) {
bubble.update();
if (bubble.x < -50 || bubble.x > 400 || bubble.y < -50 || bubble.y > 300) {
bubble.x = _random.nextDouble() * 300;
bubble.y = _random.nextDouble() * 200;
bubble.direction = _random.nextDouble() * 2 * pi;
}
}
return Stack(
children: bubbles.map((bubble) {
return Positioned(
left: bubble.x,
top: bubble.y,
child: Container(
width: bubble.size,
height: bubble.size,
decoration: BoxDecoration(
shape: BoxShape.circle,
color: bubble.color,
),
),
);
}).toList(),
);
},
),

// Profile and Settings icons
Positioned(
top: 15,
right: 15,
child: Row(
children: [
IconButton(
icon: Icon(Icons.person, color: Colors.white, size: 28),
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(builder: (context) => ProfileScreen()),
);
},
),
SizedBox(width: 10),
IconButton(
icon: Icon(Icons.settings, color: Colors.white, size: 28),
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(builder: (context) => ItemsListScreen()),
);
},
),
],
),
),

// Centered Logo
Positioned(
top: 50,
left: 0,
right: 0,
child: Center(
child: Container(
width: _showChallenges ? 100 : 140,
height: _showChallenges ? 100 : 140,
decoration: BoxDecoration(
shape: BoxShape.circle,
color: Colors.white70,
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.2),
blurRadius: 10,
spreadRadius: 2,
),
],
),
child: Padding(
padding: EdgeInsets.all(_showChallenges ? 15 : 20),
child: Image.asset(
"assets/logo.png",
fit: BoxFit.contain,
),
),
),
),
),

// Swipe indicator
Positioned(
bottom: 10,
left: 0,
right: 0,
child: Column(
children: [
Icon(
_showChallenges
? Icons.keyboard_arrow_up
    : Icons.keyboard_arrow_down,
color: Colors.white.withOpacity(0.7),
size: 30,
),
Text(
_showChallenges ? "Swipe up to close" : "Swipe down for challenges",
style: TextStyle(
color: Colors.white.withOpacity(0.7),
fontSize: 12,
),
),
],
),
),

// Challenges List
if (_showChallenges)
Positioned(
left: 20,
right: 20,
top: 150,
bottom: 70,
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
"Daily Challenges",
style: TextStyle(
color: Colors.white,
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
SizedBox(height: 8),
Expanded(
child: LayoutBuilder(
builder: (context, constraints) {
return SingleChildScrollView(
physics: BouncingScrollPhysics(),
child: ConstrainedBox(
constraints: BoxConstraints(
minHeight: constraints.maxHeight,
),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
..._challenges.map((challenge) => Padding(
padding: EdgeInsets.only(bottom: 8),
child: _buildChallengeCard(challenge),
)),
SizedBox(height: 20),
],
),
),
);
},
),
),
],
),
),
],
),
),
),

// Carbon Tracker Text - Left aligned with reduced top margin
Padding(
padding: EdgeInsets.fromLTRB(20, 15, 20, 10),
child: Align(
alignment: Alignment.centerLeft,
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
],
),
),
),

// Rainbow progress circles
Center(
child: SizedBox(
width: MediaQuery.of(context).size.width * 0.9, // Responsive width
height: 150, // Adjusted height for circles
child: CustomPaint(
painter: _RainbowSemiCirclesPainter(
wasteProgress: wasteProgress,
recoveryProgress: recoveryProgress,
cookiesProgress: cookiesProgress,
),
),
),
),
SizedBox(height: 40),

// Three stat cards without fixed height container
Padding(
padding: EdgeInsets.symmetric(horizontal: 15),
child: SingleChildScrollView(
scrollDirection: Axis.horizontal,
child: Row(
children: [
Padding(
padding: EdgeInsets.only(right: 8),
child: _buildCarbonFootprintCard(),
),
Padding(
padding: EdgeInsets.only(right: 8),
child: _buildWasteReductionCard(),
),
Padding(
padding: EdgeInsets.only(right: 8),
child: _buildCookiesCard(context),
),
],
),
),
),
SizedBox(height: 10),

// Category Cards
Padding(
padding: EdgeInsets.symmetric(horizontal: 15),
child: Column(
children: [
Row(
children: [
_buildSleepCard(),
SizedBox(width: 10),
_buildTransportCard(),
],
),
SizedBox(height: 10),
Row(
children: [
_buildFoodCard(),
SizedBox(width: 10),
_buildTrackCard(),
],
),
],
),
),
SizedBox(height: 20),
],
),
),
),
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
              color: Color(0xFF4D8B6F), size: 28),
          onPressed: () {}, // Already on Home
        ),
        IconButton(
          icon: Icon(Icons.checkroom_outlined,
              color: Colors.grey, size: 28),
          onPressed: () {
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => ScanOptionsScreen()));
          },
        ),
        IconButton(
          icon: Icon(Icons.restaurant_menu_outlined,
              color: Colors.grey, size: 28),
          onPressed: () {
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => FoodScreen()));
          },
        ),
        IconButton(
          icon: Icon(Icons.alt_route_outlined,
              color: Colors.grey, size: 28),
          onPressed: () {
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => DailyRapportScreen()));
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

class _RainbowSemiCirclesPainter extends CustomPainter {
final double wasteProgress;
final double recoveryProgress;
final double cookiesProgress;

_RainbowSemiCirclesPainter({
required this.wasteProgress,
required this.recoveryProgress,
required this.cookiesProgress,
});

@override
void paint(Canvas canvas, Size size) {
final circleRadius = size.height / 4; // Slightly smaller radius for better fit
final spacing = 20.0; // Increased spacing between circles
final strokeWidth = 12.0; // Slightly thinner stroke for elegance

// Calculate centers for three circles arranged horizontally
final wasteCenter = Offset(
circleRadius + strokeWidth + spacing,
size.height / 2,
);
final recoveryCenter = Offset(
size.width / 2,
size.height / 2,
);
final cookiesCenter = Offset(
size.width - circleRadius - strokeWidth - spacing,
size.height / 2,
);

// Define colors for empty and progress parts
final Map<String, Color> emptyColors = {
'waste': Color(0xFFFFC9C9),
'recovery': Color(0xFFDCFCE7),
'cookies': Color(0xFFFEF9C2),
};

final Map<String, Color> progressColors = {
'waste': Color(0xFFFB2C36),
'recovery': Color(0xFF4D8B6F),
'cookies': Color(0xFFD4B999),
};

// Text style for percentage and labels
final percentageStyle = TextStyle(
color: Colors.black87,
fontSize: 14,
fontWeight: FontWeight.bold,
);

final labelStyle = TextStyle(
color: Colors.black54,
fontSize: 12,
fontWeight: FontWeight.w500,
);

final textPainter = TextPainter(
textAlign: TextAlign.center,
textDirection: TextDirection.ltr,
);

// Draw circle function
void drawCircle(Offset center, double progress, String type) {
// Draw background circle (empty part)
final backgroundPaint = Paint()
..color = emptyColors[type]!
..style = PaintingStyle.stroke
..strokeWidth = strokeWidth
..strokeCap = StrokeCap.round;

canvas.drawCircle(
center,
circleRadius,
backgroundPaint,
);

// Draw progress arc
final progressPaint = Paint()
..color = progressColors[type]!
..style = PaintingStyle.stroke
..strokeWidth = strokeWidth
..strokeCap = StrokeCap.round;

if (progress > 0) {
canvas.drawArc(
Rect.fromCircle(center: center, radius: circleRadius),
-pi / 2, // Start at top
2 * pi * progress, // Sweep angle based on progress
false,
progressPaint,
);
}

// Draw percentage text
final text = TextSpan(
text: '${(progress * 100).toStringAsFixed(0)}%',
style: percentageStyle,
);
textPainter.text = text;
textPainter.layout();
textPainter.paint(
canvas,
Offset(
center.dx - textPainter.width / 2,
center.dy - textPainter.height / 2 - 10, // Slightly above center
),
);

// Draw label below circle
final label = TextSpan(
text: type.capitalize(),
style: labelStyle,
);
textPainter.text = label;
textPainter.layout();
textPainter.paint(
canvas,
Offset(
center.dx - textPainter.width / 2,
center.dy + circleRadius + 10, // Below circle
),
);
}

// Draw each stat circle
drawCircle(wasteCenter, wasteProgress, 'waste');
drawCircle(recoveryCenter, recoveryProgress, 'recovery');
drawCircle(cookiesCenter, cookiesProgress, 'cookies');
}

@override
bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
