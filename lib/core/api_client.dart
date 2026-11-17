import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient({required this.token, this.onUnauthorized});

  static const baseUrl = 'https://ecommerce-api-yg2c.onrender.com';
  static const timeout = Duration(seconds: 60);

  final String? Function() token;
  final void Function()? onUnauthorized;

  Future<dynamic> get(
    String path, {
    Map<String, String?> query = const {},
    bool auth = false,
  }) {
    return _send('GET', path, query: query, auth: auth);
  }

  Future<dynamic> post(String path, {Object? body, bool auth = false}) {
    return _send('POST', path, body: body, auth: auth);
  }

  Future<dynamic> put(String path, {Object? body, bool auth = false}) {
    return _send('PUT', path, body: body, auth: auth);
  }

  Future<dynamic> patch(String path, {Object? body, bool auth = false}) {
    return _send('PATCH', path, body: body, auth: auth);
  }

  Future<dynamic> delete(String path, {bool auth = false}) {
    return _send('DELETE', path, auth: auth);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String?> query = const {},
    Object? body,
    bool auth = false,
  }) async {
    final filtered = <String, String>{};
    query.forEach((key, value) {
      if (value != null && value.isNotEmpty) filtered[key] = value;
    });

    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: filtered.isEmpty ? null : filtered);

    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
    };
    if (auth) {
      final current = token();
      if (current == null || current.isEmpty) {
        onUnauthorized?.call();
        throw const ApiException(
          status: 401,
          message: 'Tu sesión expiró. Inicia sesión de nuevo.',
        );
      }
      headers['Authorization'] = 'Bearer $current';
    }

    final encoded = body == null ? null : jsonEncode(body);

    try {
      final response = await _request(
        method,
        uri,
        headers,
        encoded,
      ).timeout(timeout);
      return _decode(response, auth);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        status: 0,
        message:
            'El servidor tardó demasiado. La primera petición puede demorar hasta un minuto.',
      );
    } catch (_) {
      throw const ApiException(
        status: 0,
        message:
            'No hay conexión con el servidor. Si acabas de abrir la app, espera un momento e intenta de nuevo.',
      );
    }
  }

  Future<http.Response> _request(
    String method,
    Uri uri,
    Map<String, String> headers,
    String? body,
  ) {
    switch (method) {
      case 'GET':
        return http.get(uri, headers: headers);
      case 'POST':
        return http.post(uri, headers: headers, body: body);
      case 'PUT':
        return http.put(uri, headers: headers, body: body);
      case 'PATCH':
        return http.patch(uri, headers: headers, body: body);
      case 'DELETE':
        return http.delete(uri, headers: headers);
      default:
        throw ArgumentError('Método HTTP no soportado: $method');
    }
  }

  dynamic _decode(http.Response response, bool auth) {
    final code = response.statusCode;
    if (code >= 200 && code < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    var message = 'Ocurrió un error ($code)';
    var fieldErrors = <String, String>{};
    if (response.body.isNotEmpty) {
      try {
        final data = jsonDecode(response.body);
        if (data is Map) {
          final rawMessage = data['message'];
          if (rawMessage is String && rawMessage.isNotEmpty) {
            message = rawMessage;
          }
          final rawFields = data['fieldErrors'];
          if (rawFields is Map) {
            fieldErrors = rawFields.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            );
          }
        }
      } catch (_) {
        // El cuerpo no es JSON; se conserva el mensaje genérico.
      }
    }

    if (code == 401 && auth) onUnauthorized?.call();

    throw ApiException(
      status: code,
      message: message,
      fieldErrors: fieldErrors,
    );
  }
}
