import 'dart:io';

import 'package:flutter/material.dart';
import 'CameraOptionsScreen.dart'; // Import the CameraOptionsScreen file
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class EcoFriendlyFashionScanScreen extends StatefulWidget {
  @override
  _EcoFriendlyFashionScanScreenState createState() =>
      _EcoFriendlyFashionScanScreenState();
}

class _EcoFriendlyFashionScanScreenState
    extends State<EcoFriendlyFashionScanScreen> {
  String? scannedImagePath; // Store the scanned image path
  bool isLoading = false; // Show loading state

  Future<void> scanAndDetectFabric(BuildContext context) async {
    final imagePath = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraOptionsScreen(fabric: "linen", imagePath: '')),
    );

    if (imagePath == null) {
      print("No image captured.");
      return;
    }

    setState(() {
      scannedImagePath = imagePath;
      isLoading = true;
    });

    String backendUrl = "http://192.168.1.19:3000/upload/fabric"; // Backend URL for fabric detection

    try {
      var request = http.MultipartRequest('POST', Uri.parse(backendUrl));
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse["fabric"] != null) {
        String fabricDetected = jsonResponse["fabric"];

        // Show the detected fabric and pass it to the Outfit Selection Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraOptionsScreen(
              fabric: fabricDetected, // Pass fabric to the next screen
              imagePath: imagePath,   // Pass the image path

            ),
          ),
        );
      } else {
        print("Failed to detect fabric. Response: $jsonResponse");
        // Show an alert if fabric detection fails
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to detect fabric. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the alert
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print("Error fetching fabric data: $e");
      // Show an alert if an error occurs
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('An error occurred while processing the image.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the alert
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green.shade200,
        elevation: 0,
        title: const Text(
          'Eco-Friendly Fashion Scan',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Image.asset(
            'assets/Hanger_icon.png',
            height: 220,
            width: 220,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 10),
          const Text(
            "You're rocking the outfit today!",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const Text(
            "Let's make it even more eco-friendly",
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Scan your look:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () => scanAndDetectFabric(context),
            child: isLoading
                ? const CircularProgressIndicator() // Show loader while scanning
                : Image.asset(
              "assets/eco_friendly_scan.png",
              height: 180,
              width: 180,
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () => scanAndDetectFabric(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade900,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Scan Your Clothes",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
