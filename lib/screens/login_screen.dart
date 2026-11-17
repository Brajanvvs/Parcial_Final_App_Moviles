import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../core/feedback.dart';
import '../core/theme.dart';
import '../core/validators.dart';
import '../state/auth_controller.dart';
import '../widgets/password_field.dart';
import '../widgets/submit_button.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  final Map<String, String> _apiErrors = {};
  bool _visible = false;
  bool _loading = false;
  bool _submitted = false;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
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
      await context.read<AuthController>().login(
        usernameOrEmail: _identifier.text,
        password: _password.text,
      );
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
      backgroundColor: AlkostoColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                    Container(
                      height: 72,
                      decoration: BoxDecoration(
                        color: AlkostoColors.navy,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.storefront,
                            color: AlkostoColors.orange,
                            size: 34,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'DesCuento!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 26,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Inicia sesión',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AlkostoColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Compra tecnología, hogar y más',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _identifier,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [
                        AutofillHints.username,
                        AutofillHints.email,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Username o correo',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      onChanged: (_) => _clearError('usernameOrEmail'),
                      validator: (value) =>
                          _apiErrors['usernameOrEmail'] ??
                          Validators.loginIdentifier(value),
                    ),
                    const SizedBox(height: 14),
                    PasswordField(
                      controller: _password,
                      label: 'Contraseña',
                      visible: _visible,
                      onToggle: () => setState(() => _visible = !_visible),
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => _clearError('password'),
                      validator: (value) =>
                          _apiErrors['password'] ??
                          Validators.loginPassword(value),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _loading
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                        child: const Text('¿Olvidaste tu contraseña?'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SubmitButton(
                      label: 'Iniciar sesión',
                      loading: _loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('¿No tienes cuenta?'),
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const RegisterScreen(),
                                    ),
                                  );
                                },
                          child: const Text('Crear cuenta'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AlkostoColors.promoBar,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Cuenta de prueba: demo  ·  Demo12345',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AlkostoColors.orangeDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
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
