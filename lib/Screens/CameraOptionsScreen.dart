import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'CarboneFootPrint.dart';

class CameraOptionsScreen extends StatefulWidget {
  final String fabric;
  final String imagePath;
  final Map<String, dynamic> compositionData;
  final String brandData;
  final int carbonFootprint;
  final String message;

  const CameraOptionsScreen({
    super.key,
    required this.fabric,
    required this.imagePath,
    required this.compositionData,
    required this.brandData,
    required this.carbonFootprint,
    required this.message,
  });

  @override
  _CameraOptionsScreenState createState() => _CameraOptionsScreenState();
}

class _CameraOptionsScreenState extends State<CameraOptionsScreen> {
  final List<Map<String, String>> outfits = [
    {"name": "T-Shirt", "image": "assets/Tshirt.png"},
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
  final bool _isHovered = false;
  int? _hoveredIndex;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _configureDio();
  }

  void _configureDio() {
    _dio.options.baseUrl = 'http://192.168.1.15:3000';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Authorization': 'Bearer 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',
    };
  }

  Future<void> _saveLook() async {
    if (_selectedOutfit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an outfit first"),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CarbonFootprintScreen(
            carbonFootprint: widget.carbonFootprint.toDouble(),
            fabric: widget.fabric,
            fileName: widget.imagePath.split('/').last,
            outfitType: _selectedOutfit!,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Your Look",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fabric Info Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(widget.imagePath),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 40),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Detected Fabric",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            widget.fabric,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Base Footprint: ${widget.carbonFootprint} g CO₂",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Outfit Selection
            const Text(
              "SELECT OUTFIT TYPE",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 16),

            // Outfit Grid with Hover Effects
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: outfits.length,
              itemBuilder: (context, index) {
                final outfit = outfits[index];
                final isSelected = _selectedOutfit == outfit["name"];
                final isHovered = _hoveredIndex == index;

                return MouseRegion(
                  onEnter: (_) => setState(() => _hoveredIndex = index),
                  onExit: (_) => setState(() => _hoveredIndex = null),
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedOutfit = outfit["name"]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.green[50]
                            : isHovered
                            ? Colors.grey[50]
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.green
                              : isHovered
                              ? Colors.grey[400]!
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          if (isHovered || isSelected)
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? Colors.green[100]
                                  : isHovered
                                  ? Colors.grey[200]
                                  : Colors.grey[100],
                            ),
                            child: Center(
                              child: Image.asset(
                                outfit["image"]!,
                                width: 40,
                                height: 40,
                                color: isSelected
                                    ? Colors.green[800]
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            outfit["name"]!,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.green[800]
                                  : Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Calculate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveLook,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Color(0xFF8BC34A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isUploading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF8BC34A),
                  ),
                )
                    : const Text(
                  "CALCULATE CARBON FOOTPRINT",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
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