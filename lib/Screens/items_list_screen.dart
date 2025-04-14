import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemsListScreen extends StatefulWidget {
  const ItemsListScreen({Key? key}) : super(key: key);

  @override
  State<ItemsListScreen> createState() => _ItemsListScreenState();
}

class _ItemsListScreenState extends State<ItemsListScreen> {
  Map<String, List<String>> categorizedItems = {};
  Map<String, String> categoryFromItem = {};
  Set<String> _highlightedItems = {};
  Map<String, double> usageFrequency = {};

  @override
  void initState() {
    super.initState();
    _loadCategorizedItems();
        _printAllStoredItemsToConsole();

  }

  Future<void> _loadCategorizedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList('scanned_items') ?? [];
    final customCategories = prefs.getStringList('custom_categories') ?? [];

    Map<String, List<String>> tempMap = {};

    for (var item in items) {
      final parts = item.split('|');
      final name = parts[0].trim();
      final category = parts.length > 1 && parts[1].trim().isNotEmpty ? parts[1].trim() : 'General';
      final isFlagged = parts.length >= 4 ? parts[3].trim() == 'true' : false;

      if (!tempMap.containsKey(category)) {
        tempMap[category] = [];
      }
      tempMap[category]!.add(name);
      if (isFlagged) {
        _highlightedItems.add(name);
      }
    }

    for (var category in customCategories) {
      tempMap.putIfAbsent(category, () => []);
    }

    if (!tempMap.containsKey('General')) {
      tempMap['General'] = [];
    }

    for (var category in tempMap.entries) {
      for (var item in category.value) {
        categoryFromItem[item] = category.key;
      }
    }
    for (var item in items) {
      final parts = item.split('|');
      if (parts.length >= 3) {
        usageFrequency[parts[0].trim()] = double.tryParse(parts[2].trim()) ?? 0;
      }
    }

