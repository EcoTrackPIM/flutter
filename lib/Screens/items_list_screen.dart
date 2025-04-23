import 'package:flutter/material.dart';
import 'package:flutter_eco_track/Components/Toolbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'CarbonFootprintScreen.dart';

class ItemsListScreen extends StatefulWidget {
  const ItemsListScreen({Key? key}) : super(key: key);

  @override
  State<ItemsListScreen> createState() => _ItemsListScreenState();
}

class _ItemsListScreenState extends State<ItemsListScreen> {
  Map<String, List<String>> categorizedItems = {};
  Map<String, String> categoryFromItem = {};
  final Map<String, String> _carbonFootprints = {};

  @override
  void initState() {
    super.initState();

    //_addManualItems(); // Add items manually on screen load
        _loadCategorizedItems();

  }
void _addManualItems() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Define your manual items
  final List<String> manualItems = [
  'screen|food',
  'laptop|food',
  'bath towel|food',
  'Christmas stocking|food',
  
  // General Category
  'modem|General',
  'web site|General',
  'space bar|General',
  'monitor|General',
  'ant|General',
  'computer keyboard|General',
  
  // Kitchen Category
  'shovel|kitchen',
  'knife|kitchen',
  'plate|kitchen',
  'frying pan|kitchen',
  
  // Electronics Category
  'television|electronics',
  'smartphone|electronics',
  'tablet|electronics',
  'headphones|electronics',
  'charger|electronics',

  // Clothing Category
  't-shirt|clothing',
  'jeans|clothing',
  'jacket|clothing',
  'shoes|clothing',
  'hat|clothing',

  // Furniture Category
  'sofa|furniture',
  'table|furniture',
  'chair|furniture',
  'bookshelf|furniture',
  'lamp|furniture',
  
  // Sports Category
  'football|sports',
  'basketball|sports',
  'tennis racket|sports',
  'gym equipment|sports',
  'soccer ball|sports',
  ];

  // Retrieve any existing items from SharedPreferences
  final List<String> savedItems = prefs.getStringList('scanned_items') ?? [];
  
  // Add the manual items to the list if they are not already in the storage
  for (var item in manualItems) {
    if (!savedItems.contains(item)) {
      savedItems.add(item);
    }
  }

  // Save the updated list back to SharedPreferences
  await prefs.setStringList('scanned_items', savedItems);

  debugPrint('✅ Manually added items to storage');
}
  Future<void> _loadCategorizedItems() async {
  final prefs = await SharedPreferences.getInstance();
  final items = prefs.getStringList('scanned_items') ?? [];
  final customCategories = prefs.getStringList('custom_categories') ?? [];

  // 🔍 PRINT the raw stored items in terminal
  print("📦 Loaded scanned_items from SharedPreferences:");
  for (var item in items) {
    print("- $item");
  }

  Map<String, List<String>> tempMap = {};

  for (var item in items) {
    final parts = item.split('|');
    final name = parts[0].trim();
    final category = parts.length > 1 && parts[1].trim().isNotEmpty ? parts[1].trim() : 'General';

    if (!tempMap.containsKey(category)) {
      tempMap[category] = [];
    }
    tempMap[category]!.add(name);
    categoryFromItem[name] = category;
  }

  for (var category in customCategories) {
    tempMap.putIfAbsent(category, () => []);
  }

  setState(() => categorizedItems = tempMap);
}



  void _moveItem(String itemName, String newCategory) async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList('scanned_items') ?? [];
    final updatedItems = items.map((e) {
      final parts = e.split('|');
      final name = parts[0].trim();
      if (name == itemName) {
        // Update shared preference key for category
        prefs.setString('category_$itemName', newCategory);
        return '$itemName|$newCategory';
      } else {
        return e;
      }
    }).toList();
    await prefs.setStringList('scanned_items', updatedItems);
    _loadCategorizedItems();
  }

    Widget _buildDraggableItem(String itemName) {
  return LongPressDraggable<String>(
    data: itemName,
    feedback: Material(
      color: Colors.transparent, // Makes feedback draggable item not have a background
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFFE5F5E9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        alignment: Alignment.center,
        child: Text(
          itemName,
          style: const TextStyle(color: Colors.black, fontSize: 12),
        ),
      ),
    ),
    childWhenDragging: Material( // This part will display the placeholder while dragging
      color: Colors.transparent, // Transparent color while dragging
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          itemName,
          style: const TextStyle(color: Colors.black, fontSize: 12),
        ),
      ),
    ),
    onDragEnd: (details) {
      if (details.wasAccepted) {
        // If the item was dropped into a valid target, refresh the categorized items
        _loadCategorizedItems();
      }
    },
    child: GestureDetector(
      onTap: () async {
        final footprintText = _carbonFootprints[itemName] ?? '0';
        final footprintValue = double.tryParse(footprintText.split(' ').first) ?? 0;
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarbonFootprintScreen(itemName: itemName),
          ),
        );

        if (mounted && result == true) {
          setState(() {
            _loadCategorizedItems();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Changes applied"),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              itemName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
            if (_carbonFootprints.containsKey(itemName))
              Text(
                _carbonFootprints[itemName]!,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildDonutChart() {
    final total = categorizedItems.values.fold<int>(0, (sum, list) => sum + list.length);
    if (total == 0) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🌿 Category Overview",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2F6650),
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: categorizedItems.entries.map((entry) {
              final percent = ((entry.value.length / total) * 100).toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                    Text('$percent%', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDonutChart(),
              const SizedBox(height: 24),
              ...categorizedItems.entries.map((entry) {
                final category = entry.key;
                final items = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3E8E65),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF3E8E65)),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    DragTarget<String>(
                      onWillAccept: (data) => true,
                      onAccept: (itemName) {
                        final fromCategory = categoryFromItem[itemName];
                        if (fromCategory != null && fromCategory != category) {
                          _moveItem(itemName, category);
                        }
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFB2D8C2)),
                          ),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: items.map((item) => _buildDraggableItem(item)).toList(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomToolbar(
        context: context,
        currentIndex: 0,
      ),
    );
  }
}