import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  static const String backendUrl = 'http://192.168.1.113:3000/products';

  Future<Product?> fetchProduct(String barcode) async {
    try {
      final response = await http.get(Uri.parse('$backendUrl/$barcode.json'));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 1) {
          return Product.fromJson(jsonResponse['product']);
        } else {
          return null;
        }
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur API: $e');
      return null;
    }
  }

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

  Future<List<Product>> fetchScannedProducts() async {
    return fetchSavedProducts();
  }
}
