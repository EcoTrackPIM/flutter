class Product {
  final String code;
  final String productName;
  final String? brands;
  final String? categories;
  final String? imageUrl;
  final double carbonImpact;
  final String? ingredients;
  final String? recyclability;
  final List<String>? languages;

  Product({
    required this.code,
    required this.productName,
    this.brands,
    this.categories,
    this.imageUrl,
    this.carbonImpact = 0.0,
    this.ingredients,
    this.recyclability,
    this.languages,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      code: json['code'] ?? '',
      productName: json['product_name'] ?? '',
      brands: json['brands'],
      categories: json['categories'],
      imageUrl: json['imageUrl'],
      carbonImpact: (json['carbonImpact'] ?? 0.0).toDouble(),
      ingredients: json['ingredients'],
      recyclability: json['recyclability'],
      languages: json['languages'] != null ? List<String>.from(json['languages']) : null,
    );
  }
}