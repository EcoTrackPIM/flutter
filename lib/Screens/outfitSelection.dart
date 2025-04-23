import 'package:flutter/material.dart';

class OutfitSelectionScreen extends StatelessWidget {
  final List<Map<String, String>> outfits = [
    {"name": "Tshirt", "image": "assets/Tshirt.png"},
    {"name": "Shirt", "image": "assets/Shirt.png"},
    {"name": "Pullover", "image": "assets/Pullover.png"},
    {"name": "Dress", "image": "assets/Dress.png"},
    {"name": "Skirt", "image": "assets/Skirt.png"},
    {"name": "Jacket", "image": "assets/Jacket.png"},
    {"name": "Jeans", "image": "assets/Jeans.png"},
    {"name": "Sweater", "image": "assets/Sweater.png"},
    {"name": "Shorts", "image": "assets/Shorts.png"},
  ];

  OutfitSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF8BC34A),
        title: const Text(
          "Outfit Selection",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select your look:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:  Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                itemCount: outfits.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5, // Adjusted aspect ratio
                  crossAxisSpacing: 10, // Spacing between columns
                  mainAxisSpacing: 10, // Spacing between rows
                ),
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            outfits[index]["image"]!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            outfits[index]["name"]!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:  Color(0xFF1B5E20),
                            ),
                            textAlign: TextAlign.center, // Center the text
                            overflow: TextOverflow.ellipsis, // Handle overflow
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8BC34A),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  // Handle save action
                },
                child: const Text(
                  "Save Look",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//changedddd