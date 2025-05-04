import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'carbon_footprint_screen.dart';
import '../Api/tagscanner.dart';

class OutfitSelectionScreen extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> composition;

  const OutfitSelectionScreen({
    super.key,
    required this.imagePath,
    required this.composition,
  });

  @override
  _OutfitSelectionScreenState createState() => _OutfitSelectionScreenState();
}

class _OutfitSelectionScreenState extends State<OutfitSelectionScreen> {
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
  bool _isCalculating = false;
  int? _hoveredIndex;

  Future<void> _calculateCarbon() async {
    if (_selectedOutfit == null) {
      _showErrorSnackbar("Please select an outfit first");
      return;
    }

    setState(() => _isCalculating = true);

    try {
      final footprint = await TagApi.calculateCarbonFootprint(
        widget.composition, // This should contain {"Cotton": 50, "Polyester": 50}
        _selectedOutfit!,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CarbonFootprintScreen(
            carbonFootprint: footprint,
            fileName: widget.imagePath.split('/').last,
            outfitType: _selectedOutfit!,
            composition: widget.composition, itemName: '', // Pass the composition through
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog("Failed to calculate: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isCalculating = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Calculation Error"),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  String _getMainMaterial(Map<String, dynamic> composition) {
    if (composition.isEmpty) return "Mixed Materials";

    final converted = composition.map<String, double>(
          (key, value) => MapEntry(
        key,
        value is double ? value : double.tryParse(value.toString()) ?? 0.0,
      ),
    );

    final mainMaterial = converted.entries.reduce(
          (a, b) => a.value > b.value ? a : b,
    );
    return "${mainMaterial.key} (${mainMaterial.value.toStringAsFixed(1)}%)";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Outfit Type"),
        centerTitle: true,
        backgroundColor: const Color(0xFF4D8B6F),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Image and Composition Card
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
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Material Composition",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4D8B6F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.composition.isEmpty)
                      const Text("No composition data available"),
                    if (widget.composition.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.composition.entries.map((entry) => Chip(
                          label: Text("${entry.key} ${entry.value}%"),
                          backgroundColor: const Color(0xFF4D8B6F).withOpacity(0.1),
                        )).toList(),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Outfit Selection Grid
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
                final isHovered = _hoveredIndex == index;

                return GestureDetector(
                  onTap: () => setState(() => _selectedOutfit = outfit["name"]),
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _hoveredIndex = index),
                    onExit: (_) => setState(() => _hoveredIndex = null),
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
                        boxShadow: isHovered && !isSelected
                            ? [BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )]
                            : null,
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
                onPressed: _isCalculating ? null : _calculateCarbon,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF4D8B6F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isCalculating
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
                    : const Text(
                  "CALCULATE CARBON FOOTPRINT",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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