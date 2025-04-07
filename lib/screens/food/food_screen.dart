// food_screen.dart avec :
// - Tri par impact carbone
// - Bouton "Enregistrer" manuellement
// - Accumulation dans une liste pour rapport

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';

class FoodScreen extends StatefulWidget {
  @override
  _FoodScreenState createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  String result = '';
  Product? product;
  List<Product> searchResults = [];
  List<Product> savedProducts = []; // pour le rapport
  bool isSearching = false;

  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.green.shade100,
        elevation: 0,
        title: const Text('EcoTrack', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.description, color: Colors.black),
            onPressed: () => _showReportDialog(),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 20),
              _buildScanButton(),
              const SizedBox(height: 10),
              Text('Code-barres : $result', style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 20),
              if (searchResults.isNotEmpty || isSearching)
                _buildSearchResultsList()
              else if (product != null)
                _buildProductDetails(product!)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.brown, width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Chercher un produit",
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(color: Colors.brown, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () async {
                String keyword = _searchController.text.trim();
                if (keyword.isNotEmpty) {
                  setState(() {
                    isSearching = true;
                    searchResults.clear();
                  });
                  List<Product> results = await _productService.searchProducts(keyword);
                  results.sort((a, b) => a.carbonImpact.compareTo(b.carbonImpact)); // tri CO2
                  setState(() {
                    searchResults = results;
                    isSearching = false;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
    return ElevatedButton(
      onPressed: () async {
        String? barcode = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SimpleBarcodeScannerPage()),
        );

        if (barcode != null && barcode.isNotEmpty) {
          setState(() => result = barcode);

          Product? fetchedProduct = await _productService.fetchProduct(barcode);
          setState(() => product = fetchedProduct);

          if (fetchedProduct != null) await sendProductToServer(fetchedProduct);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: const Text('Scanner un produit', style: TextStyle(fontSize: 16)),
    );
  }

  Widget _buildSearchResultsList() {
    if (isSearching) return const CircularProgressIndicator();
    if (searchResults.isEmpty) return const Text("Aucun produit avec impact carbone trouvé.");

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final p = searchResults[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: p.imageUrl != null
                ? Image.network(p.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                : Image.asset('assets/placeholder.png', width: 50, height: 50),
            title: Text(p.productName),
            subtitle: Text("CO2: ${p.carbonImpact.toStringAsFixed(2)} kg | ${p.brands ?? ''}"),
            trailing: IconButton(
              icon: const Icon(Icons.save_alt),
              onPressed: () async {
                await sendProductToServer(p);
                setState(() => savedProducts.add(p));
              },
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            product.imageUrl != null
                ? Image.network(product.imageUrl!, height: 150)
                : Image.asset('assets/placeholder.png', height: 150),
            const SizedBox(height: 10),
            Text(product.productName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Marque: ${product.brands ?? 'N/A'}'),
            Text('Catégorie: ${product.categories ?? 'N/A'}'),
            Text('Impact Carbone: ${product.carbonImpact.toStringAsFixed(2)} kg CO₂'),
          ],
        ),
      ),
    );
  }

  Future<void> sendProductToServer(Product product) async {
    final url = Uri.parse("http://<TON_IP>:3000/products"); // remplacer <TON_IP>
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
        }),
      );
    } catch (e) {
      print("Erreur d'envoi serveur: $e");
    }
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rapport des produits enregistrés"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: savedProducts.length,
            itemBuilder: (context, index) {
              final p = savedProducts[index];
              return ListTile(
                title: Text(p.productName),
                subtitle: Text("CO₂ : ${p.carbonImpact.toStringAsFixed(2)} kg"),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Fermer"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }
}