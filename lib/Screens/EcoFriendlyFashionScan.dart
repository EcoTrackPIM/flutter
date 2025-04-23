import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'CameraOptionsScreen.dart';

const String BEARER_TOKEN = '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';
const String SERVER_URL = 'http://192.168.1.15/upload';

class EcoFriendlyFashionScanScreen extends StatefulWidget {
  const EcoFriendlyFashionScanScreen({super.key});

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
       'Authorization': 'Bearer $BEARER_TOKEN',
      'Accept': 'application/json',
    };
  }

  Future<void> _showImageSourceDialog(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Select Image Source",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ImageSourceButton(
                  icon: Icons.camera_alt_rounded,
                  label: "Camera",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                  color: Color(0xFF8BC34A),
                ),
                _ImageSourceButton(
                  icon: Icons.photo_library_rounded,
                  label: "Gallery",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey.shade600),
              ),
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
      List<int> imageBytes = await image.readAsBytes();

      FormData formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          imageBytes,
          filename: 'fabric_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      print('Attempting to upload to: $SERVER_URL');

      final response = await _dio.post(
        SERVER_URL,
        data: formData,
        onSendProgress: (sent, total) {
          print('Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%');
        },
      );

      print('Response received: ${response.statusCode}');
      print('Response data: ${response.data}');

      if ([200, 201].contains(response.statusCode)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraOptionsScreen(
              fabric: response.data['fabric'] ?? 'Unknown',
              imagePath: image.path,
              compositionData: response.data['composition'] ?? {},
              brandData: response.data['brand'] ?? 'Unknown',
              carbonFootprint: response.data['carbonFootprint'] ?? 0,
              message: response.data['message'] ?? '',
            ),
          ),
        );
      } else {
        throw Exception(response.data['message'] ?? 'Invalid server response');
      }
    } on DioException catch (e) {
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

  String _getErrorMessage(DioException e) {
    if (e.response != null) {
      if (e.response!.statusCode == 400) {
        return 'Invalid request: ${e.response!.data['error'] ?? 'Bad request'}';
      } else if (e.response!.statusCode == 413) {
        return 'File too large';
      } else if (e.response!.statusCode == 415) {
        return 'Unsupported media type: ${e.response!.data['error'] ?? 'Please upload a valid image file'}';
      }
      return 'Server error: ${e.response!.statusCode} - ${e.response!.data['error'] ?? 'Unknown error'}';
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your network.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout. Server may be busy.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout. Server response delayed.';
      case DioExceptionType.badResponse:
        return 'Server error: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.unknown:
        return 'Network error: ${e.message}';
      default:
        return 'An error occurred';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Color(0xFF8BC34A),
        elevation: 0,
        title: Text(
          'Eco Scan',
          style: TextStyle(
            color: Color(0xFF030500),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Color(0xFF030500)),
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
                _HeaderSection(),
                const SizedBox(height: 32),
                _ScanSection(
                  isLoading: isLoading,
                  errorMessage: errorMessage,
                  onTap: () => _showImageSourceDialog(context),
                ),
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

class _ImageSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ImageSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/fashion_scan.png', // Main image
          height: 180,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            'assets/ceintre_image.png', // Replace with your fallback image
            height: 200,
            width: 200,
          ),
        ),

        Text(
          "You're rocking the outfit today!",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Let's make it even more eco-friendly",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _ScanSection extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onTap;

  const _ScanSection({
    required this.isLoading,
    required this.errorMessage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: isLoading ? null : onTap,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF8BC34A),
              ),
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_rounded,
                  size: 48,
                  color: Color(0xFF1B5E20),
                ),
                const SizedBox(height: 12),
                Text(
                  "Scan Your Clothes",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded, color: Colors.red.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red.shade600),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8BC34A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Text(
              "Start Scan",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "How it works:",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Color(0xFF253715),
          ),
        ),
        const SizedBox(height: 16),
        _StepItem(
          number: 1,
          title: "Take a photo",
          description: "Capture your clothing item or choose from gallery",
        ),
        _StepItem(
          number: 2,
          title: "AI fabric detection",
          description: "Our system analyzes the material composition",
        ),
        _StepItem(
          number: 3,
          title: "Carbon footprint",
          description: "Get an estimate of environmental impact",
        ),
        _StepItem(
          number: 4,
          title: "Eco alternatives",
          description: "Discover sustainable fashion options",
        ),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  final int number;
  final String title;
  final String description;

  const _StepItem({
    required this.number,
    required this.title,
    required this.description,
  });

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
            decoration: BoxDecoration(
              color: Color(0xFF8BC34A),
              shape: BoxShape.circle,
            ),
            child: Text(
              number.toString(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
//changed