import 'dart:io';
import 'package:flutter/material.dart';
import '../Api/authApi.dart'; // Import the ApiService

class CarbonFootprintScreen extends StatelessWidget {
  final double carbonFootprint;
  final String fabric;
  final String fileName;
  final String outfitType;
  final String? scanId; // Add this


  const CarbonFootprintScreen({
    super.key,
    required this.carbonFootprint,
    required this.fabric,
    required this.fileName,
    required this.outfitType,
    this.scanId, // Add this

  });

  @override
  Widget build(BuildContext context) {
    final adjustedFootprint = carbonFootprint;
    final impactLevel = _getImpactLevel(adjustedFootprint);
    final primaryColor = const Color(0xFF4D8B6F);
    final apiService = ApiService(); // Create an instance of ApiService

    Future<void> _saveResult(BuildContext context) async {
      final apiService = ApiService();

      if (scanId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Scan reference missing!")),
        );
        return;
      }

      try {
        final response = await apiService.updateCarbonFootprint(
          uploadId: scanId!,
          carbonFootprint: carbonFootprint,
        );

        print('Update Response: $response');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Update successful'),
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Sustainability Report',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            )),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Modern Header Card with Fabric Info
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.eco, color: primaryColor, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "FABRIC ANALYSIS",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                fabric.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoItem("Outfit Type", outfitType, Icons.checkroom),
                        _buildInfoItem(
                            "File", fileName.split('/').last, Icons.insert_drive_file),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Carbon Footprint Visualization
            Column(
              children: [
                Text(
                  "CARBON FOOTPRINT",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "For your $outfitType",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                // Footprint Circle with Gradient
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        impactLevel.color.withOpacity(0.1),
                        impactLevel.color.withOpacity(0.3),
                      ],
                    ),
                    border: Border.all(
                      color: impactLevel.color,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${adjustedFootprint.toStringAsFixed(1)} g",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: impactLevel.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "CO₂ EQUIVALENT",
                          style: TextStyle(
                            fontSize: 12,
                            color: impactLevel.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Impact Level Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: impactLevel.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: impactLevel.color.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.eco, color: impactLevel.color),
                  const SizedBox(width: 12),
                  Text(
                    impactLevel.text.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: impactLevel.color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Sustainability Tips Section
            _buildSustainabilityTips(impactLevel),
            const SizedBox(height: 32),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: primaryColor, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "ANOTHER OUTFIT",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () => _saveResult(context),
                    child: const Text(
                      "SAVE REPORT",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSustainabilityTips(ImpactLevel impact) {
    final tips = {
      ImpactLevel.low: [
        "This is an eco-friendly choice!",
        "Consider natural fiber alternatives for even lower impact",
        "Look for certified sustainable brands"
      ],
      ImpactLevel.medium: [
        "Good effort! You're on the right track",
        "Consider washing in cold water to reduce impact",
        "Air dry instead of using a dryer"
      ],
      ImpactLevel.high: [
        "Consider more sustainable alternatives",
        "Look for recycled material options",
        "Extend garment life through proper care"
      ],
    }[impact]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SUSTAINABILITY TIPS",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: const Color(0xFF4D8B6F),
          ),
        ),
        const SizedBox(height: 16),
        ...tips.map((tip) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: impact.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: impact.color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tip,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  ImpactLevel _getImpactLevel(double footprint) {
    if (footprint < 15) return ImpactLevel.low;
    if (footprint < 30) return ImpactLevel.medium;
    return ImpactLevel.high;
  }
}

enum ImpactLevel {
  low(Colors.green, "Low Impact"),
  medium(Colors.orange, "Medium Impact"),
  high(Colors.red, "High Impact");

  final Color color;
  final String text;

  const ImpactLevel(this.color, this.text);
}
