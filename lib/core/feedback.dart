import 'package:flutter/material.dart';

import 'api_exception.dart';

void showApiError(BuildContext context, Object error) {
  final message = error is ApiException
      ? error.message
      : 'No se pudo completar la acción. Intenta de nuevo.';
  showMessage(context, message);
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
