import 'package:flutter/material.dart';

class SuccessConfirmationScreen extends StatelessWidget {
  const SuccessConfirmationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.popUntil(context, (route) => route.isFirst); // Retour Home automatiquement
    });

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // vert clair
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            const Text(
              'Produit ajouté avec succès !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: Colors.green,
            ),
            const SizedBox(height: 10),
            const Text(
              'Retour...',
              style: TextStyle(color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
