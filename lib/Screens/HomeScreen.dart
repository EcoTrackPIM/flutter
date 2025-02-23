import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFDAF7DE), // Light green app bar color
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              "assets/logo.png",
              width: 70, // Increased size
              height: 70, // Increased size
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.black), // Three-bar menu icon
            onPressed: () {
              // Open menu or drawer here
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "WHO ARE WE",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            buildFeatureCard(
              "assets/transport.png",
              "Track your transport emissions",
              context,
            ),
            const SizedBox(height: 20),
            buildFeatureCard(
              "assets/food.png",
              "Analyze your food's carbon footprint",
              context,
            ),
            const SizedBox(height: 20),
            buildFeatureCard(
              "assets/energy.png",
              "Energy Consumption Tracking",
              context,
            ),
            const SizedBox(height: 30), // Space before phone image

            // New Image Placeholder for "phone.png"
            Center(
              child: Container(
                width: 200,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white, // Placeholder color
                ),
                child: Image.asset("assets/phone.png", fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 40), // Space before numbered sections

            // Section 1
            buildNumberedSection(
              "assets/number1.png",
              "Track your transport emissions :",
              "Compares travel emissions in real-time, suggesting greener options like carpooling or biking.",
            ),
            const SizedBox(height: 30),

            // Section 2
            buildNumberedSection(
              "assets/number2.png",
              "Analyze your food's carbon footprint Subheading :",
              "Predicts food carbon footprints and recommends sustainable alternatives.",
            ),
            const SizedBox(height: 30),

            // Section 3
            buildNumberedSection(
              "assets/number3.png",
              "Energy Consumption Tracking:",
              "Monitors energy use via smart devices, offering savings tips.",
            ),
            const SizedBox(height: 20), // Final spacing
          ],
        ),
      ),
    );
  }

  Widget buildFeatureCard(String imagePath, String text, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50), // Oval shape like in screenshot
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(imagePath, width: 120, height: 80), // Adjusted image size
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 120,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                // Add navigation or functionality here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "Start now",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNumberedSection(String imagePath, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(imagePath, width: 50, height: 50), // Numbered icon (1, 2, 3)
        const SizedBox(width: 16), // Space between image and text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
