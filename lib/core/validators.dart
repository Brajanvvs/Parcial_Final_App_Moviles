class Validators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _username = RegExp(r'^[a-zA-Z0-9._]+$');

  static String? requiredText(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? email(String? value) {
    final empty = requiredText(value, 'El correo es obligatorio');
    if (empty != null) return empty;
    if (!_email.hasMatch(value!.trim())) {
      return 'El formato del correo no es válido';
    }
    return null;
  }

  static String? loginIdentifier(String? value) {
    final empty = requiredText(value, 'Ingresa tu username o correo');
    if (empty != null) return empty;
    final text = value!.trim();
    if (text.contains('@') && !_email.hasMatch(text)) {
      return 'El formato del correo no es válido';
    }
    return null;
  }

  static String? loginPassword(String? value) {
    final empty = requiredText(value, 'La contraseña es obligatoria');
    if (empty != null) return empty;
    if (value!.length < 6) {
      return 'La contraseña debe tener mínimo 6 caracteres';
    }
    return null;
  }

  static String? password(String? value) {
    final empty = requiredText(value, 'La contraseña es obligatoria');
    if (empty != null) return empty;
    if (value!.length < 8) {
      return 'La contraseña debe tener mínimo 8 caracteres';
    }
    return null;
  }

  static String? username(String? value) {
    final empty = requiredText(value, 'El username es obligatorio');
    if (empty != null) return empty;
    final text = value!.trim();
    if (text.length < 3 || text.length > 40) {
      return 'El username debe tener entre 3 y 40 caracteres';
    }
    if (!_username.hasMatch(text)) {
      return 'Solo letras, números, punto y guion bajo';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final empty = requiredText(value, 'Confirma la contraseña');
    if (empty != null) return empty;
    if (value != original) return 'Las contraseñas no coinciden';
    return null;
  }

  static String? personName(String? value, String emptyMessage) {
    final empty = requiredText(value, emptyMessage);
    if (empty != null) return empty;
    if (value!.trim().length > 80) return 'Debe tener máximo 80 caracteres';
    return null;
  }

  /// Acepta el token plano o un enlace que lo traiga en `?token=`.
  static String extractToken(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return '';
    final uri = Uri.tryParse(text);
    final queryToken = uri?.queryParameters['token'];
    if (queryToken != null && queryToken.trim().isNotEmpty) {
      return queryToken.trim();
    }
    return text;
  }
}
