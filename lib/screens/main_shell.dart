import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../state/auth_controller.dart';
import '../state/cart_controller.dart';
import '../widgets/app_drawer.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  int _index = 0;

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _go(int index) {
    setState(() => _index = index);
    _scaffoldKey.currentState?.closeDrawer();
  }

  void _openOrders() {
    _scaffoldKey.currentState?.closeDrawer();
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const OrdersScreen()));
  }

  Future<void> _logout() async {
    _scaffoldKey.currentState?.closeDrawer();
    await context.read<AuthController>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final count = context.watch<CartController>().itemCount;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AlkostoColors.surface,
      appBar: _index == 0
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
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        controller: _search,
                        focusNode: _searchFocus,
                        textInputAction: TextInputAction.search,
                        style: const TextStyle(
                          color: AlkostoColors.ink,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: '¿Qué buscas hoy?',
                          hintStyle: const TextStyle(
                            color: AlkostoColors.muted,
                            fontSize: 13.5,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AlkostoColors.muted,
                          ),
                          suffixIcon: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _search,
                            builder: (context, value, _) {
                              if (value.text.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return IconButton(
                                onPressed: _search.clear,
                                icon: const Icon(Icons.close, size: 18),
                              );
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide.none,
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
                  tooltip: 'Mi cuenta',
                  onPressed: () => _go(2),
                  icon: const Icon(Icons.person_outline),
                ),
                IconButton(
                  tooltip: 'Mi carrito',
                  onPressed: () => _go(1),
                  icon: Badge(
                    isLabelVisible: count > 0,
                    backgroundColor: AlkostoColors.orange,
                    label: Text(count > 99 ? '99+' : '$count'),
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                ),
              ],
            )
          : AppBar(
              title: Text(switch (_index) {
                1 => 'Mi carrito',
                2 => 'Mi cuenta',
                _ => 'DesCuento!',
              }),
            ),
      drawer: AppDrawer(
        onHome: () => _go(0),
        onOrders: _openOrders,
        onProfile: () => _go(2),
        onLogout: _logout,
      ),
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(
            searchController: _search,
            onOpenSearch: () => _searchFocus.requestFocus(),
          ),
          CartScreen(onBrowse: () => _go(0)),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _go,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: count > 0,
              backgroundColor: AlkostoColors.orange,
              label: Text('$count'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: count > 0,
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
