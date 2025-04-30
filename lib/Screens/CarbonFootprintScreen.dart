import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CarbonFootprintScreen extends StatefulWidget {
  final String itemName;

  const CarbonFootprintScreen({
    Key? key,
    required this.itemName,
  }) : super(key: key);

  @override
  _CarbonFootprintScreenState createState() => _CarbonFootprintScreenState();
}

class _CarbonFootprintScreenState extends State<CarbonFootprintScreen> {
  double carbonFootprint = 0.0;
  String selectedCategory = 'General';
  int usageCount = 1;
  String? tips; // ✅ New field for tips
bool recyclable = false; // ♻️
String? location;         // 📍
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadItemData());
  }

  Future<void> _loadItemData() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.128:3000/items/name/${widget.itemName}'));

      if (response.statusCode == 200) {
        final itemData = json.decode(response.body);

        setState(() {
          carbonFootprint = (itemData['carbonFootprint'] ?? 0).toDouble();
          selectedCategory = itemData['category'] ?? 'General';
          usageCount = itemData['amount'] ?? 1;
          tips = itemData['tips']; // ✅ <-- Fetch tips from database
          recyclable = itemData['recyclable'] ?? false;
location = itemData['location'];

        });

        print('✅ Loaded item data: $itemData');
      } else {
        print('❌ Failed to fetch item: ${response.statusCode}');
      }
    } catch (error) {
      print('❌ Error fetching item: $error');
    }
  }

  Future<void> deleteItemByName(String name) async {
    final url = Uri.parse('http://192.168.1.128:3000/items/name/$name');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted successfully!')),
        );
        Navigator.pop(context);
      } else {
        debugPrint('❌ Failed to delete item. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error deleting item: $e');
    }
  }

  Future<void> updateItemAmountByName(String name, int newAmount) async {
    final url = Uri.parse('http://192.168.1.128:3000/items/name/$name/amount');

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': newAmount}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Amount updated successfully!')),
        );
        _loadItemData();
      } else {
        debugPrint('❌ Failed to update amount. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error updating amount: $e');
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${widget.itemName}"?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              deleteItemByName(widget.itemName);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCarbonFootprintBadge() {
final carbonFootprintGrams = carbonFootprint * usageCount;
    String label = '';
    Color color = Colors.grey;

    if (carbonFootprintGrams < 1000) {
      label = 'Low';
      color = Colors.green;
    } else if (carbonFootprintGrams < 5000) {
      label = 'Medium';
      color = Colors.orange;
    } else {
      label = 'High';
      color = Colors.red;
    }

    return Column(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 5),
          ),
          child: Center(
            child: Text(
              '${carbonFootprintGrams.toStringAsFixed(0)} g CO₂',
              style: TextStyle(
                fontSize: 18,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsagePicker() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
  context: context,
  builder: (context) => Container(
    height: 250,
    child: Column(
      children: [
        const SizedBox(height: 10),
        const Text(
          'Select Usage Count',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: CupertinoPicker(
            scrollController: FixedExtentScrollController(initialItem: usageCount - 1),
            itemExtent: 40,
            onSelectedItemChanged: (index) {
              int newUsage = index + 1;
              setState(() => usageCount = newUsage);
            },
            children: List.generate(100, (index) => Center(child: Text('${index + 1} times'))),
          ),
        ),
      ],
    ),
  ),
).then((_) {
  // After picker closes, send update once!
  updateItemAmountByName(widget.itemName, usageCount);
});
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Used $usageCount time${usageCount > 1 ? 's' : ''} (Tap to Change)',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Carbon Footprint Report'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _showDeleteConfirmation,
            tooltip: 'Delete Item',
          ),
        ],
      ),
body: SingleChildScrollView(
  physics: const BouncingScrollPhysics(), // ✅ Makes it smooth (optional)
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Center(child: _buildCarbonFootprintBadge()),
        const SizedBox(height: 30),
        Text(
          'Item Name:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade900,
          ),
        ),
        const SizedBox(height: 10),
        Text(widget.itemName, style: const TextStyle(fontSize: 16, color: Colors.black87)),
        const SizedBox(height: 20),
        Text(
          'Category:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade900,
          ),
        ),
        const SizedBox(height: 10),
        Text(selectedCategory, style: const TextStyle(fontSize: 16, color: Colors.black87)),
        const SizedBox(height: 20),
        Text(
          'Usage Count:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade900,
          ),
        ),
        const SizedBox(height: 10),
        _buildUsagePicker(),
        if (tips != null && tips!.isNotEmpty) ...[
          const SizedBox(height: 40),
          const Text(
            'Tips for this Item:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text('• $tips'),
          const SizedBox(height: 20),
Row(
  children: [
    Icon(
      recyclable ? Icons.recycling : Icons.delete_forever,
      color: recyclable ? Colors.green : Colors.grey,
      size: 28,
    ),
    const SizedBox(width: 10),
    Text(
      recyclable ? 'Recyclable' : 'Not Recyclable',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: recyclable ? Colors.green : Colors.grey,
      ),
    ),
  ],
),const SizedBox(height: 20),
Text(
  'Location:',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.green.shade900,
  ),
),
const SizedBox(height: 10),
Text(
  location ?? 'Unknown',
  style: const TextStyle(fontSize: 16, color: Colors.black87),
),
        ],
      ],
    ),
  ),
),
    );
  }
}