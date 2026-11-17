class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.categoryId,
    required this.categoryName,
  });

  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int stock;
  final int categoryId;
  final String categoryName;

  bool get inStock => stock > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      imageUrl: (json['imageUrl'] ?? '') as String,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
      categoryName: (json['categoryName'] ?? '') as String,
    );
  }
}