    setState(() => categorizedItems = tempMap);
  }

  Future<void> _moveItemToCategory(String itemName, String fromCategory, String toCategory) async {
    final prefs = await SharedPreferences.getInstance();
    final allItems = prefs.getStringList('scanned_items') ?? [];

    final updatedItems = allItems.map((item) {
      final parts = item.split('|');
      final name = parts[0].trim();
      final cat = parts.length > 1 && parts[1].trim().isNotEmpty ? parts[1].trim() : 'General';
      if (name == itemName && cat == fromCategory) {
        return '$name|$toCategory';
      }
      return item;
    }).toList();

    await prefs.setStringList('scanned_items', updatedItems);
    _loadCategorizedItems();
  }

  Widget _buildItemBox(String item, {bool highlighted = false}) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (BuildContext context) {
            bool isFlagged = _highlightedItems.contains(item);
            return StatefulBuilder(
              builder: (context, setModalState) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Item Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Flag Item'),
                        value: isFlagged,
                        onChanged: (bool value) async {
                          setModalState(() {
                            isFlagged = value;
                          });
                          setState(() {
                            if (value) {
                              _highlightedItems.add(item);
                            } else {
                              _highlightedItems.remove(item);
                            }
                          });

                          final prefs = await SharedPreferences.getInstance();
                          final allItems = prefs.getStringList('scanned_items') ?? [];
                          final updatedItems = allItems.map((itemStr) {
                            final parts = itemStr.split('|');
                            final name = parts[0].trim();
                            final cat = parts.length > 1 ? parts[1].trim() : 'General';
                            final usage = parts.length > 2 ? parts[2].trim() : '0';
                            if (name == item) {
                              return '$name|$cat|$usage|$value';
                            }
                            return itemStr;
                          }).toList();
                          await prefs.setStringList('scanned_items', updatedItems);
                        },
                        secondary: const Icon(Icons.flag),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Usage per month:'),
                          DropdownButton<double>(
                            value: usageFrequency[item] ?? 0,
                            items: [
                              const DropdownMenuItem(value: 0.25, child: Text('¼')),
                              const DropdownMenuItem(value: 0.5, child: Text('½')),
                              ...List.generate(100, (i) => DropdownMenuItem(
                                value: i.toDouble(),
                                child: Text('$i'),
                              )),
                            ],
                            onChanged: (value) async {
                              final prefs = await SharedPreferences.getInstance();
                              final allItems = prefs.getStringList('scanned_items') ?? [];
                        
                              final updatedItems = allItems.map((itemStr) {
                                final parts = itemStr.split('|');
                                final name = parts[0].trim();
                                final cat = parts.length > 1 ? parts[1].trim() : 'General';
                                if (name == item) {
                                  return '$name|$cat|${value.toString()}';
                                }
                                return itemStr;
                              }).toList();
                        
                              await prefs.setStringList('scanned_items', updatedItems);
                        
                              setState(() {
                                usageFrequency[item] = value!;
                              });
                        
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Usage set to ${value == 0.25 ? "¼" : value == 0.5 ? "½" : value!.toInt()}')),
                              );
                            },
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: _highlightedItems.contains(item) ? Colors.red.shade100 : (highlighted ? Colors.green.shade100 : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        alignment: Alignment.center,
          child: Stack(
            children: [
              Center(
                child: Text(item, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
              ),
              if (usageFrequency.containsKey(item))
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade800,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      usageFrequency[item]! >= 1
                          ? usageFrequency[item]!.toInt().toString()
                          : usageFrequency[item] == 0.5 ? '½' : '¼',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              if (_highlightedItems.contains(item))
                Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(Icons.flag, color: Colors.red, size: 16),
                ),
            ],
          ),
      ),
    );
  }
 void _printAllStoredItemsToConsole() async {
  final prefs = await SharedPreferences.getInstance();
  final items = prefs.getStringList('scanned_items') ?? [];

  debugPrint('🔎 Stored Items Debug Log:');
  for (final item in items) {
    final parts = item.split('|');
    final name = parts.isNotEmpty ? parts[0].trim() : '';
    final category = parts.length > 1 ? parts[1].trim() : 'General';
    final usage = parts.length > 2 ? parts[2].trim() : '0';
    final flagged = parts.length > 3 ? parts[3].trim() : 'false';

    debugPrint('• Item: "$name" | Category: "$category" | Usage: $usage | Flagged: $flagged');
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade800,
        title: const Text('Items by Category'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Category',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  final TextEditingController _controller = TextEditingController();

                  return AlertDialog(
                    title: const Text('New Category'),
                    content: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(hintText: 'Enter category name'),
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      ElevatedButton(
                        child: const Text('Add'),
                        onPressed: () async {
                          final newCategory = _controller.text.trim();
                          if (newCategory.isNotEmpty) {
                            final prefs = await SharedPreferences.getInstance();
                            final existing = prefs.getStringList('custom_categories') ?? [];
                            if (!existing.contains(newCategory)) {
                              existing.add(newCategory);
                              await prefs.setStringList('custom_categories', existing);
                            }
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: categorizedItems.entries.map((entry) {
          final category = entry.key;
          final items = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade400),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (category.toLowerCase() != 'general')
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (String value) async {
                          final prefs = await SharedPreferences.getInstance();
                          final customCategories = prefs.getStringList('custom_categories') ?? [];

                          if (value == 'rename') {
                            final TextEditingController renameController = TextEditingController(text: category);
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Rename Category'),
                                content: TextField(
                                  controller: renameController,
                                  decoration: const InputDecoration(hintText: 'Enter new category name'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final newName = renameController.text.trim();
                                      if (newName.isNotEmpty && newName != category) {
                                        final updatedItems = <String>[];
                                        final allItems = prefs.getStringList('scanned_items') ?? [];

                                        for (final item in allItems) {
                                          final parts = item.split('|');
                                          final name = parts[0].trim();
                                          final cat = parts.length > 1 && parts[1].trim().isNotEmpty ? parts[1].trim() : 'General';
                                          if (cat == category) {
                                            updatedItems.add('$name|$newName');
                                          } else {
                                            updatedItems.add(item);
                                          }
                                        }

                                        await prefs.setStringList('scanned_items', updatedItems);

                                        if (customCategories.contains(category)) {
                                          customCategories.remove(category);
                                          customCategories.add(newName);
                                          await prefs.setStringList('custom_categories', customCategories);
                                        }

                                        Navigator.of(context).pop();
                                        _loadCategorizedItems();
                                      }
                                    },
                                    child: const Text('Rename'),
                                  ),
                                ],
                              ),
                            );
                          } else if (value == 'delete') {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Category'),
                                content: const Text('Are you sure you want to delete this category and its items?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final updatedItems = <String>[];
                                      final allItems = prefs.getStringList('scanned_items') ?? [];

                                      for (final item in allItems) {
                                        final parts = item.split('|');
                                        final cat = parts.length > 1 && parts[1].trim().isNotEmpty ? parts[1].trim() : 'General';
                                        if (cat != category) {
                                          updatedItems.add(item);
                                        }
                                      }

                                      await prefs.setStringList('scanned_items', updatedItems);

                                      if (customCategories.contains(category)) {
                                        customCategories.remove(category);
                                        await prefs.setStringList('custom_categories', customCategories);
                                      }

                                      Navigator.of(context).pop();
                                      _loadCategorizedItems();
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'rename',
                            child: Text('Rename'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              DragTarget<String>(
                onAccept: (itemName) {
                  final fromCategory = categoryFromItem[itemName];
                  if (fromCategory != null && fromCategory != category) {
                    setState(() {
                      _highlightedItems.add(itemName);
                    });
                    Future.delayed(const Duration(milliseconds: 600), () {
                      setState(() {
                        _highlightedItems.remove(itemName);
                      });
                    });
                    _moveItemToCategory(itemName, fromCategory, category);
                  }
                },
                builder: (context, candidateData, rejectedData) {
                  return SizedBox(
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.green.shade300, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            runAlignment: WrapAlignment.start,
                            spacing: 5,
                            runSpacing: 10,
                            children: [
                              ...items.map((item) {
                                return LongPressDraggable<String>(
                                  data: item,
                                  feedback: Material(
                                    child: Container(
                                      width: 70,
                                      height: 70,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(item, style: const TextStyle(fontSize: 14, color: Colors.white)),
                                    ),
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.4,
                                    child: _buildItemBox(item),
                                  ),
                                  child: _buildItemBox(item, highlighted: _highlightedItems.contains(item)),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}