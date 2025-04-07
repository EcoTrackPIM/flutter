import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'CarboneFootPrint.dart';

class CameraOptionsScreen extends StatefulWidget {
  final String fabric;
  final String imagePath;

  CameraOptionsScreen({required this.fabric, required this.imagePath});

  @override
  _CameraOptionsScreenState createState() => _CameraOptionsScreenState();
}

class _CameraOptionsScreenState extends State<CameraOptionsScreen> {
  final List<Map<String, String>> outfits = [
    {"name": "TShirt", "image": "assets/Tshirt.png"},
    {"name": "Shirt", "image": "assets/Shirt.png"},
    {"name": "Pullover", "image": "assets/Pullover.png"},
    {"name": "Dress", "image": "assets/Dress.png"},
    {"name": "Skirt", "image": "assets/Skirt.png"},
    {"name": "Jacket", "image": "assets/Jacket.png"},
    {"name": "Jeans", "image": "assets/Jeans.png"},
    {"name": "Sweater", "image": "assets/Sweater.png"},
    {"name": "Shorts", "image": "assets/Shorts.png"},
  ];

  String? _selectedOutfit;

  double calculateCarbonFootprint(String fabric, String clothingType) {
    // Fabric carbon footprint values
    Map<String, double> fabricFootprint = {
      'linen': 2, // kg CO2 per kg of fabric
      'cotton': 2.5,
      'wool': 10,
      'polyester': 5,
      'silk': 10,
      'hemp': 0.9,
      'cashmere': 10,
      'bamboo': 3,
      'nylon': 6,
      'spandex': 5
    };

    // Clothing type weight factors
    Map<String, double> clothingWeight = {
      'TShirt': 0.2, // kg
      'Shirt': 0.3,
      'Pullover': 0.5,
      'Dress': 0.5,
      'Skirt': 0.3,
      'Jacket': 0.8,
      'Pants': 0.5,
      'Sweater': 0.4,
      'Shorts': 0.15,
      // Add more clothing types as needed
    };

    // Convert fabric to lowercase and fetch carbon footprint value
    double fabricCarbon = fabricFootprint[fabric.toLowerCase()] ?? 1.0; // Default to 1 if not found
    double clothingWeightFactor = clothingWeight[clothingType] ?? 0.0;

    // Calculate total carbon footprint
    return fabricCarbon * clothingWeightFactor;
  }


  void _saveLook() async {
    if (_selectedOutfit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You should choose an outfit before saving!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    double carbonFootprint = calculateCarbonFootprint(widget.fabric, _selectedOutfit!);

    // Upload the image with the selected outfit type
    await _uploadImage(File(widget.imagePath), _selectedOutfit!);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarbonFootprintScreen(
          carbonFootprint: carbonFootprint, // Pass the calculated carbon footprint here
        ),
      ),
    );
  }

  Future<void> _uploadImage(File file, String clothingType) async {
    try {
      String uploadUrl = 'http://192.168.1.19:3000/upload'; // Change to your server URL

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: 'image.jpg'),
        'clothingType': clothingType, // Ensure clothing type is sent
      });

      final response = await Dio().post(uploadUrl, data: formData);

      print('Upload response: ${response.data}');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade200,
        title: const Text("Outfit Selection", style: TextStyle(color: Colors.black)),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Text(
              "Select your look: ${widget.fabric}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
            ),
            const SizedBox(height: 10),
            widget.imagePath.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(widget.imagePath), width: 100, height: 100, fit: BoxFit.cover),
            )
                : const Text("No image captured"),
            const SizedBox(height: 20),
            const Text(
              "Choose an outfit:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: outfits.map((outfit) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedOutfit = outfit["name"];
                    });
                  },
                  child: Column(
                    children: [
                      Image.asset(outfit["image"]!, width: 100, height: 100),
                      Text(outfit["name"]!, style: TextStyle(fontSize: 14)),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveLook,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.green.shade900,
              ),
              child: const Text(
                "Save Outfit and Calculate Carbon Footprint",
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
