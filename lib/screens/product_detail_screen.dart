import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/feedback.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../models/catalog_item.dart';
import '../state/cart_controller.dart';
import '../widgets/remote_image.dart';
import '../widgets/submit_button.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.item});

  final CatalogItem item;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late int _quantity = 1;
  bool _adding = false;

  CatalogItem get item => widget.item;

  Future<void> _add() async {
    if (!item.inStock) return;
    setState(() => _adding = true);
    try {
      await context.read<CartController>().add(
        productId: item.remoteProductId,
        quantity: _quantity,
      );
      if (!mounted) return;
      showMessage(context, 'Agregaste ${item.name} al carrito');
    } catch (error) {
      if (!mounted) return;
      showApiError(context, error);
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(item.brand)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                AspectRatio(
                  aspectRatio: 1.05,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'catalog-${item.id}',
                        child: RemoteImage(url: item.imageUrl),
                      ),
                      if (item.discountPercent > 0)
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AlkostoColors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '-${item.discountPercent}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.categoryName.toUpperCase(),
                        style: const TextStyle(
                          color: AlkostoColors.sky,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AlkostoColors.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.brand,
                        style: const TextStyle(
                          color: AlkostoColors.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (item.discountPercent > 0)
                        Text(
                          formatMoney(item.oldPrice),
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: AlkostoColors.muted,
                            fontSize: 15,
                          ),
                        ),
                      Text(
                        formatMoney(item.price),
                        style: const TextStyle(
                          color: AlkostoColors.orangeDark,
                          fontWeight: FontWeight.w900,
                          fontSize: 30,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AlkostoColors.promoBar,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Paga a cuotas · Envío a todo el país',
                          style: TextStyle(
                            color: AlkostoColors.orangeDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(item.description, style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 10),
                      Text(
                        item.inStock ? 'Disponibles: ${item.stock}' : 'Agotado',
                        style: TextStyle(
                          color: item.inStock
                              ? AlkostoColors.muted
                              : theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Cantidad',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton.filledTonal(
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                            icon: const Icon(Icons.remove),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '$_quantity',
                              style: theme.textTheme.titleLarge,
                            ),
                          ),
                          IconButton.filledTonal(
                            onPressed: _quantity < item.stock
                                ? () => setState(() => _quantity++)
                                : null,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SubmitButton(
                label: 'Agregar al carrito',
                loading: _adding,
                onPressed: item.inStock ? _add : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
