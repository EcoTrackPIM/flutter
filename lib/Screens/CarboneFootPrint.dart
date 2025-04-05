import 'package:flutter/material.dart';

class CarbonFootprintScreen extends StatelessWidget {
  final double carbonFootprint;

  const CarbonFootprintScreen({super.key, required this.carbonFootprint});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade300,
        title: const Text('Carbone Footprint'),
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
            // ✅ Ajout du logo Hanger avec gestion d'erreur
            Image.asset(
              'assets/Hanger_icon.png', // Vérifie bien ce chemin
              height: 80,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, size: 50, color: Colors.red);
              },
            ),
            const SizedBox(height: 20),

            const Icon(Icons.checkroom, size: 80, color: Colors.green),
            const SizedBox(height: 20),

            const Text(
              "Here’s your estimated carbon footprint!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 80,
              backgroundColor: Colors.green,
              child: Text(
                "$carbonFootprint kg",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade100,
                  ),
                  onPressed: () {},
                  child: const Text("Try another outfit"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                  ),
                  onPressed: () {},
                  child: const Text("Save Result", style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
