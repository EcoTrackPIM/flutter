import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'CameraOptionsScreen.dart';

class EcoFriendlyFashionScanScreen extends StatefulWidget {
  @override
  _EcoFriendlyFashionScanScreenState createState() =>
      _EcoFriendlyFashionScanScreenState();
}

class _EcoFriendlyFashionScanScreenState
    extends State<EcoFriendlyFashionScanScreen> {
  String? scannedImagePath;
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> scanAndDetectFabric(BuildContext context) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    setState(() {
      scannedImagePath = image.path;
      isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
          'POST',
          Uri.parse("http://192.168.1.19:3000/upload/fabric")
      );
      request.files.add(
          await http.MultipartFile.fromPath('image', image.path)
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse["fabric"] != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraOptionsScreen(
              fabric: jsonResponse["fabric"],
              imagePath: image.path,
            ),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to detect fabric.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
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
        title: Text('Eco-Friendly Fashion Scan'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Image.asset('assets/Hanger_icon.png', height: 220),
          SizedBox(height: 10),
          Text("You're rocking the outfit today!"),
          Text("Let's make it even more eco-friendly"),
          SizedBox(height: 30),
          GestureDetector(
            onTap: () => scanAndDetectFabric(context),
            child: isLoading
                ? CircularProgressIndicator()
                : Image.asset("assets/eco_friendly_scan.png", height: 180),
          ),
          SizedBox(height: 25),
          ElevatedButton(
            onPressed: () => scanAndDetectFabric(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade900,
            ),
            child: Text("Scan Your Clothes", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}