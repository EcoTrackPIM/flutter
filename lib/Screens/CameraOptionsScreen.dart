import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'CarboneFootPrint.dart';

const String BEARER_TOKEN = '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';
const String SERVER_URL = 'http://192.168.211.213:3000/upload';

class CameraOptionsScreen extends StatefulWidget {
  final String fabric;
  final String imagePath;

  const CameraOptionsScreen({
    Key? key,
    required this.fabric,
    required this.imagePath,
  }) : super(key: key);

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
  bool _isUploading = false;
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

  void _saveLook() async {
    if (_selectedOutfit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an outfit first"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final response = await _uploadImage(File(widget.imagePath), _selectedOutfit!);

      if (response != null && response['success'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarbonFootprintScreen(
              carbonFootprint: response['carbonFootprint']?.toDouble() ?? 0.0,
              fabric: response['fabric'] ?? widget.fabric,
              fileName: response['fileName'] ?? '',
            ),
          ),
        );
      } else {
        throw Exception(response?['message'] ?? 'Failed to process outfit');
      }
    } on DioError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${_getErrorMessage(e)}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<Map<String, dynamic>?> _uploadImage(File file, String clothingType) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: 'outfit_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        'clothingType': clothingType,
        'fabric': widget.fabric,
      });

      print('Uploading outfit data...');
      print('Clothing type: $clothingType');
      print('Fabric: ${widget.fabric}');

      final response = await _dio.post(
        '/upload',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      print('Upload successful: ${response.data}');
      return response.data;
    } on DioError catch (e) {
      print('Upload Error:');
      print('- Type: ${e.type}');
      print('- Message: ${e.message}');
      print('- Response: ${e.response?.data}');
      return null;
    } catch (e) {
      print('General Upload Error: $e');
      return null;
    }
  }

  String _getErrorMessage(DioError e) {
    switch (e.type) {
      case DioErrorType.connectionTimeout:
        return 'Connection timeout';
      case DioErrorType.sendTimeout:
        return 'Upload timeout';
      case DioErrorType.receiveTimeout:
        return 'Server response timeout';
      case DioErrorType.badResponse:
        return 'Server error: ${e.response?.statusCode}';
      case DioErrorType.cancel:
        return 'Request cancelled';
      case DioErrorType.unknown:
        return 'Network error: ${e.message}';
      default:
        return 'Upload failed';
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
          onPressed: () => Navigator.pop(context),
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
              child: Image.file(
                File(widget.imagePath),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
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
                      Image.asset(
                        outfit["image"]!,
                        width: 100,
                        height: 100,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported, size: 50),
                      ),
                      Text(outfit["name"]!, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _saveLook,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.green.shade900,
                minimumSize: const Size(double.infinity, 50),
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