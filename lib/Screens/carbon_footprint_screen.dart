import 'package:flutter/material.dart';

class CarbonFootprintScreen extends StatelessWidget {
  final double carbonFootprint;
  final String fileName;
  final String outfitType;
  final Map<String, dynamic> composition;

  const CarbonFootprintScreen({
    super.key,
    required this.carbonFootprint,
    required this.fileName,
    required this.outfitType,
    required this.composition, required String itemName,
  });

  String get _mainMaterial {
    if (composition.isEmpty) return "Mixed Materials";

    // Convert values to numbers if they aren't already
    final convertedComposition = composition.map<String, double>(
          (key, value) => MapEntry(
        key,
        value is double ? value : double.tryParse(value.toString()) ?? 0.0,
      ),
    );

    final mainMaterial = convertedComposition.entries.reduce(
          (a, b) => a.value > b.value ? a : b,
    );
    return "${mainMaterial.key} (${mainMaterial.value}%)";
  }

  @override
  Widget build(BuildContext context) {
    final impactLevel = _getImpactLevel(carbonFootprint);
    final primaryColor = const Color(0xFF4D8B6F);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Sustainability Report'),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fabric Composition Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
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
                                "FABRIC COMPOSITION",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _mainMaterial,
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
                    // Display all composition materials
                    if (composition.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: composition.entries.map((entry) => Chip(
                          label: Text("${entry.key} ${entry.value}%"),
                          backgroundColor: primaryColor.withOpacity(0.1),
                        )).toList(),
                      )
                    else
                      Text(
                        "No composition data available",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
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

                // Footprint Circle
                Container(
                  width: isPortrait ? 200 : 150,
                  height: isPortrait ? 200 : 150,
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
                          "${carbonFootprint.toStringAsFixed(1)} kg",
                          style: TextStyle(
                            fontSize: isPortrait ? 32 : 24,
                            fontWeight: FontWeight.bold,
                            color: impactLevel.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "CO₂ EQUIVALENT",
                          style: TextStyle(
                            fontSize: isPortrait ? 12 : 10,
                            color: impactLevel.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Impact Level
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.eco, color: impactLevel.color, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        impactLevel.text.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: impactLevel.color,
                          fontSize: isPortrait ? 14 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Sustainability Tips
            _buildSustainabilityTips(impactLevel, isPortrait),

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
                      "BACK",
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

  Widget _buildSustainabilityTips(ImpactLevel impact, bool isPortrait) {
    final tips = {
      ImpactLevel.low: [
        "This is an eco-friendly choice!",
        "Consider natural fiber alternatives",
        "Look for certified sustainable brands"
      ],
      ImpactLevel.medium: [
        "Good effort! You're on the right track",
        "Consider washing in cold water",
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
            fontSize: isPortrait ? 16 : 14,
            fontWeight: FontWeight.bold,
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
                width: isPortrait ? 24 : 20,
                height: isPortrait ? 24 : 20,
                decoration: BoxDecoration(
                  color: impact.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  size: isPortrait ? 16 : 14,
                  color: impact.color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tip,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: isPortrait ? 14 : 12,
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

  void _saveResult(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Report saved successfully!"),
        backgroundColor: Color(0xFF4D8B6F),
        behavior: SnackBarBehavior.floating,
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