import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'state/auth_controller.dart';
import 'state/cart_controller.dart';

class ShopApp extends StatefulWidget {
  const ShopApp({super.key});

  @override
  State<ShopApp> createState() => _ShopAppState();
}

class _ShopAppState extends State<ShopApp> {
  late final AuthController _auth = AuthController();

  @override
  void initState() {
    super.initState();
    _auth.bootstrap();
  }

  @override
  void dispose() {
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: _auth),
        ChangeNotifierProvider(
          create: (context) => CartController(context.read<AuthController>()),
        ),
      ],
      child: Consumer<AuthController>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'DesCuento!',
            debugShowCheckedModeBanner: false,
            theme: buildTheme(),
            // Invitados pueden ver el catálogo; el login se pide al comprar.
            home: switch (auth.status) {
              AuthStatus.unknown => const SplashScreen(),
              AuthStatus.authenticated ||
              AuthStatus.unauthenticated => const MainShell(),
            },
          );
        },
      ),
    );
  }
}
