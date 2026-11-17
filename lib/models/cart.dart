class Cart {
  const Cart({required this.items, required this.summary});

  final List<CartItem> items;
  final CartSummary summary;

  bool get isEmpty => items.isEmpty;

  factory Cart.empty() => const Cart(items: [], summary: CartSummary.empty);

  factory Cart.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return Cart(
      items: rawItems
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      summary: CartSummary.fromJson(
        json['summary'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class CartItem {
  const CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    required this.stock,
    required this.lineTotal,
  });

  final int id;
  final int productId;
  final String name;
  final String imageUrl;
  final double unitPrice;
  final int quantity;
  final int stock;
  final double lineTotal;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: (json['id'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      name: (json['name'] ?? '') as String,
      imageUrl: (json['imageUrl'] ?? '') as String,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0,
    );
  }
}

class CartSummary {
  const CartSummary({
    required this.itemCount,
    required this.subtotal,
    required this.taxRate,
    required this.tax,
    required this.shipping,
    required this.total,
  });

  static const empty = CartSummary(
    itemCount: 0,
    subtotal: 0,
    taxRate: 0.19,
    tax: 0,
    shipping: 0,
    total: 0,
  );

  final int itemCount;
  final double subtotal;
  final double taxRate;
  final double tax;
  final double shipping;
  final double total;

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    return CartSummary(
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.19,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      shipping: (json['shipping'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );
  }
}
