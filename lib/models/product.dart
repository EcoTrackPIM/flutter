class Product {
  final String code;
  final String productName;
  final String? brands;
  final String? categories;
  final String? imageUrl;
  final double carbonImpact;
  final String? ingredients;
  final String? recyclability;
  
  Product({
    required this.code,
    required this.productName,
    this.brands,
    this.categories,
    this.imageUrl,
    this.carbonImpact = 0.0,
    this.ingredients,
    this.recyclability,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      code: json['code'] ?? 'Inconnu',
      productName: json['product_name'] ?? 'Nom inconnu',
      brands: json['brands'],
      categories: json['categories'],
      imageUrl: json['image_url'],
      carbonImpact: (json['ecoscore_data']?['agribalyse']?['co2_total'] ?? 0.0).toDouble(),
      ingredients: json['ingredients_text'],
      recyclability: json['packaging'] ?? 'Non spécifié',
    );
  }
}
