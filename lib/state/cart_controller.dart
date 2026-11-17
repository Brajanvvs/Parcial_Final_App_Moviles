import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../core/api_exception.dart';
import '../models/cart.dart';
import '../models/order.dart';
import '../services/shop_api.dart';
import 'auth_controller.dart';

class CartController extends ChangeNotifier {
  CartController(AuthController auth) : _auth = auth {
    _api = ShopApi(
      ApiClient(
        token: () => _auth.token,
        onUnauthorized: _auth.handleUnauthorized,
      ),
    );
    _seenToken = _auth.token;
    _auth.addListener(_onAuthChanged);
    if (_seenToken != null) Future<void>.microtask(refresh);
  }

  final AuthController _auth;
  late final ShopApi _api;

  Cart cart = Cart.empty();
  bool loading = false;
  String? error;
  final Set<int> busyItems = {};
  String? _seenToken;
  bool _disposed = false;

  int get itemCount => cart.summary.itemCount;

  void _onAuthChanged() {
    final token = _auth.token;
    if (token == _seenToken) return;
    _seenToken = token;
    if (token == null) {
      cart = Cart.empty();
      error = null;
      loading = false;
      _notify();
      return;
    }
    refresh();
  }

  Future<void> refresh() async {
    if (_auth.token == null) return;
    loading = true;
    error = null;
    _notify();
    try {
      cart = await _api.cart();
    } on ApiException catch (exception) {
      if (!exception.isUnauthorized) error = exception.message;
    } catch (_) {
      error = 'No se pudo cargar el carrito.';
    } finally {
      loading = false;
      _notify();
    }
  }

  Future<void> add({required int productId, required int quantity}) async {
    cart = await _api.addToCart(productId: productId, quantity: quantity);
    _notify();
  }

  Future<void> setQuantity(CartItem item, int quantity) async {
    if (quantity < 1 || quantity == item.quantity) return;
    busyItems.add(item.id);
    _notify();
    try {
      cart = await _api.updateQuantity(itemId: item.id, quantity: quantity);
    } finally {
      busyItems.remove(item.id);
      _notify();
    }
  }

  Future<void> remove(CartItem item) async {
    busyItems.add(item.id);
    _notify();
    try {
      cart = await _api.removeItem(item.id);
    } finally {
      busyItems.remove(item.id);
      _notify();
    }
  }

  Future<Order> checkout({
    String? shippingAddress,
    String? paymentMethod,
  }) async {
    final order = await _api.checkout(
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
    );
    await refresh();
    return order;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }
}
