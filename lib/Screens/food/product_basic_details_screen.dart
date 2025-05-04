import 'package:flutter/material.dart';
import '../../services/product_service.dart';

class ProductBasicDetailsScreen extends StatefulWidget {
  final String scannedBarcode;

  const ProductBasicDetailsScreen({Key? key, required this.scannedBarcode}) : super(key: key);

  @override
  _ProductBasicDetailsScreenState createState() => _ProductBasicDetailsScreenState();
}

class _ProductBasicDetailsScreenState extends State<ProductBasicDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();

  @override
  void dispose() {
    _productNameController.dispose();
    _brandController.dispose();
    _quantityController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ProductService().sendBasicInfo(
          widget.scannedBarcode,
          _productNameController.text,
          _brandController.text,
          _quantityController.text,
          _ingredientsController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Produit enregistré avec succès !'), backgroundColor: Colors.green),
        );

        Navigator.popUntil(context, (route) => route.isFirst);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9), // Vert très clair
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: const Text("Détails du Produit", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Text(
                  "Veuillez compléter les informations",
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                _buildSection("Nom du produit", Icons.fastfood, _productNameController, "Ex: Nutella"),
                const SizedBox(height: 16),
                _buildSection("Marque", Icons.store, _brandController, "Ex: Ferrero"),
                const SizedBox(height: 16),
                _buildSection("Quantité", Icons.scale, _quantityController, "Ex: 500g"),
                const SizedBox(height: 16),
                _buildSection("Ingrédients", Icons.list_alt, _ingredientsController, "Ex: sucre, lait..."),

                const Spacer(),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.green),
                          foregroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Enregistrer'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, TextEditingController controller, String hint) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
            ],
          ),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              hintStyle: const TextStyle(color: Colors.grey),
            ),
            validator: (value) => (title != "Quantité" && title != "Ingrédients" && value!.isEmpty) ? "Champ requis" : null,
          ),
        ],
      ),
    );
  }
}
