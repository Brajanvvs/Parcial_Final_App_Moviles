import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../state/auth_controller.dart';
import 'user_avatar.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.onHome,
    required this.onOrders,
    required this.onProfile,
    required this.onLogin,
    required this.onLogout,
  });

  final VoidCallback onHome;
  final VoidCallback onOrders;
  final VoidCallback onProfile;
  final VoidCallback onLogin;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;
    final theme = Theme.of(context);
    final guest = !auth.isAuthenticated;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              color: AlkostoColors.navy,
              child: guest
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person_outline, color: Colors.white, size: 30),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Invitado',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Mira productos sin cuenta. Inicia sesión para comprar.',
                          style: TextStyle(color: Colors.white70, fontSize: 12.5),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: onLogin,
                          child: const Text('Iniciar sesión'),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        UserAvatar(user: user!, radius: 30),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '@${user.username}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Text(
                                user.email,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Inicio'),
              onTap: onHome,
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Mis pedidos'),
              onTap: onOrders,
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Perfil'),
              onTap: onProfile,
            ),
            const Spacer(),
            const Divider(height: 1),
            if (guest)
              ListTile(
                leading: const Icon(Icons.login, color: AlkostoColors.orangeDark),
                title: const Text(
                  'Iniciar sesión',
                  style: TextStyle(
                    color: AlkostoColors.orangeDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: onLogin,
              )
            else
              ListTile(
                leading: Icon(Icons.logout, color: theme.colorScheme.error),
                title: Text(
                  'Cerrar sesión',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: onLogout,
              ),
          ],
        ),
      ),
    );
  }
}
