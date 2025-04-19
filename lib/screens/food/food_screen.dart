import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/product.dart';
import '../../services/product_service.dart';
import 'scanned_products_screen.dart';

class FoodScreen extends StatefulWidget {
  @override
  _FoodScreenState createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  String result = '';
  Product? product;
  List<Product> searchResults = [];
  bool isSearching = false;
  bool sortAscending = true;

  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FDF9),
      appBar: AppBar(
        backgroundColor: Colors.green.shade100,
        elevation: 0,
        title: const Text(
          'EcoTrack - Scan',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black87),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.brown),
            tooltip: 'Historique',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ScannedProductsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Icon(Icons.shopping_basket, size: 90, color: Colors.green),
            const SizedBox(height: 10),

            const Text(
              "Analyse ton produit alimentaire !",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                "Scanne ou recherche un produit pour découvrir son impact écologique.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            // Barre de recherche
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Recherche d’un produit",
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onSubmitted: (value) async {
                  final term = value.trim();
                  if (term.isEmpty) return;
                  setState(() => isSearching = true);
                  List<Product> results =
                      await _productService.searchProductsInTunisia(term);
                  setState(() {
                    searchResults = results;
                    isSearching = false;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // Bouton scanner stylisé
            ElevatedButton.icon(
              onPressed: _startScan,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("Commencer le scan"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),

            const SizedBox(height: 16),
            if (result.isNotEmpty)
              Text('Code-barres détecté : $result',
                  style: const TextStyle(fontSize: 14)),

            const SizedBox(height: 20),

            if (searchResults.isNotEmpty)
              _buildSearchResultsList()
            else if (product != null)
              _buildProductDetails(product!),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsList() {
    if (isSearching) return const CircularProgressIndicator();
    if (searchResults.isEmpty) return const Text("Aucun produit trouvé.");

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final p = searchResults[index];
        Color impactColor = p.carbonImpact < 1
            ? Colors.green
            : p.carbonImpact < 3
                ? Colors.orange
                : Colors.red;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: p.imageUrl != null
                      ? Image.network(p.imageUrl!,
                          width: 60, height: 60, fit: BoxFit.cover)
                      : Image.asset('assets/placeholder.png',
                          width: 60, height: 60),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.productName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(p.brands ?? "Marque inconnue",
                          style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.eco, color: impactColor, size: 16),
                          const SizedBox(width: 6),
                          Text(
                              "${p.carbonImpact.toStringAsFixed(2)} kg CO₂",
                              style: TextStyle(color: impactColor)),
                        ],
                      )
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.save_alt),
                  onPressed: () async {
                    await sendProductToServer(p);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Produit enregistré avec succès.")));
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductDetails(Product product) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            product.imageUrl != null
                ? Image.network(product.imageUrl!, height: 150)
                : Image.asset('assets/placeholder.png', height: 150),
            const SizedBox(height: 10),
            Text(product.productName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Marque : ${product.brands ?? 'N/A'}'),
            Text('Catégorie : ${product.categories ?? 'N/A'}'),
            Text(
                'Impact Carbone : ${product.carbonImpact.toStringAsFixed(2)} kg CO₂'),
          ],
        ),
      ),
    );
  }

  Future<void> _startScan() async {
    String barcode = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Annuler", true, ScanMode.BARCODE);

    if (barcode != "-1") {
      setState(() => result = barcode);
      final fetchedProduct = await _productService.fetchProduct(barcode);
      setState(() => product = fetchedProduct);

      if (fetchedProduct != null) await sendProductToServer(fetchedProduct);
    }
  }

  Future<void> sendProductToServer(Product product) async {
    final url = Uri.parse("http://localhost:3000/products");
    try {
      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "code": product.code,
          "productName": product.productName,
          "brands": product.brands,
          "categories": product.categories,
          "imageUrl": product.imageUrl,
          "carbonImpact": product.carbonImpact,
          "ingredients": product.ingredients,
          "recyclability": product.recyclability,
          "countries": "Tunisia",
          "source": "scan"
        }),
      );
    } catch (e) {
      print("Erreur d'envoi serveur: $e");
    }
  }
}
