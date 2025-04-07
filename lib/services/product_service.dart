import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  static const String baseUrl = 'https://world.openfoodfacts.org/api/v0/product';

  /// Recherche un produit par code-barres
  Future<Product?> fetchProduct(String barcode) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$barcode.json'));

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

  /// Recherche par mot-clé (filtré par impact carbone > 0)
  Future<List<Product>> searchProducts(String query) async {
    final url = Uri.parse(
        'https://world.openfoodfacts.org/cgi/search.pl?search_terms=$query&search_simple=1&action=process&json=1');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = (data['products'] as List)
            .map((item) => Product.fromJson(item))
            .where((product) => product.carbonImpact > 0)
            .toList();
        return products;
      } else {
        print("Erreur lors de la recherche : ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Erreur recherche produits : $e");
      return [];
    }
  }
}
