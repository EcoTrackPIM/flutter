import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';

class ScannedProductsScreen extends StatefulWidget {
  @override
  _ScannedProductsScreenState createState() => _ScannedProductsScreenState();
}

class _ScannedProductsScreenState extends State<ScannedProductsScreen> {
  final ProductService _productService = ProductService();
  List<Product> scannedProducts = [];

  @override
  void initState() {
    super.initState();
    fetchScanned();
  }

  void fetchScanned() async {
    final products = await _productService.fetchScannedProducts();
    setState(() {
      scannedProducts = products;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits Scannés'),
        backgroundColor: Colors.green,
      ),
      body: scannedProducts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: scannedProducts.length,
              itemBuilder: (context, index) {
                final product = scannedProducts[index];
                return ListTile(
                  leading: product.imageUrl != null
                      ? Image.network(product.imageUrl!, width: 50)
                      : const Icon(Icons.fastfood),
                  title: Text(product.productName),
                  subtitle: Text('CO₂: ${product.carbonImpact.toStringAsFixed(2)} kg'),
                );
              },
            ),
    );
  }
}
