import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../core/feedback.dart';
import '../core/validators.dart';
import '../state/auth_controller.dart';
import '../widgets/password_field.dart';
import '../widgets/submit_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final Map<String, String> _apiErrors = {};
  bool _visible = false;
  bool _loading = false;
  bool _submitted = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _clearError(String field) {
    if (_apiErrors.remove(field) != null) setState(() {});
  }

  Future<void> _checkUsername() async {
    final value = _username.text.trim();
    if (Validators.username(value) != null) return;
    try {
      final available = await context
          .read<AuthController>()
          .api
          .isUsernameAvailable(value);
      if (!mounted) return;
      setState(() {
        if (available) {
          _apiErrors.remove('username');
        } else {
          _apiErrors['username'] = 'El username ya está en uso';
        }
      });
      _formKey.currentState?.validate();
    } catch (_) {
      // El registro vuelve a validar el username en el backend.
    }
  }

  Future<void> _checkEmail() async {
    final value = _email.text.trim();
    if (Validators.email(value) != null) return;
    try {
      final available = await context
          .read<AuthController>()
          .api
          .isEmailAvailable(value);
      if (!mounted) return;
      setState(() {
        if (available) {
          _apiErrors.remove('email');
        } else {
          _apiErrors['email'] = 'Ya existe una cuenta con este correo';
        }
      });
      _formKey.currentState?.validate();
    } catch (_) {}
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _checkUsername();
      await _checkEmail();
      if (!mounted) return;
      if (_apiErrors.isNotEmpty) {
        _formKey.currentState!.validate();
        return;
      }
      await context.read<AuthController>().register(
        firstName: _firstName.text,
        lastName: _lastName.text,
        username: _username.text,
        email: _email.text,
        password: _password.text,
        confirmPassword: _confirm.text,
      );
      if (!mounted) return;
      showMessage(context, 'Cuenta creada. Ya puedes iniciar sesión.');
      Navigator.of(context).pop();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                autovalidateMode: _submitted
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _firstName,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      onChanged: (_) => _clearError('firstName'),
                      validator: (value) =>
                          _apiErrors['firstName'] ??
                          Validators.personName(
                            value,
                            'El nombre es obligatorio',
                          ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _lastName,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Apellidos',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      onChanged: (_) => _clearError('lastName'),
                      validator: (value) =>
                          _apiErrors['lastName'] ??
                          Validators.personName(
                            value,
                            'Los apellidos son obligatorios',
                          ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _username,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                      onChanged: (_) => _clearError('username'),
                      onEditingComplete: _checkUsername,
                      validator: (value) =>
                          _apiErrors['username'] ?? Validators.username(value),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      onChanged: (_) => _clearError('email'),
                      onEditingComplete: _checkEmail,
                      validator: (value) =>
                          _apiErrors['email'] ?? Validators.email(value),
                    ),
                    const SizedBox(height: 14),
                    PasswordField(
                      controller: _password,
                      label: 'Contraseña',
                      visible: _visible,
                      onToggle: () => setState(() => _visible = !_visible),
                      onChanged: (_) => _clearError('password'),
                      validator: (value) =>
                          _apiErrors['password'] ?? Validators.password(value),
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
                      label: 'Registrarse',
                      loading: _loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Ya tengo cuenta'),
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
