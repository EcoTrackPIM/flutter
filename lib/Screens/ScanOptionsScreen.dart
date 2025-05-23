import 'package:flutter/material.dart';
import './EcoFriendlyFashionScan.dart';
import './TagScannerScreen.dart';

class ScanOptionsScreen extends StatelessWidget {
  const ScanOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Scan Options', style: TextStyle(color: Colors.black87)),
        backgroundColor: Color(0xFF4D8B6F),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  'assets/eco.png',
                  height: 150,
                  width: 150,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Choose Scan Type',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4D8B6F),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Select the scanning method that fits your needs',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              _buildModernOptionCard(
                context: context,
                icon: Icons.eco_rounded,
                title: "Eco Fashion Scan",
                subtitle: "Sustainability Analysis",
                description: "Get insights about your outfit's environmental impact",
                color: Color(0xFF4D8B6F),
                gradient: LinearGradient(
                  colors: [Color(0xFF4D8B6F), Color(0xFF6AB4E1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                titleColor: Colors.black, // Updated to black
                destination: EcoFriendlyFashionScanScreen(),
              ),
              SizedBox(height: 10),
              _buildModernOptionCard(
                context: context,
                icon: Icons.tag_rounded,
                title: "Tag Scanner",
                subtitle: "Fabric Composition",
                description: "Scan clothing tags to analyze material composition",
                color: Color(0xFF4D8B6F),
                gradient: LinearGradient(
                  colors: [Color(0xFF4D8B6F), Color(0xFF6AB4E1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                titleColor: Colors.black, // Updated to black
                destination: TagScannerScreen(),
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required Gradient gradient,
    required Color titleColor,
    required Widget destination,
  }) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => destination)),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(gradient: gradient),
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 28, color: Color(0xFF4D8B6F)),
                ),
                SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: titleColor, // black now
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_forward, color: Color(0xFF4D8B6F)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
