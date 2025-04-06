import 'package:flutter/material.dart';

class CarbonFootprintScreen extends StatelessWidget {
  final double carbonFootprint;
  final String fabric;
  final String fileName;

  const CarbonFootprintScreen({
    super.key,
    required this.carbonFootprint,
    required this.fabric,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade300,
        title: const Text('Carbon Footprint'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hanger icon with error handling
            Image.asset(
              'assets/Hanger_icon.png',
              height: 80,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, size: 50, color: Colors.red);
              },
            ),
            const SizedBox(height: 20),

            // Clothing icon with fabric type
            Column(
              children: [
                const Icon(Icons.checkroom, size: 80, color: Colors.green),
                Text(
                  fabric.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Information text
            const Text(
              "Your estimated carbon footprint:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "For $fileName",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 10),

            // Carbon footprint display
            CircleAvatar(
              radius: 80,
              backgroundColor: _getFootprintColor(carbonFootprint),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$carbonFootprint kg",
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    "CO₂",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Environmental impact indicator
            _buildImpactIndicator(carbonFootprint),
            const SizedBox(height: 20),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade100,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Try Another Outfit"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () => _saveResult(context),
                  child: const Text(
                    "Save Result",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Color _getFootprintColor(double footprint) {
    if (footprint < 10) return Colors.green;
    if (footprint < 25) return Colors.orange;
    return Colors.red;
  }

  Widget _buildImpactIndicator(double footprint) {
    String impactText;
    Color impactColor;

    if (footprint < 10) {
      impactText = "Low Impact";
      impactColor = Colors.green;
    } else if (footprint < 25) {
      impactText = "Medium Impact";
      impactColor = Colors.orange;
    } else {
      impactText = "High Impact";
      impactColor = Colors.red;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.eco, color: impactColor),
        const SizedBox(width: 8),
        Text(
          impactText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: impactColor,
          ),
        ),
      ],
    );
  }

  void _saveResult(BuildContext context) {
    // TODO: Implement save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Result saved successfully!"),
        backgroundColor: Colors.green,
      ),
    );
  }
}