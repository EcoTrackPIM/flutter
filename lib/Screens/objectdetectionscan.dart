import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'CameraOptionsScreen.dart';
import 'package:pimflutter/Screens/realtimescan.dart';

const String BEARER_TOKEN = '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';
const String SERVER_URL = 'http://192.168.100.17:3000/upload';

class ObjectDetectionScanScreen extends StatefulWidget {
  @override
  _ObjectDetectionScanScreenState createState() => _ObjectDetectionScanScreenState();
}

class _ObjectDetectionScanScreenState extends State<ObjectDetectionScanScreen> {
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
      'Authorization': 'Bearer $BEARER_TOKEN',
      'Accept': 'application/json',
    };
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 85, preferredCameraDevice: CameraDevice.rear);
      if (image == null) return;

      setState(() {
        scannedImagePath = image.path;
        isLoading = true;
        errorMessage = null;
      });

      await _uploadAndDetectObject(image);
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Image selection failed: ${e.toString()}';
      });
    }
  }

  Future<void> _uploadAndDetectObject(XFile image) async {
    try {
      List<int> imageBytes = await image.readAsBytes();
      FormData formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          imageBytes,
          filename: 'object_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      final response = await _dio.post(SERVER_URL, data: formData);

      if ([200, 201].contains(response.statusCode)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraOptionsScreen(
              fabric: response.data['object'] ?? 'Unknown',
              imagePath: image.path,
              compositionData: response.data['details'] ?? {},
              brandData: response.data['category'] ?? 'Unknown',
              carbonFootprint: response.data['carbonFootprint'] ?? 0,
              message: response.data['message'] ?? '',
            ),
          ),
        );
      } else {
        throw Exception(response.data['message'] ?? 'Invalid server response');
      }
    } on DioError catch (e) {
      setState(() => errorMessage = _getErrorMessage(e));
    } catch (e) {
      setState(() => errorMessage = 'Processing failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String _getErrorMessage(DioError e) {
    if (e.response != null) {
      switch (e.response!.statusCode) {
        case 400:
          return 'File too large';
        case 413:
          return 'File too large';
        case 415:
          return 'Unsupported media type';
        default:
          return 'Server error: ${e.response!.statusCode}';
      }
    }
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
      default:
        return 'Network error: ${e.message}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Object Detector', style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.green.shade800),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Image.asset('assets/detection_logo.png', height: 100),
                const SizedBox(height: 24),
                Text("Identify the Object", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                const SizedBox(height: 8),
                Text("and calculate its carbon impact", style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final cameras = await availableCameras();
                      Navigator.push(
                       context,
    MaterialPageRoute(
      builder: (context) => RealTimeScanScreen(cameras: cameras),
    ),
  );
},
                    icon: Icon(Icons.camera_alt_rounded),
                    label: isLoading
                        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text("Scan Object", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded, color: Colors.red.shade600),
                        const SizedBox(width: 8),
                        Expanded(child: Text(errorMessage!, style: TextStyle(color: Colors.red.shade600))),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 40),
                _HowItWorksSection(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("How it works:", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.green.shade800)),
        const SizedBox(height: 16),
        _StepItem(number: 1, title: "Take a photo", description: "Capture an item using camera or select from gallery"),
        _StepItem(number: 2, title: "AI object detection", description: "Identify the object and its classification"),
        _StepItem(number: 3, title: "Carbon footprint", description: "Estimate its environmental impact"),
        _StepItem(number: 4, title: "Better choices", description: "Explore eco-friendly alternatives"),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  final int number;
  final String title;
  final String description;

  const _StepItem({required this.number, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.green.shade800, shape: BoxShape.circle),
            child: Text(number.toString(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.grey.shade800)),
                Text(description, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}