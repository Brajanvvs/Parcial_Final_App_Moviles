import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/auth_gate.dart';
import '../core/theme.dart';
import '../state/auth_controller.dart';
import '../state/cart_controller.dart';
import '../widgets/app_drawer.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _index = 0;

  void _go(int index) {
    setState(() => _index = index);
    _scaffoldKey.currentState?.closeDrawer();
  }

  Future<void> _goProtected(int index, {required String message}) async {
    final ok = await ensureAuthenticated(context, message: message);
    if (!ok || !mounted) return;
    _go(index);
  }

  Future<void> _openOrders() async {
    _scaffoldKey.currentState?.closeDrawer();
    final ok = await ensureAuthenticated(
      context,
      message: 'Inicia sesión para ver tus pedidos.',
    );
    if (!ok || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const OrdersScreen()),
    );
  }

  Future<void> _openSearch() async {
    await Navigator.of(context).push(
      MaterialPageRoute<String?>(builder: (_) => const SearchScreen()),
    );
  }

  Future<void> _openLogin() async {
    _scaffoldKey.currentState?.closeDrawer();
    await Navigator.of(context).push(
      MaterialPageRoute<bool>(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _logout() async {
    _scaffoldKey.currentState?.closeDrawer();
    await context.read<AuthController>().logout();
    if (!mounted) return;
    setState(() => _index = 0);
  }

  Future<void> _onDestinationSelected(int index) async {
    if (index == 0) {
      _go(0);
      return;
    }
    if (index == 1) {
      await _goProtected(
        1,
        message: 'Inicia sesión o crea una cuenta para ver tu carrito y comprar.',
      );
      return;
    }
    await _goProtected(
      2,
      message: 'Inicia sesión para ver y editar tu perfil.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = context.watch<CartController>().itemCount;
    final auth = context.watch<AuthController>();
    // Si cierra sesión estando en carrito/perfil, vuelve al Home.
    final safeIndex = (!auth.isAuthenticated && _index != 0) ? 0 : _index;
    if (safeIndex != _index) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _index = 0);
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AlkostoColors.surface,
      appBar: safeIndex == 0
          ? AppBar(
              titleSpacing: 0,
              title: Row(
                children: [
                  const Text(
                    'DesCuento!',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      child: InkWell(
                        onTap: _openSearch,
                        borderRadius: BorderRadius.circular(22),
                        child: const SizedBox(
                          height: 40,
                          child: Row(
                            children: [
                              SizedBox(width: 12),
                              Icon(Icons.search, color: AlkostoColors.muted, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '¿Qué buscas hoy?',
                                  style: TextStyle(
                                    color: AlkostoColors.muted,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: auth.isAuthenticated ? 'Mi cuenta' : 'Iniciar sesión',
                  onPressed: () => _onDestinationSelected(2),
                  icon: const Icon(Icons.person_outline),
                ),
                IconButton(
                  tooltip: 'Mi carrito',
                  onPressed: () => _onDestinationSelected(1),
                  icon: Badge(
                    isLabelVisible: auth.isAuthenticated && count > 0,
                    backgroundColor: AlkostoColors.orange,
                    label: Text(count > 99 ? '99+' : '$count'),
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                ),
              ],
            )
          : AppBar(
              title: Text(switch (safeIndex) {
                1 => 'Mi carrito',
                2 => 'Mi cuenta',
                _ => 'DesCuento!',
              }),
            ),
      drawer: AppDrawer(
        onHome: () => _go(0),
        onOrders: _openOrders,
        onProfile: () => _onDestinationSelected(2),
        onLogin: _openLogin,
        onLogout: _logout,
      ),
      body: IndexedStack(
        index: safeIndex,
        children: [
          HomeScreen(onOpenSearch: _openSearch),
          CartScreen(onBrowse: () => _go(0)),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: auth.isAuthenticated && count > 0,
              backgroundColor: AlkostoColors.orange,
              label: Text('$count'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: auth.isAuthenticated && count > 0,
              backgroundColor: AlkostoColors.orange,
              label: Text('$count'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Carrito',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
