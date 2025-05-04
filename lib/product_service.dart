import 'dart:convert';
import 'package:flutter_eco_track/models/product.dart';
import 'package:http/http.dart' as http;

class ProductService {
  static const String backendUrl = 'http://192.168.1.21:3000/products'; // ✅ Vérifie bien que c’est l’IP de ton PC

  /// ✅ Nouvelle méthode pour scanner un produit via le backend NestJS (qui appelle OpenFoodFacts)
  Future<Product?> scanProduct(String barcode) async {
    final url = Uri.parse('$backendUrl/scan'); // ✅ Appel à /products/scan côté backend
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"code": barcode}), // ✅ Envoi du code-barres
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['product'] != null) {
          return Product.fromJson(data['product']); // ✅ Conversion JSON → modèle Flutter
        } else {
          print("⚠️ Produit non trouvé dans la réponse");
          return null;
        }
      } else {
        print("❌ Erreur HTTP (${response.statusCode}): ${response.body}");
        return null;
      }
    } catch (e) {
      print("🚨 Erreur réseau scanProduct : $e");
      return null;
    }
  }

  /// 🔍 Recherche des produits par mot-clé, filtrés sur la Tunisie
  Future<List<Product>> searchProductsInTunisia(String term) async {
    final url = Uri.parse('$backendUrl/search/$term');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Erreur de recherche');
      }
    } catch (e) {
      print("Erreur recherche : $e");
      return [];
    }
  }

  /// 📦 Récupère tous les produits (sans filtre)
  Future<List<Product>> fetchAllProducts() async {
    final url = Uri.parse(backendUrl);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((product) => Product.fromJson(product)).toList();
      } else {
        throw Exception("Erreur lors du chargement des produits");
      }
    } catch (e) {
      print("Erreur API fetchAllProducts: $e");
      return [];
    }
  }

  /// 📜 Historique des produits scannés
  Future<List<Product>> fetchSavedProducts() async {
    final url = Uri.parse('$backendUrl/scanned');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception("Erreur lors de la récupération de l’historique");
      }
    } catch (e) {
      print("Erreur API : $e");
      return [];
    }
  }
Future<Product?> fetchProduct(String barcode) async {
  final url = Uri.parse('$backendUrl/$barcode');
  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Product.fromJson(data);
    } else {
      print("❌ Produit non trouvé (status ${response.statusCode})");
      return null;
    }
  } catch (e) {
    print("🚨 Erreur fetchProduct : $e");
    return null;
  }
}

  /// 🔁 Alias pour historique
  Future<List<Product>> fetchScannedProducts() async {
    return fetchSavedProducts(); // ✅ Rien à changer ici
  }
}