import 'package:flutter_test/flutter_test.dart';
import 'package:taller_final/models/cart.dart';
import 'package:taller_final/models/product.dart';
import 'package:taller_final/models/user.dart';

void main() {
  test('product and user parse the API payload', () {
    final product = Product.fromJson({
      'id': 1,
      'name': 'Camiseta',
      'description': 'Algodón',
      'price': 39900.00,
      'imageUrl': 'https://img.test/1',
      'stock': 50,
      'categoryId': 1,
      'categoryName': 'Ropa',
    });
    expect(product.price, 39900);
    expect(product.inStock, isTrue);

    final user = User.fromJson({
      'id': 1,
      'firstName': 'Usuario',
      'lastName': 'Demo',
      'fullName': 'Usuario Demo',
      'username': 'demo',
      'email': 'demo@ecommerce.test',
    });
    expect(user.initials, 'UD');
    expect(user.toJson()['username'], 'demo');
  });

  test('cart summary keeps the server totals', () {
    final cart = Cart.fromJson({
      'items': [
        {
          'id': 2,
          'productId': 1,
          'name': 'Camiseta',
          'imageUrl': 'https://img.test/1',
          'unitPrice': 39900,
          'quantity': 1,
          'stock': 50,
          'lineTotal': 39900,
        },
      ],
      'summary': {
        'itemCount': 1,
        'subtotal': 39900,
        'taxRate': 0.19,
        'tax': 7581,
        'shipping': 12000,
        'total': 59481,
      },
    });
    expect(cart.summary.total, 59481);
    expect(cart.items.single.quantity, 1);
    expect(Cart.empty().isEmpty, isTrue);
  });
}
