import 'dart:convert';
import 'package:flutter_eco_track/models/product.dart';
import 'package:http/http.dart' as http;

class ProductService {
  static const String backendUrl = 'http://192.168.1.128:3000/products'; // ✅ IP backend correcte

  /// ✅ Scanner un produit via backend NestJS
  Future<Product?> scanProduct(String barcode) async {
    final url = Uri.parse('$backendUrl/scan');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"code": barcode}),
      );

      print("📬 Réponse scanProduct HTTP ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['product'] != null) {
          return Product.fromJson(data['product']);
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

  /// 🔍 Recherche de produits par mot-clé (Tunisie)
  Future<List<Product>> searchProductsInTunisia(String term) async {
    final url = Uri.parse('$backendUrl/search/$term');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Erreur recherche ${response.statusCode}');
      }
    } catch (e) {
      print("🚨 Erreur recherche : $e");
      return [];
    }
  }

  /// 📦 Récupérer tous les produits
  Future<List<Product>> fetchAllProducts() async {
    final url = Uri.parse(backendUrl);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((product) => Product.fromJson(product)).toList();
      } else {
        throw Exception("Erreur chargement ${response.statusCode}");
      }
    } catch (e) {
      print("🚨 Erreur fetchAllProducts: $e");
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
        throw Exception("Erreur historique ${response.statusCode}");
      }
    } catch (e) {
      print("🚨 Erreur fetchSavedProducts: $e");
      return [];
    }
  }

  /// 🔁 Alias pour historique
  Future<List<Product>> fetchScannedProducts() async {
    return fetchSavedProducts();
  }

  /// 🔍 Récupérer un seul produit par code-barres
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

  /// ➕ Créer un produit minimal si introuvable
  Future<void> createNewProduct(String code, String category) async {
    final url = Uri.parse(backendUrl);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'code': code,
          'productName': 'Produit inconnu',
          'brands': 'Non spécifié',
          'categories': category,
          'imageUrl': '',
          'carbonImpact': 0,
          'ingredients': '',
          'recyclability': '',
          'countries': 'Tunisia',
          'source': 'ajout-manuelle'
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Produit ajouté avec succès.');
      } else {
        print('❌ Erreur HTTP createNewProduct (${response.statusCode}): ${response.body}');
        throw Exception('Erreur serveur création');
      }
    } catch (e) {
      print("🚨 Erreur réseau createNewProduct : $e");
      throw Exception('Erreur réseau création');
    }
  }

  /// ✍️ Envoyer les informations de base (Nom, Marques, Quantité, Ingrédients)
  Future<void> sendBasicInfo(String code, String productName, String brands, String quantity, String ingredients) async {
    final url = Uri.parse('$backendUrl/basic-info');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'code': code,
          'productName': productName,
          'brands': brands,
          'quantity': quantity,
          'ingredients': ingredients,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Informations de base envoyées avec succès.');
      } else {
        print('❌ Erreur HTTP sendBasicInfo (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('🚨 Erreur réseau sendBasicInfo : $e');
    }
  }
}
