import 'package:flutter/material.dart';

class CarbonFootprintScreen extends StatelessWidget {
  final double carbonFootprint;
  final String fabric;
  final String fileName;
  final String outfitType;

  const CarbonFootprintScreen({
    super.key,
    required this.carbonFootprint,
    required this.fabric,
    required this.fileName,
    required this.outfitType,
  });

  @override
  Widget build(BuildContext context) {
    final adjustedFootprint = _calculateAdjustedFootprint(carbonFootprint, outfitType);
    final impactLevel = _getImpactLevel(adjustedFootprint);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Sustainability Report', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header Card
            Card(
              elevation: 0,
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
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.eco, color: Colors.green[700], size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Fabric Analysis",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                fabric.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
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
                        _buildInfoItem("Outfit", outfitType, Icons.checkroom),
                        _buildInfoItem("File", fileName.split('/').last, Icons.insert_drive_file),
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
                const Text(
                  "CARBON FOOTPRINT",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
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

                // Animated Circle with footprint
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: impactLevel.color.withOpacity(0.2),
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

                const SizedBox(height: 24),

                // Impact Level Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: impactLevel.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: impactLevel.color.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.eco, color: impactLevel.color),
                      const SizedBox(width: 8),
                      Text(
                        impactLevel.text,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: impactLevel.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Sustainability Tips
            _buildSustainabilityTips(impactLevel),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.green[700]!),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "ANOTHER OUTFIT..",
                      style: TextStyle(color: Colors.green[700]),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => _saveResult(context),
                    child: const Text(
                      "SAVE REPORT",
                      style: TextStyle(color: Colors.white),
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
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
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
        const Text(
          "SUSTAINABILITY TIPS",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        ...tips.map((tip) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline, size: 20, color: impact.color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tip,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  double _calculateAdjustedFootprint(double baseFootprint, String outfitType) {
    // Adjust footprint based on outfit type
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
    return baseFootprint * multiplier;
  }

  ImpactLevel _getImpactLevel(double footprint) {
    if (footprint < 15) return ImpactLevel.low;
    if (footprint < 30) return ImpactLevel.medium;
    return ImpactLevel.high;
  }

  void _saveResult(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Report saved successfully!"),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
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