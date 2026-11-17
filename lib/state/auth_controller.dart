import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../core/api_exception.dart';
import '../models/user.dart';
import '../services/session_store.dart';
import '../services/shop_api.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthController extends ChangeNotifier {
  AuthController({SessionStore? store, ShopApi? api})
    : _store = store ?? SessionStore() {
    _api =
        api ??
        ShopApi(
          ApiClient(token: () => _token, onUnauthorized: handleUnauthorized),
        );
  }

  final SessionStore _store;
  late final ShopApi _api;

  AuthStatus status = AuthStatus.unknown;
  User? user;
  String? _token;
  bool _closing = false;

  ShopApi get api => _api;
  String? get token => _token;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  Future<void> bootstrap() async {
    try {
      final session = await _store.read();
      if (session.token == null) {
        status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }
      _token = session.token;
      user = session.user;
      status = AuthStatus.authenticated;
      notifyListeners();
      try {
        user = await _api.me();
        await _store.save(_token!, user!);
        notifyListeners();
      } on ApiException catch (error) {
        if (error.isUnauthorized) await logout(remote: false);
      }
    } catch (_) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    final session = await _api.login(
      usernameOrEmail: usernameOrEmail.trim(),
      password: password,
    );
    _token = session.token;
    user = session.user;
    await _store.save(session.token, session.user);
    status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return _api.register(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      username: username.trim(),
      email: email.trim(),
      password: password,
      confirmPassword: confirmPassword,
    );
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String username,
  }) async {
    user = await _api.updateProfile(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      username: username.trim(),
    );
    if (_token != null && user != null) await _store.save(_token!, user!);
    notifyListeners();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _api.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  void handleUnauthorized() {
    if (_closing || status != AuthStatus.authenticated) return;
    logout(remote: false);
  }

  Future<void> logout({bool remote = true}) async {
    if (_closing) return;
    _closing = true;
    if (remote && _token != null) {
      try {
        await _api.logout();
      } catch (_) {
        // La sesión local se cierra aunque el servidor no responda.
      }
    }
    _token = null;
    user = null;
    status = AuthStatus.unauthenticated;
    await _store.clear();
    _closing = false;
    notifyListeners();
  }
}
