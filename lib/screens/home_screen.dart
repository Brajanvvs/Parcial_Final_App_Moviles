import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/auth_gate.dart';
import '../core/feedback.dart';
import '../core/theme.dart';
import '../data/showcase_catalog.dart';
import '../models/catalog_item.dart';
import '../state/cart_controller.dart';
import '../widgets/product_card.dart';
import '../widgets/promo_carousel.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onOpenSearch});

  final VoidCallback? onOpenSearch;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _categoryId;

  void _selectCategory(int? id) {
    setState(() => _categoryId = id);
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

  List<CatalogItem> get _filtered =>
      ShowcaseCatalog.search(categoryId: _categoryId);

  bool get _isFiltering => _categoryId != null;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AlkostoColors.orange,
      onRefresh: () async {
        setState(() {});
        await Future<void>.delayed(const Duration(milliseconds: 350));
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _PromoStrip(onTap: widget.onOpenSearch)),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: PromoCarousel(banners: ShowcaseCatalog.banners),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(
            child: _CategoryGrid(
              selectedCategoryId: _categoryId,
              onSelected: _selectCategory,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(child: _BenefitsBar()),
          if (_isFiltering) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Resultados por categoría',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _categoryId = null),
                      child: const Text('Limpiar'),
                    ),
                  ],
                ),
              ),
            ),
            if (_filtered.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('No encontramos productos.')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.62,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = _filtered[index];
                    return ProductCard(
                      item: item,
                      onTap: () => _openProduct(item),
                    );
                  }, childCount: _filtered.length),
                ),
              ),
          ] else
            for (final section in ShowcaseCatalog.sections)
              SliverToBoxAdapter(
                child: _ProductRail(
                  section: section,
                  products: ShowcaseCatalog.bySection(section.id),
                  onOpen: _openProduct,
                  onAdd: _quickAdd,
                  onSeeAll: () {
                    final first = ShowcaseCatalog.bySection(
                      section.id,
                    ).firstOrNull;
                    if (first != null) _selectCategory(first.categoryId);
                  },
                ),
              ),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }
}

class _PromoStrip extends StatelessWidget {
  const _PromoStrip({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AlkostoColors.promoBar,
      child: InkWell(
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.bolt, color: AlkostoColors.orangeDark, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Black Days · Hasta 50% en tecnología seleccionada',
                  style: TextStyle(
                    color: AlkostoColors.orangeDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AlkostoColors.orangeDark,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final int? selectedCategoryId;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ShowcaseCatalog.tiles.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final tile = ShowcaseCatalog.tiles[index];
          final selected =
              selectedCategoryId != null &&
              selectedCategoryId == tile.categoryId;
          return InkWell(
            onTap: () => onSelected(selected ? null : tile.categoryId),
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 78,
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: selected
                          ? AlkostoColors.blue.withValues(alpha: 0.12)
                          : AlkostoColors.chip,
                      borderRadius: BorderRadius.circular(16),
                      border: selected
                          ? Border.all(color: AlkostoColors.blue, width: 1.5)
                          : null,
                    ),
                    child: Icon(
                      tile.icon,
                      color: selected ? AlkostoColors.blue : AlkostoColors.navy,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tile.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selected ? AlkostoColors.blue : AlkostoColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BenefitsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.local_shipping_outlined, 'Envío gratis'),
      (Icons.replay_outlined, 'Cambios fáciles'),
      (Icons.verified_user_outlined, 'Compra segura'),
      (Icons.credit_card, '0% interés'),
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AlkostoColors.navy,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: Column(
                children: [
                  Icon(item.$1, color: AlkostoColors.orange, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    item.$2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductRail extends StatelessWidget {
  const _ProductRail({
    required this.section,
    required this.products,
    required this.onOpen,
    required this.onAdd,
    required this.onSeeAll,
  });

  final HomeSection section;
  final List<CatalogItem> products;
  final ValueChanged<CatalogItem> onOpen;
  final ValueChanged<CatalogItem> onAdd;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${section.emoji} ${section.title}',
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      color: AlkostoColors.ink,
                    ),
                  ),
                ),
                TextButton(onPressed: onSeeAll, child: const Text('Ver todo')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 168,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = products[index];
                return ProductCard(
                  item: item,
                  horizontal: true,
                  onTap: () => onOpen(item),
                  onAdd: () => onAdd(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
