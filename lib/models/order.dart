class Order {
  const Order({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.itemCount,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    this.shippingAddress,
    this.paymentMethod,
    required this.items,
  });

  final int id;
  final String status;
  final DateTime createdAt;
  final int itemCount;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final String? shippingAddress;
  final String? paymentMethod;
  final List<OrderItem> items;

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return Order(
      id: (json['id'] as num).toInt(),
      status: (json['status'] ?? '') as String,
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '') as String) ??
          DateTime.now(),
      itemCount: (json['itemCount'] as num?)?.toInt() ?? rawItems.length,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      shipping: (json['shipping'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      shippingAddress: json['shippingAddress'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      items: rawItems
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OrderItem {
  const OrderItem({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });

  final int productId;
  final String productName;
  final String imageUrl;
  final double unitPrice;
  final int quantity;
  final double lineTotal;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: (json['productId'] as num?)?.toInt() ?? 0,
      productName: (json['productName'] ?? '') as String,
      imageUrl: (json['imageUrl'] ?? '') as String,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0,
    );
  }
}
