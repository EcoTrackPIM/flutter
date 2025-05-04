import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../Api/authApi.dart';
import 'CarboneFootPrint.dart';

class CameraOptionsScreen extends StatefulWidget {
  final String imagePath;
  final String fabric;
  final Map<String, dynamic> compositionData;
  final String brandData;
  final int carbonFootprint;
  final String message;

  const CameraOptionsScreen({
    Key? key,
    required this.imagePath,
    required this.fabric,
    required this.compositionData,
    required this.brandData,
    required this.carbonFootprint,
    required this.message,
  }) : super(key: key);

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
  final ApiService _apiService = ApiService();
  final Dio _dio = Dio();
  int _updatedCarbonFootprint = 0;

  @override
  void initState() {
    super.initState();
    _configureDio();
    _updatedCarbonFootprint = widget.carbonFootprint;
  }

  void _configureDio() {
    _dio.options.baseUrl = 'http://192.168.1.128:3000';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Authorization': 'Bearer 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',
      'Accept': 'application/json',
    };
  }

  int _calculateAdjustedFootprint(int baseFootprint, String outfitType) {
    final outfitMultipliers = {
      'T-Shirt': 1.0,
      'Shirt': 1.2,
      'Pullover': 1.5,
      'Dress': 1.8,
      'Skirt': 1.3,
      'Jacket': 2.0,
      'Jeans': 1.7,
      'Sweater': 1.6,
      'Shorts': 0.9,
    };

    final multiplier = outfitMultipliers[outfitType] ?? 1.0;
    return (baseFootprint * multiplier).round();
  }

  void _onOutfitSelected(String outfitName) {
    setState(() {
      _selectedOutfit = outfitName;
      _updatedCarbonFootprint = _calculateAdjustedFootprint(
          widget.carbonFootprint,
          outfitName
      );
    });
  }

  Future<void> _saveLook() async {
    if (_selectedOutfit == null) return;

    setState(() => _isUploading = true);

    try {
      final response = await _apiService.saveScan(
        imageFile: File(widget.imagePath),
        outfitType: _selectedOutfit!,
        carbonFootprint: _updatedCarbonFootprint.toDouble(),
        fabric: widget.fabric,
      );

      print('Scan Response: $response'); // Add this for debugging

      if (mounted) {
        Navigator.pushReplacement( // Changed to pushReplacement
          context,
          MaterialPageRoute(
            builder: (context) => CarbonFootprintScreen(
              carbonFootprint: _updatedCarbonFootprint.toDouble(),
              fabric: widget.fabric,
              fileName: widget.imagePath,
              outfitType: _selectedOutfit!,
              scanId: response['id']?.toString() ?? response['_id']?.toString(),
            ),
          ),
        );
      }
    } catch (e) {
      print('Save Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
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
        title: const Text(
          "Complete Your Look",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF4D8B6F),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(widget.imagePath),
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "FABRIC TYPE",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.fabric.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4D8B6F),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "BASE FOOTPRINT",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${widget.carbonFootprint} kg CO₂",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4D8B6F),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (_selectedOutfit != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "SELECTED OUTFIT",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedOutfit!.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4D8B6F),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "ADJUSTED FOOTPRINT",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$_updatedCarbonFootprint kg CO₂",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4D8B6F),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              ),
              child: const Text(
                "SELECT OUTFIT TYPE",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Color(0xFF4D8B6F),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: outfits.length,
              itemBuilder: (context, index) {
                final outfit = outfits[index];
                final isSelected = _selectedOutfit == outfit["name"];
                final calculatedFootprint = _calculateAdjustedFootprint(
                  widget.carbonFootprint,
                  outfit["name"]!,
                );

                return GestureDetector(
                  onTap: () => _onOutfitSelected(outfit["name"]!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4D8B6F).withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4D8B6F)
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
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
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? const Color(0xFF4D8B6F).withOpacity(0.2)
                                : Colors.grey[100],
                          ),
                          child: Center(
                            child: Image.asset(
                              outfit["image"]!,
                              width: 36,
                              height: 36,
                              color: isSelected
                                  ? const Color(0xFF4D8B6F)
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          outfit["name"]!,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFF4D8B6F)
                                : Colors.grey[800],
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 4),
                          Text(
                            "$calculatedFootprint kg CO₂",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4D8B6F),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _saveLook,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: const Color(0xFF4D8B6F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  shadowColor: const Color(0xFF4D8B6F).withOpacity(0.3),
                ),
                child: _isUploading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
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