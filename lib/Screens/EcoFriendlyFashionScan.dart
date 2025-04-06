import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'CameraOptionsScreen.dart';

const String BEARER_TOKEN = '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';
const String SERVER_URL = 'http://192.168.211.213:3000/upload';

class EcoFriendlyFashionScanScreen extends StatefulWidget {
  @override
  _EcoFriendlyFashionScanScreenState createState() =>
      _EcoFriendlyFashionScanScreenState();
}

class _EcoFriendlyFashionScanScreenState
    extends State<EcoFriendlyFashionScanScreen> {
  String? scannedImagePath;
  bool isLoading = false;
  String? errorMessage;
  final ImagePicker _picker = ImagePicker();
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _configureDio();
  }

  void _configureDio() {
    _dio.options.baseUrl = SERVER_URL;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Authorization': 'Bearer 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',
      'Accept': 'application/json',
    };
  }

  Future<void> _showImageSourceDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Image Source"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) return;

      setState(() {
        scannedImagePath = image.path;
        isLoading = true;
        errorMessage = null;
      });

      await _uploadAndDetectFabric(image);
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Image selection failed: ${e.toString()}';
      });
    }
  }

  Future<void> _uploadAndDetectFabric(XFile image) async {
    try {
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          image.path,
          filename: 'fabric_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      print('Attempting to upload to: $SERVER_URL');

      final response = await _dio.post(
        '/upload',
        data: formData,
        onSendProgress: (sent, total) {
          print('Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%');
        },
      );

      print('Response received: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data['fabric'] != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraOptionsScreen(
              fabric: response.data['fabric'],
              imagePath: image.path,
            ),
          ),
        );
      } else {
        throw Exception(response.data['message'] ?? 'Invalid server response');
      }
    } on DioError catch (e) {
      print('Dio Error Details:');
      print('- Type: ${e.type}');
      print('- Message: ${e.message}');
      print('- Response: ${e.response?.data}');

      setState(() {
        errorMessage = _getErrorMessage(e);
      });
    } catch (e) {
      print('General Error: $e');
      setState(() {
        errorMessage = 'Processing failed: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  String _getErrorMessage(DioError e) {
    switch (e.type) {
      case DioErrorType.connectionTimeout:
        return 'Connection timeout. Please check your network.';
      case DioErrorType.sendTimeout:
        return 'Send timeout. Server may be busy.';
      case DioErrorType.receiveTimeout:
        return 'Receive timeout. Server response delayed.';
      case DioErrorType.badResponse:
        return 'Server error: ${e.response?.statusCode}';
      case DioErrorType.cancel:
        return 'Request cancelled';
      case DioErrorType.unknown:
        return 'Network error: ${e.message}';
      default:
        return 'An error occurred';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green.shade200,
        title: const Text(
          'Eco-Friendly Fashion Scan',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/Hanger_icon.png',
                height: 220,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.checkroom, size: 100, color: Colors.green),
              ),
              const SizedBox(height: 20),
              const Text(
                "You're rocking the outfit today!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Let's make it even more eco-friendly",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () => _showImageSourceDialog(context),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : Image.asset(
                  "assets/eco_friendly_scan.png",
                  height: 180,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.camera_alt, size: 100, color: Colors.green),
                ),
              ),
              const SizedBox(height: 20),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ElevatedButton(
                onPressed: isLoading ? null : () => _showImageSourceDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade900,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  "Scan Your Clothes",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "How it works:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "1. Take a photo or choose from gallery\n"
                      "2. Our AI detects the fabric type\n"
                      "3. Get the carbon footprint estimate\n"
                      "4. Discover eco-friendly alternatives",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}