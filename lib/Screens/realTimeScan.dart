import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:convert';

const int kInputSize = 224;
const int kOutputClasses = 1001;

Future<Float32List> preprocessImageIsolate(Map<String, dynamic> args) async {
  final Uint8List imageBytes = args['imageBytes'];
  final int inputSize = args['inputSize'];
  final img.Image? decodedImage = img.decodeImage(imageBytes);
  if (decodedImage == null) throw Exception("Failed to decode image");

  final img.Image resizedImage = img.copyResize(
    decodedImage,
    width: inputSize,
    height: inputSize,
  );

  final Float32List convertedBytes = Float32List(inputSize * inputSize * 3);
  int index = 0;
  for (int y = 0; y < resizedImage.height; y++) {
    for (int x = 0; x < resizedImage.width; x++) {
      final pixel = resizedImage.getPixel(x, y);
      convertedBytes[index++] = img.getRed(pixel) / 255.0;
      convertedBytes[index++] = img.getGreen(pixel) / 255.0;
      convertedBytes[index++] = img.getBlue(pixel) / 255.0;
    }
  }
  return convertedBytes;
}

class RealTimeScanScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const RealTimeScanScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _RealTimeScanScreenState createState() => _RealTimeScanScreenState();
}

class _RealTimeScanScreenState extends State<RealTimeScanScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  late Interpreter interpreter;
  List<String>? labels;
  double _currentZoomLevel = 1.0;
  double _baseZoomLevel = 1.0;
  bool _showCaptureFeedback = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModelAndLabels();
  }

  Future<void> _initializeCamera() async {
    if (widget.cameras.isNotEmpty) {
      _controller = CameraController(
        widget.cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();
      await _controller!.setFlashMode(FlashMode.off);
      _isCameraInitialized = true;
      setState(() {});
    }
  }

  Future<void> _loadModelAndLabels() async {
    try {
      final modelData = await rootBundle.load('assets/yolov5.tflite');
      interpreter = Interpreter.fromBuffer(modelData.buffer.asUint8List());
      debugPrint('✅ Interpreter initialized');
    } catch (e) {
      debugPrint('❌ Model load error: $e');
    }

    try {
      final labelData = await rootBundle.loadString('assets/labels.txt');
      labels = labelData.split('\n').where((e) => e.trim().isNotEmpty).toList();
      debugPrint('✅ Labels loaded (${labels!.length})');
    } catch (e) {
      debugPrint('❌ Label load error: $e');
    }
  }

  Future<Map<String, dynamic>> runInference(Uint8List imageBytes) async {
    final Float32List processed = await compute(preprocessImageIsolate, {
      'imageBytes': imageBytes,
      'inputSize': kInputSize,
    });

    final inputTensor = [
      List.generate(
        kInputSize,
        (i) => List.generate(
          kInputSize,
          (j) => List.generate(
            3,
            (k) => processed[i * kInputSize * 3 + j * 3 + k],
          ),
        ),
      )
    ];

    final output = List.generate(1, (_) => List.filled(kOutputClasses, 0.0));
    interpreter.run(inputTensor, output);

    double maxConfidence = 0;
    int predictedIndex = 0;
    for (int i = 0; i < kOutputClasses; i++) {
      if (output[0][i] > maxConfidence) {
        maxConfidence = output[0][i];
        predictedIndex = i;
      }
    }

    return {
      'predictedIndex': predictedIndex,
      'confidence': maxConfidence,
    };
  }

  Future<void> _captureImage() async {
    if (!_controller!.value.isInitialized) return;
    try {
      final image = await _controller!.takePicture();
      final imageBytes = await image.readAsBytes();
      final result = await runInference(imageBytes);

      final index = result['predictedIndex'] as int;
      final confidence = result['confidence'] as double;
      final adjustedIndex = index - 1;

      final label = (labels != null &&
              adjustedIndex >= 0 &&
              adjustedIndex < labels!.length)
          ? labels![adjustedIndex]
          : 'Unknown';

      // Send directly to backend
      await _saveItemToServer(label);

      setState(() => _showCaptureFeedback = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _showCaptureFeedback = false);
        }
      });
      debugPrint('📦 Prediction: $label | Confidence: ${(confidence * 100).toStringAsFixed(2)}%');
    } catch (e) {
      debugPrint('Image capture error: $e');
    }
  }

  Future<void> _saveItemToServer(String itemName) async {
    final url = Uri.parse('http://192.168.2.1:3000/items');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': itemName}),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('✅ Sent to server: $itemName');
      } else {
        debugPrint('❌ Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Failed to send item: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.green.shade800,
        title: const Text('EcoTrack'),
      ),
      body: _isCameraInitialized
          ? GestureDetector(
              onScaleStart: (details) {
                _baseZoomLevel = _currentZoomLevel;
              },
              onScaleUpdate: (details) {
                final newZoom = (_baseZoomLevel * details.scale).clamp(1.0, 5.0);
                _controller!.setZoomLevel(newZoom);
                setState(() => _currentZoomLevel = newZoom);
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CameraPreview(_controller!),
                  ),
                  if (_showCaptureFeedback)
                    Positioned(
                      top: 100,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '✅ Item captured and sent!',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade800,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.settings, color: Colors.white),
                            onPressed: () {},
                          ),
                          Transform.translate(
                            offset: const Offset(0, -35),
                            child: Material(
                              elevation: 8,
                              shape: const CircleBorder(),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: _captureImage,
                                child: Ink(
                                  width: 72,
                                  height: 72,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: const Icon(Icons.camera_alt, color: Colors.green, size: 32),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.list_alt, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}