import 'package:flutter/material.dart';
import '../../model/product.dart';
import '../product_service.dart';

class FoodHistoryScreen extends StatefulWidget {
  @override
  _FoodHistoryScreenState createState() => _FoodHistoryScreenState();
}

class _FoodHistoryScreenState extends State<FoodHistoryScreen> {
  final ProductService _productService = ProductService();
  List<Product> scannedProducts = [];

  @override
  void initState() {
    super.initState();
    loadScannedProducts();
  }

  Future<void> loadScannedProducts() async {
    final products = await _productService.fetchSavedProducts();
    
    // Tri par impact carbone croissant
    products.sort((a, b) => a.carbonImpact.compareTo(b.carbonImpact));

    setState(() => scannedProducts = products);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique des scans"),
        backgroundColor: Colors.green.shade100,
      ),
      body: scannedProducts.isEmpty
          ? const Center(child: Text("Aucun produit scanné"))
          : ListView.builder(
              itemCount: scannedProducts.length,
              itemBuilder: (context, index) {
                final product = scannedProducts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: product.imageUrl != null
                        ? Image.network(
                            product.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.fastfood, size: 40),
                    title: Text(
                      product.productName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.eco, color: Colors.green, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              "Empreinte carbone : ${product.carbonImpact.toStringAsFixed(2)} kg CO₂",
                              style: TextStyle(
                                color: product.carbonImpact < 1.0
                                    ? Colors.green
                                    : product.carbonImpact < 3.0
                                        ? Colors.orange
                                        : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: CircleAvatar(
                      backgroundColor: product.carbonImpact < 1.0
                          ? Colors.green
                          : product.carbonImpact < 3.0
                              ? Colors.orange
                              : Colors.red,
                      child: Text(
                        product.carbonImpact.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}