import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/feedback.dart';
import '../core/format.dart';
import '../models/cart.dart';
import '../state/cart_controller.dart';
import '../widgets/remote_image.dart';
import '../widgets/submit_button.dart';
import 'order_detail_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final cartController = context.watch<CartController>();
    final cart = cartController.cart;
    final theme = Theme.of(context);

    if (cartController.loading && cart.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cart.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Tu carrito está vacío',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Cuando agregues productos, vas a ver el subtotal, el IVA y el envío aquí.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onBrowse,
                child: const Text('Ver productos'),
              ),
            ],
          ),
        ),
      );
    }

    final summary = cart.summary;
    return Column(
      children: [
        if (cartController.error != null)
          MaterialBanner(
            content: Text(cartController.error!),
            actions: [
              TextButton(
                onPressed: cartController.refresh,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            itemCount: cart.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = cart.items[index];
              final busy = cartController.busyItems.contains(item.id);
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 72,
                          height: 72,
                          child: RemoteImage(url: item.imageUrl),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(formatMoney(item.unitPrice)),
                            Text(
                              'Total: ${formatMoney(item.lineTotal)}',
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: busy || item.quantity <= 1
                                      ? null
                                      : () => _change(
                                          context,
                                          item,
                                          item.quantity - 1,
                                        ),
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                Text('${item.quantity}'),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: busy || item.quantity >= item.stock
                                      ? null
                                      : () => _change(
                                          context,
                                          item,
                                          item.quantity + 1,
                                        ),
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Eliminar',
                        onPressed: busy ? null : () => _remove(context, item),
                        icon: Icon(
                          Icons.delete_outline,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Material(
          elevation: 8,
          color: theme.colorScheme.surface,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  _SummaryRow(
                    label: 'Subtotal',
                    value: formatMoney(summary.subtotal),
                  ),
                  _SummaryRow(
                    label: 'IVA (${formatPercent(summary.taxRate)})',
                    value: formatMoney(summary.tax),
                  ),
                  _SummaryRow(
                    label: 'Envío',
                    value: formatMoney(summary.shipping),
                  ),
                  const Divider(),
                  _SummaryRow(
                    label: 'Total',
                    value: formatMoney(summary.total),
                    emphasize: true,
                  ),
                  const SizedBox(height: 12),
                  SubmitButton(
                    label: 'Proceder al pago',
                    loading: false,
                    onPressed: () => _checkout(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _change(
    BuildContext context,
    CartItem item,
    int quantity,
  ) async {
    try {
      await context.read<CartController>().setQuantity(item, quantity);
    } catch (error) {
      if (context.mounted) showApiError(context, error);
    }
  }

  Future<void> _remove(BuildContext context, CartItem item) async {
    try {
      await context.read<CartController>().remove(item);
    } catch (error) {
      if (context.mounted) showApiError(context, error);
    }
  }

  Future<void> _checkout(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _CheckoutSheet(),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)
        : Theme.of(context).textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _CheckoutSheet extends StatefulWidget {
  const _CheckoutSheet();

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  final _address = TextEditingController();
  String? _payment = 'Tarjeta';
  bool _loading = false;

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    setState(() => _loading = true);
    try {
      final order = await context.read<CartController>().checkout(
        shippingAddress: _address.text,
        paymentMethod: _payment,
      );
      if (!mounted) return;
      final navigator = Navigator.of(context);
      var openDetail = false;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.check_circle_outline),
          title: const Text('Compra realizada'),
          content: Text(
            'Pedido #${order.id} por ${formatMoney(order.total)}. El pago quedó simulado y el carrito se vació.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cerrar'),
            ),
            FilledButton(
              onPressed: () {
                openDetail = true;
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Ver pedido'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      navigator.pop();
      if (openDetail) {
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => OrderDetailScreen(order: order),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      showApiError(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final total = context.watch<CartController>().cart.summary.total;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Simular pago',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text('Total a pagar: ${formatMoney(total)}'),
          const SizedBox(height: 16),
          TextField(
            controller: _address,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 250,
            decoration: const InputDecoration(
              labelText: 'Dirección de envío (opcional)',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 8),
          Text('Método de pago', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final method in const ['Tarjeta', 'PSE', 'Contraentrega'])
                ChoiceChip(
                  label: Text(method),
                  selected: _payment == method,
                  onSelected: (selected) {
                    setState(() => _payment = selected ? method : null);
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          SubmitButton(
            label: 'Confirmar compra',
            loading: _loading,
            onPressed: _confirm,
          ),
        ],
      ),
    );
  }
}
