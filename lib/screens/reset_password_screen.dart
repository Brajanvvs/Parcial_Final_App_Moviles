import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../core/feedback.dart';
import '../core/validators.dart';
import '../state/auth_controller.dart';
import '../widgets/password_field.dart';
import '../widgets/submit_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _token = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final Map<String, String> _apiErrors = {};
  bool _visible = false;
  bool _loading = false;
  bool _submitted = false;

  @override
  void dispose() {
    _token.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _clearError(String field) {
    if (_apiErrors.remove(field) != null) setState(() {});
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthController>().api.resetPassword(
        token: Validators.extractToken(_token.text),
        newPassword: _password.text,
        confirmPassword: _confirm.text,
      );
      if (!mounted) return;
      showMessage(context, 'Contraseña actualizada. Ya puedes iniciar sesión.');
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(
        () => _apiErrors
          ..clear()
          ..addAll(error.fieldErrors),
      );
      _formKey.currentState!.validate();
      showApiError(context, error);
    } catch (error) {
      if (!mounted) return;
      showApiError(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva contraseña')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                autovalidateMode: _submitted
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Abre el enlace del correo y pégalo aquí, o pega solo el token. Después elige tu nueva contraseña.',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _token,
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Enlace o token',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.key_outlined),
                      ),
                      onChanged: (_) => _clearError('token'),
                      validator: (value) {
                        if (_apiErrors['token'] != null) {
                          return _apiErrors['token'];
                        }
                        if (Validators.extractToken(value ?? '').isEmpty) {
                          return 'Pega el enlace o el token del correo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    PasswordField(
                      controller: _password,
                      label: 'Nueva contraseña',
                      visible: _visible,
                      onToggle: () => setState(() => _visible = !_visible),
                      onChanged: (_) => _clearError('newPassword'),
                      validator: (value) =>
                          _apiErrors['newPassword'] ??
                          Validators.password(value),
                    ),
                    const SizedBox(height: 14),
                    PasswordField(
                      controller: _confirm,
                      label: 'Verificar contraseña',
                      visible: _visible,
                      onToggle: () => setState(() => _visible = !_visible),
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => _clearError('confirmPassword'),
                      validator: (value) =>
                          _apiErrors['confirmPassword'] ??
                          Validators.confirmPassword(value, _password.text),
                    ),
                    const SizedBox(height: 22),
                    SubmitButton(
                      label: 'Restablecer contraseña',
                      loading: _loading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
