import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ItemsListController extends ChangeNotifier {
  Map<String, List<String>> categorizedItems = {};
  Map<String, String> categoryFromItem = {};
  final Map<String, String> carbonFootprints = {};

  Future<void> loadCategorizedItems() async {
    final url = Uri.parse('http://192.168.1.128:3000/items');
    try {
      final response = await http.get(url, headers: {'Connection': 'close'});

      if (response.statusCode == 200) {
        final List<dynamic> items = json.decode(response.body);
        Map<String, List<String>> tempMap = {};

        for (var item in items) {
          final name = item['name'];
          final category = item['category'] ?? 'General';

          if (!tempMap.containsKey(category)) {
            tempMap[category] = [];
          }
          tempMap[category]!.add(name);
          categoryFromItem[name] = category;
        }

        categorizedItems = tempMap;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error fetching items: $e');
    }
  }

  Future<void> moveItem(String itemName, String newCategory) async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList('scanned_items') ?? [];

    final updatedItems = items.map((e) {
      final parts = e.split('|');
      final name = parts[0].trim();
      if (name == itemName) {
        prefs.setString('category_$itemName', newCategory);
        return '$itemName|$newCategory';
      }
      return e;
    }).toList();

    await prefs.setStringList('scanned_items', updatedItems);
    await loadCategorizedItems();
  }
}