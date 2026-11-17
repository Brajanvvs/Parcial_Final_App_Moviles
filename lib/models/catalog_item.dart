import 'package:flutter/material.dart';

import 'product.dart';

class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.remoteProductId,
    required this.name,
    required this.brand,
    required this.description,
    required this.price,
    required this.oldPrice,
    required this.imageUrl,
    required this.categoryId,
    required this.categoryName,
    required this.sectionId,
    required this.stock,
  });

  final int id;
  final int remoteProductId;
  final String name;
  final String brand;
  final String description;
  final double price;
  final double oldPrice;
  final String imageUrl;
  final int categoryId;
  final String categoryName;
  final String sectionId;
  final int stock;

  bool get inStock => stock > 0;

  int get discountPercent {
    if (oldPrice <= price || oldPrice <= 0) return 0;
    return (((oldPrice - price) / oldPrice) * 100).round();
  }

  Product toProduct() {
    return Product(
      id: remoteProductId,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      stock: stock,
      categoryId: categoryId,
      categoryName: categoryName,
    );
  }
}

class HomeSection {
  const HomeSection({
    required this.id,
    required this.title,
    required this.emoji,
    required this.productIds,
  });

  final String id;
  final String title;
  final String emoji;
  final List<int> productIds;
}

class CategoryTile {
  const CategoryTile({
    required this.id,
    required this.name,
    required this.icon,
    this.categoryId,
  });

  final int id;
  final String name;
  final IconData icon;
  final int? categoryId;
}
