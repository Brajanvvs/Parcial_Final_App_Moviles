import '../core/api_client.dart';
import '../models/cart.dart';
import '../models/category.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/promo_banner.dart';
import '../models/user.dart';

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final User user;
}

class ShopApi {
  ShopApi(this._client);

  final ApiClient _client;

  Future<AuthSession> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    final data = await _client.post(
      '/auth/login',
      body: {'usernameOrEmail': usernameOrEmail, 'password': password},
    );
    final map = data as Map<String, dynamic>;
    return AuthSession(
      token: map['token'] as String,
      user: User.fromJson(map['user'] as Map<String, dynamic>),
    );
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return _client.post(
      '/auth/register',
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );
  }

  Future<void> logout() => _client.post('/auth/logout', auth: true);

  Future<bool> isUsernameAvailable(String username) async {
    final data = await _client.get(
      '/auth/check-username',
      query: {'username': username},
    );
    return (data as Map)['available'] == true;
  }

  Future<bool> isEmailAvailable(String email) async {
    final data = await _client.get(
      '/auth/check-email',
      query: {'email': email},
    );
    return (data as Map)['available'] == true;
  }

  Future<String> forgotPassword(String email) async {
    final data = await _client.post(
      '/auth/forgot-password',
      body: {'email': email},
    );
    final message = (data as Map)['message'];
    if (message is String && message.isNotEmpty) return message;
    return 'Si el correo está registrado, te enviamos un enlace para restablecer tu contraseña';
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _client.post(
      '/auth/reset-password',
      body: {
        'token': token,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }

  Future<User> me() async {
    final data = await _client.get('/users/me', auth: true);
    return User.fromJson(data as Map<String, dynamic>);
  }

  Future<User> updateProfile({
    required String firstName,
    required String lastName,
    required String username,
  }) async {
    final data = await _client.put(
      '/users/me',
      auth: true,
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
      },
    );
    return User.fromJson(data as Map<String, dynamic>);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _client.put(
      '/users/me/password',
      auth: true,
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }

  Future<List<PromoBanner>> banners() async {
    final data = await _client.get('/banners');
    return _list(data, PromoBanner.fromJson);
  }

  Future<List<Category>> categories() async {
    final data = await _client.get('/categories');
    return _list(data, Category.fromJson);
  }

  Future<List<Product>> products({String? search, int? categoryId}) async {
    final data = await _client.get(
      '/products',
      query: {'search': search?.trim(), 'categoryId': categoryId?.toString()},
    );
    return _list(data, Product.fromJson);
  }

  Future<Product> product(int id) async {
    final data = await _client.get('/products/$id');
    return Product.fromJson(data as Map<String, dynamic>);
  }

  Future<Cart> cart() async {
    final data = await _client.get('/cart', auth: true);
    return Cart.fromJson(data as Map<String, dynamic>);
  }

  Future<Cart> addToCart({
    required int productId,
    required int quantity,
  }) async {
    final data = await _client.post(
      '/cart/items',
      auth: true,
      body: {'productId': productId, 'quantity': quantity},
    );
    return Cart.fromJson(data as Map<String, dynamic>);
  }

  Future<Cart> updateQuantity({
    required int itemId,
    required int quantity,
  }) async {
    final data = await _client.patch(
      '/cart/items/$itemId',
      auth: true,
      body: {'quantity': quantity},
    );
    return Cart.fromJson(data as Map<String, dynamic>);
  }

  Future<Cart> removeItem(int itemId) async {
    final data = await _client.delete('/cart/items/$itemId', auth: true);
    return Cart.fromJson(data as Map<String, dynamic>);
  }

  Future<Order> checkout({
    String? shippingAddress,
    String? paymentMethod,
  }) async {
    final body = <String, dynamic>{};
    final address = shippingAddress?.trim() ?? '';
    final method = paymentMethod?.trim() ?? '';
    if (address.isNotEmpty) body['shippingAddress'] = address;
    if (method.isNotEmpty) body['paymentMethod'] = method;
    final data = await _client.post('/orders/checkout', auth: true, body: body);
    return Order.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Order>> orders() async {
    final data = await _client.get('/orders', auth: true);
    return _list(data, Order.fromJson);
  }

  Future<Order> order(int id) async {
    final data = await _client.get('/orders/$id', auth: true);
    return Order.fromJson(data as Map<String, dynamic>);
  }

  List<T> _list<T>(dynamic data, T Function(Map<String, dynamic>) parse) {
    final raw = data as List<dynamic>? ?? const [];
    return raw.map((item) => parse(item as Map<String, dynamic>)).toList();
  }
}
