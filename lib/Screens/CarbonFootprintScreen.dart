import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
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
  List<String> allCategories = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadItemData());
  }

  Future<void> _loadItemData() async {
    final prefs = await SharedPreferences.getInstance();

    carbonFootprint = prefs.getDouble('carbonFootprint_${widget.itemName}') ?? 0.0;
    selectedCategory = prefs.getString('category_${widget.itemName}') ?? 'General';
    usageCount = prefs.getInt('usageCount_${widget.itemName}') ?? 1;

    final scannedItems = prefs.getStringList('scanned_items') ?? [];
    final categories = scannedItems.map((e) => e.split('|').length > 1 ? e.split('|')[1].trim() : 'General').toSet().toList();
    allCategories = categories.isEmpty ? ['General'] : categories;

    print('Item: ${widget.itemName}, Category: $selectedCategory, Usage: $usageCount');

    setState(() {});
  }

void _updateUsageCount(int newCount) async {
  if (newCount == usageCount) return; // ✅ Prevent redundant update

  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('usageCount_${widget.itemName}', newCount);
  setState(() => usageCount = newCount);
}
  void _showUsagePicker(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SizedBox(
        height: 250,
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text('Select Usage Count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(initialItem: usageCount - 1),
                onSelectedItemChanged: (index) {
                  _updateUsageCount(index + 1);
                },
                children: List.generate(99, (index) => Center(child: Text('${index + 1}'))),
              ),
            ),
          ],
        ),
      );
    },
  );
}
void _updateCategory(String newCategory) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('category_${widget.itemName}', newCategory);

  // 🔁 Update the scanned_items list
  List<String> scannedItems = prefs.getStringList('scanned_items') ?? [];
  for (int i = 0; i < scannedItems.length; i++) {
    if (scannedItems[i].startsWith('${widget.itemName}|')) {
      scannedItems[i] = '${widget.itemName}|$newCategory';
    }
  }
  await prefs.setStringList('scanned_items', scannedItems);

  print('✅ Updated ${widget.itemName} to new category: $newCategory');
  print('📦 Updated scanned_items list:');
  for (var item in scannedItems) {
    print('- $item');
  }

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Category updated.')),
    );

    // ⏳ Wait a bit so the user sees the snackbar, then return
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context, true); // ✅ Return true to notify caller to reload
    });
  }
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
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Item',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();

              await prefs.remove('carbonFootprint_${widget.itemName}');
              await prefs.remove('category_${widget.itemName}');
              await prefs.remove('usageCount_${widget.itemName}');

              List<String> items = prefs.getStringList('allItems') ?? [];
              items.remove(widget.itemName);
              await prefs.setStringList('allItems', items);

              List<String> scannedItems = prefs.getStringList('scanned_items') ?? [];
              scannedItems.removeWhere((entry) => entry.startsWith('${widget.itemName}|'));
              await prefs.setStringList('scanned_items', scannedItems);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item deleted.')),
                );
                Future.delayed(const Duration(milliseconds: 300), () => Navigator.pop(context, true));
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade100,
                  border: Border.all(
                    color: Colors.green.shade700,
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${carbonFootprint.toStringAsFixed(2)} kg CO₂',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
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
            Text(
              widget.itemName,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
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
            DropdownButton<String>(
              value: selectedCategory,
              items: allCategories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newCategory) {
                if (newCategory != null) {
                  _updateCategory(newCategory);
                }
              },
            ),
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
            GestureDetector(
  onTap: () => _showUsagePicker(context),
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade400),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.arrow_drop_down),
        const SizedBox(width: 10),
        Text(
          'Used $usageCount time${usageCount > 1 ? 's' : ''}',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    ),
  ),
),
            const SizedBox(height: 40),
            const Text(
              'Tips to Reduce Carbon Footprint:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text('• Use items for a longer period before replacing.'),
            const Text('• Recycle or donate used products.'),
            const Text('• Opt for sustainable alternatives when possible.'),
          ],
        ),
      ),
    );
  }
}
