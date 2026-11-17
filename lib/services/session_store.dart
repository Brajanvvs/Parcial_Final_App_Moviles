import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class SessionStore {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  Future<({String? token, User? user})> read() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final rawUser = prefs.getString(_userKey);
    User? user;
    if (rawUser != null && rawUser.isNotEmpty) {
      user = User.fromJson(jsonDecode(rawUser) as Map<String, dynamic>);
    }
    if (token == null || token.isEmpty) return (token: null, user: null);
    return (token: token, user: user);
  }

  Future<void> save(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
