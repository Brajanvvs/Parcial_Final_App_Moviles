import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/login_screen.dart';
import '../state/auth_controller.dart';
import 'theme.dart';

/// Si el usuario no ha iniciado sesión, abre Login y espera el resultado.
/// Devuelve `true` solo cuando queda autenticado.
Future<bool> ensureAuthenticated(
  BuildContext context, {
  String message = 'Inicia sesión o crea una cuenta para continuar con tu compra.',
}) async {
  final auth = context.read<AuthController>();
  if (auth.isAuthenticated) return true;

  final goLogin = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.lock_outline, color: AlkostoColors.orange),
      title: const Text('Inicia sesión'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Seguir mirando'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Iniciar sesión'),
        ),
      ],
    ),
  );

  if (goLogin != true || !context.mounted) return false;

  final loggedIn = await Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
  );

  return loggedIn == true ||
      (context.mounted && context.read<AuthController>().isAuthenticated);
}
