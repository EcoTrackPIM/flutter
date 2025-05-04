import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import 'take_photos_screen.dart'; // ✅ Ajoute l'import de ton nouvel écran ici

class ProductTypeSelectionScreen extends StatefulWidget {
  final String scannedBarcode;

  const ProductTypeSelectionScreen({Key? key, required this.scannedBarcode}) : super(key: key);

  @override
  _ProductTypeSelectionScreenState createState() => _ProductTypeSelectionScreenState();
}

class _ProductTypeSelectionScreenState extends State<ProductTypeSelectionScreen> {
  String? _selectedCategory;

  final List<Map<String, String>> categories = [
    {
      'title': 'Nourriture',
      'subtitle': 'Légumes, fruits, aliments surgelés',
      'icon': '🍊',
      'value': 'nourriture',
    },
    {
      'title': 'Hygiène personnelle',
      'subtitle': 'Maquillage, savons, dentifrices...',
      'icon': '🧴',
      'value': 'hygiene',
    },
    {
      'title': 'Nourriture pour animaux de compagnie',
      'subtitle': 'Nourriture pour chiens, chats...',
      'icon': '🐾',
      'value': 'animaux',
    },
    {
      'title': 'Autre',
      'subtitle': 'Smartphones, meubles...',
      'icon': '📷',
      'value': 'autre',
    },
  ];

  Future<void> _onNext() async {
    if (_selectedCategory != null) {
      try {
        await ProductService().createNewProduct(widget.scannedBarcode, _selectedCategory!);

        // ✅ Aller directement vers TakePhotosScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TakePhotosScreen()),
        );

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Erreur lors de l\'ajout du produit.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un type de produit.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // ✅ Fond vert clair EcoTrack
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F5E9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4D996F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sélectionnez le type de produit',
          style: TextStyle(color: Color(0xFF4D996F), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: RadioListTile<String>(
                        title: Text(cat['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(cat['subtitle']!),
                        secondary: Text(cat['icon']!, style: const TextStyle(fontSize: 28)),
                        value: cat['value']!,
                        groupValue: _selectedCategory,
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF4D996F)),
                        foregroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF43A047),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Suivant'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
