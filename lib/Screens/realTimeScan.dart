import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<String> scannedItems = [];
  Set<int> selectedItems = {};
  bool _showCaptureFeedback = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModelAndLabels();
  }

  Future<void> _loadScannedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedItems = prefs.getStringList('scanned_items') ?? [];
    setState(() {
      scannedItems = savedItems.map((e) => e.split('|').first).toList();
    });
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
      if (!scannedItems.contains(label)) {
        scannedItems.add(label);
        _saveItemToStorage(label);
        setState(() => _showCaptureFeedback = true);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() => _showCaptureFeedback = false);
          }
        });
        debugPrint('📦 Prediction: $label | Confidence: ${(confidence * 100).toStringAsFixed(2)}%');
      } else {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Object "$label" already scanned!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          );
          await Future.delayed(const Duration(milliseconds: 1000));
          if (context.mounted) Navigator.of(context).pop();
        }
      }
    } catch (e) {
      debugPrint('Image capture error: $e');
    }
  }

  void _saveItemToStorage(String item) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedItems = prefs.getStringList('scanned_items') ?? [];
 
    final entry = '$item|General';
    final alreadyExists = savedItems.any((e) => e.startsWith('$item|'));
 

  }

  void _saveMultipleItemsToStorage(List<String> items) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedItems = prefs.getStringList('scanned_items') ?? [];

    for (final item in items) {
      final entry = '$item|General';
      final alreadyExists = savedItems.any((e) => e.startsWith('$item|'));
      if (!alreadyExists) {
        savedItems.add(entry);
        debugPrint('✅ Saved to storage: $entry');
      } else {
        debugPrint('ℹ️ Already in storage: $item');
      }
    }

    await prefs.setStringList('scanned_items', savedItems);
  }

  void _clearStoredItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('scanned_items');
    setState(() {
      scannedItems.clear();
      selectedItems.clear();
    });
    debugPrint('✅ Storage cleared');
  }

  void _toggleSelection(int index) {
    setState(() {
      if (selectedItems.contains(index)) {
        selectedItems.remove(index);
      } else {
        selectedItems.add(index);
      }
    });
  }

  void _deleteSelectedItems() async {
    scannedItems = scannedItems.asMap().entries.where((entry) => !selectedItems.contains(entry.key)).map((entry) => entry.value).toList();
    setState(() {
      selectedItems.clear();
    });
  }

  void _showScannedItemsDialog() {
    selectedItems.clear();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: true,
          initialChildSize: 0.95,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Scanned Items', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              if (selectedItems.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _deleteSelectedItems();
                                    setModalState(() {}); // Refresh modal state after delete
                                  },
                                ),
                              if (selectedItems.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.add_box, color: Colors.green),
                                  onPressed: () {
                                    final selectedLabels = selectedItems.map((i) => scannedItems[i]).toList();
                                    _saveMultipleItemsToStorage(selectedLabels);
                                    setState(() {
                                      scannedItems = scannedItems.asMap().entries
                                          .where((entry) => !selectedItems.contains(entry.key))
                                          .map((entry) => entry.value)
                                          .toList();
                                      selectedItems.clear();
                                    });
                                    setModalState(() {});
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: scannedItems.isEmpty
                            ? const Center(child: Text('No items scanned yet.'))
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: scannedItems.length,
                                itemBuilder: (context, index) {
                                  final selected = selectedItems.contains(index);
                                  return Column(
                                    children: [
                                      Container(
                                        color: selected ? Colors.green.withOpacity(0.3) : null,
                                        child: ListTile(
                                          title: Row(
                                            children: [
                                              Checkbox(
                                                value: selected,
                                                onChanged: (bool? checked) {
                                                  setState(() {
                                                    _toggleSelection(index);
                                                  });
                                                  setModalState(() {}); // Update modal sheet
                                                },
                                              ),
                                              Expanded(child: Text(scannedItems[index])),
                                              IconButton(
                                                icon: const Icon(Icons.add_circle, color: Colors.green),
                                                onPressed: () {
                                                  _saveItemToStorage(scannedItems[index]);
                                                  setState(() {
                                                    scannedItems.removeAt(index);
                                                    selectedItems.remove(index);
                                                  });
                                                  setModalState(() {});
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showSettingsDialog() {
    bool isFlashOn = _controller?.value.flashMode == FlashMode.torch;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Settings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.flash_on, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Flashlight'),
                        ],
                      ),
                      Switch(
                        value: isFlashOn,
                        onChanged: (value) async {
                          if (_controller != null) {
                            final newMode = value ? FlashMode.torch : FlashMode.off;
                            await _controller!.setFlashMode(newMode);
                                  setState(() => isFlashOn = value); // update main state
                            setModalState(() {}); // update bottom sheet
                          }
                        },
                      ),
                    ],
                  ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete_forever),
            label: const Text("Clear All Scanned Items"),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text("Are you sure?"),
                  content: const Text("This will permanently delete all scanned items."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context).pop(); // Close settings sheet
                        _clearStoredItems(); // Clear items
                      },
                      child: const Text("Confirm"),
                    ),
                  ],
                ),
              );
            },
          ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    interpreter.close();
    scannedItems.clear();
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
                  Positioned(
                    top: 100,
                    left: 0,
                    right: 0,
                    child: Visibility(
                      visible: _showCaptureFeedback,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '✅ Item captured',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100, // Increased height for better spacing
                      padding: const EdgeInsets.symmetric(vertical: 10), // Added padding
                      decoration: BoxDecoration(
                        color: Colors.green.shade800,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.settings, color: Colors.white),
                            onPressed: _showSettingsDialog,
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
                            onPressed: _showScannedItemsDialog,
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