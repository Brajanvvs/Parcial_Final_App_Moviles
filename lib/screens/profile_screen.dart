import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../core/auth_gate.dart';
import '../core/feedback.dart';
import '../core/theme.dart';
import '../core/validators.dart';
import '../models/user.dart';
import '../state/auth_controller.dart';
import '../widgets/password_field.dart';
import '../widgets/submit_button.dart';
import '../widgets/user_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  final Map<String, String> _apiErrors = {};
  final Map<String, String> _passwordErrors = {};
  bool _dirty = false;
  bool _saving = false;
  bool _changingPassword = false;
  bool _showPassword = false;
  bool _profileSubmitted = false;
  bool _passwordSubmitted = false;
  String? _syncedKey;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _username.dispose();
    _email.dispose();
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthController>().user;
    if (user != null) _apply(user);
  }

  void _apply(User user) {
    _syncedKey =
        '${user.firstName}|${user.lastName}|${user.username}|${user.email}';
    _firstName.text = user.firstName;
    _lastName.text = user.lastName;
    _username.text = user.username;
    _email.text = user.email;
  }

  void _clear(Map<String, String> errors, String field) {
    if (errors.remove(field) != null) setState(() {});
  }

  Future<void> _save() async {
    final auth = context.read<AuthController>();
    final user = auth.user;
    setState(() => _profileSubmitted = true);
    if (!_formKey.currentState!.validate() || user == null) return;

    final username = _username.text.trim();
    if (username != user.username) {
      try {
        final available = await auth.api.isUsernameAvailable(username);
        if (!available) {
          if (!mounted) return;
          setState(() => _apiErrors['username'] = 'El username ya está en uso');
          _formKey.currentState!.validate();
          return;
        }
      } catch (error) {
        if (!mounted) return;
        showApiError(context, error);
        return;
      }
    }

    setState(() => _saving = true);
    try {
      await auth.updateProfile(
        firstName: _firstName.text,
        lastName: _lastName.text,
        username: username,
      );
      if (!mounted) return;
      setState(() => _dirty = false);
      showMessage(context, 'Cambios guardados');
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
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changePassword() async {
    setState(() => _passwordSubmitted = true);
    if (!_passwordKey.currentState!.validate()) return;
    setState(() => _changingPassword = true);
    try {
      await context.read<AuthController>().changePassword(
        currentPassword: _currentPassword.text,
        newPassword: _newPassword.text,
        confirmPassword: _confirmPassword.text,
      );
      if (!mounted) return;
      _currentPassword.clear();
      _newPassword.clear();
      _confirmPassword.clear();
      setState(() {
        _passwordSubmitted = false;
        _passwordErrors.clear();
      });
      showMessage(context, 'Contraseña actualizada');
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(
        () => _passwordErrors
          ..clear()
          ..addAll(error.fieldErrors),
      );
      _passwordKey.currentState!.validate();
      showApiError(context, error);
    } catch (error) {
      if (!mounted) return;
      showApiError(context, error);
    } finally {
      if (mounted) setState(() => _changingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;
    if (!auth.isAuthenticated || user == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_outline, size: 64, color: AlkostoColors.blue),
              const SizedBox(height: 12),
              const Text(
                'Tu perfil',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
              ),
              const SizedBox(height: 8),
              const Text(
                'Inicia sesión para ver y editar tus datos.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ensureAuthenticated(
                  context,
                  message: 'Inicia sesión para ver y editar tu perfil.',
                ),
                child: const Text('Iniciar sesión'),
              ),
            ],
          ),
        ),
      );
    }
    final syncKey =
        '${user.firstName}|${user.lastName}|${user.username}|${user.email}';
    if (!_dirty && syncKey != _syncedKey) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _dirty) return;
        _apply(user);
      });
    }
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Center(child: UserAvatar(user: user, radius: 48)),
        const SizedBox(height: 12),
        Text(
          user.fullName,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          '@${user.username}',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          autovalidateMode: _profileSubmitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            children: [
              TextFormField(
                controller: _firstName,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Nombre'),
                onChanged: (_) {
                  _dirty = true;
                  _clear(_apiErrors, 'firstName');
                },
                validator: (value) =>
                    _apiErrors['firstName'] ??
                    Validators.personName(value, 'El nombre es obligatorio'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastName,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Apellidos'),
                onChanged: (_) {
                  _dirty = true;
                  _clear(_apiErrors, 'lastName');
                },
                validator: (value) =>
                    _apiErrors['lastName'] ??
                    Validators.personName(
                      value,
                      'Los apellidos son obligatorios',
                    ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _username,
                decoration: const InputDecoration(labelText: 'Username'),
                onChanged: (_) {
                  _dirty = true;
                  _clear(_apiErrors, 'username');
                },
                validator: (value) =>
                    _apiErrors['username'] ?? Validators.username(value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  helperText: 'El correo no se puede cambiar',
                ),
              ),
              const SizedBox(height: 16),
              SubmitButton(
                label: 'Guardar cambios',
                loading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Cambiar contraseña',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Form(
          key: _passwordKey,
          autovalidateMode: _passwordSubmitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            children: [
              PasswordField(
                controller: _currentPassword,
                label: 'Contraseña actual',
                visible: _showPassword,
                onToggle: () => setState(() => _showPassword = !_showPassword),
                onChanged: (_) => _clear(_passwordErrors, 'currentPassword'),
                validator: (value) =>
                    _passwordErrors['currentPassword'] ??
                    Validators.requiredText(
                      value,
                      'Ingresa tu contraseña actual',
                    ),
              ),
              const SizedBox(height: 12),
              PasswordField(
                controller: _newPassword,
                label: 'Nueva contraseña',
                visible: _showPassword,
                onToggle: () => setState(() => _showPassword = !_showPassword),
                onChanged: (_) => _clear(_passwordErrors, 'newPassword'),
                validator: (value) =>
                    _passwordErrors['newPassword'] ??
                    Validators.password(value),
              ),
              const SizedBox(height: 12),
              PasswordField(
                controller: _confirmPassword,
                label: 'Verificar contraseña',
                visible: _showPassword,
                onToggle: () => setState(() => _showPassword = !_showPassword),
                textInputAction: TextInputAction.done,
                onChanged: (_) => _clear(_passwordErrors, 'confirmPassword'),
                validator: (value) =>
                    _passwordErrors['confirmPassword'] ??
                    Validators.confirmPassword(value, _newPassword.text),
              ),
              const SizedBox(height: 16),
              SubmitButton(
                label: 'Actualizar contraseña',
                loading: _changingPassword,
                onPressed: _changePassword,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
