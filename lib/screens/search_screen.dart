import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/auth_gate.dart';
import '../core/feedback.dart';
import '../core/theme.dart';
import '../data/showcase_catalog.dart';
import '../models/catalog_item.dart';
import '../state/cart_controller.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _search;
  final _focus = FocusNode();
  Timer? _debounce;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery.trim();
    _search = TextEditingController(text: widget.initialQuery);
    _search.addListener(_onChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.removeListener(_onChanged);
    _search.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() => _query = _search.text.trim());
    });
  }

  List<CatalogItem> get _results {
    if (_query.isEmpty) return const [];
    return ShowcaseCatalog.search(query: _query);
  }

  void _openProduct(CatalogItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ProductDetailScreen(item: item)),
    );
  }

  Future<void> _quickAdd(CatalogItem item) async {
    final allowed = await ensureAuthenticated(
      context,
      message: 'Inicia sesión o crea una cuenta para agregar productos al carrito.',
    );
    if (!allowed || !mounted) return;
    try {
      await context.read<CartController>().add(
        productId: item.remoteProductId,
        quantity: 1,
      );
      if (!mounted) return;
      showMessage(context, 'Agregaste ${item.name} al carrito');
    } catch (error) {
      if (!mounted) return;
      showApiError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Scaffold(
      backgroundColor: AlkostoColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AlkostoColors.ink,
        iconTheme: const IconThemeData(color: AlkostoColors.ink),
        titleSpacing: 0,
        title: TextField(
          controller: _search,
          focusNode: _focus,
          autofocus: true,
          textInputAction: TextInputAction.search,
          cursorColor: AlkostoColors.orange,
          style: const TextStyle(
            color: AlkostoColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: '¿Qué buscas hoy?',
            hintStyle: const TextStyle(
              color: AlkostoColors.muted,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: AlkostoColors.chip,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            prefixIcon: const Icon(Icons.search, color: AlkostoColors.blue),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _search,
              builder: (context, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  tooltip: 'Limpiar',
                  onPressed: () {
                    _search.clear();
                    setState(() => _query = '');
                    _focus.requestFocus();
                  },
                  icon: const Icon(Icons.close, color: AlkostoColors.muted),
                );
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: AlkostoColors.orange, width: 1.4),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_search.text.trim()),
            child: const Text('Cerrar'),
          ),
        ],
      ),
      body: _query.isEmpty
          ? const _EmptySearchHint()
          : results.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No encontramos resultados para "$_query"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AlkostoColors.muted,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Text(
                    '${results.length} resultado(s) para "$_query"',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AlkostoColors.ink,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.62,
                    ),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      return ProductCard(
                        item: item,
                        onTap: () => _openProduct(item),
                        onAdd: () => _quickAdd(item),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _EmptySearchHint extends StatelessWidget {
  const _EmptySearchHint();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 56, color: AlkostoColors.blue),
            SizedBox(height: 12),
            Text(
              'Escribe para buscar productos',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: AlkostoColors.ink,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Prueba con celular, TV, portátil, hogar...',
              textAlign: TextAlign.center,
              style: TextStyle(color: AlkostoColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
