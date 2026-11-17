import 'package:flutter/material.dart';

import '../core/format.dart';
import '../models/order.dart';
import '../widgets/remote_image.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Pedido #${order.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.status,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(formatDate(order.createdAt)),
                  if ((order.shippingAddress ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Envío: ${order.shippingAddress}'),
                  ],
                  if ((order.paymentMethod ?? '').isNotEmpty)
                    Text('Pago: ${order.paymentMethod}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final item in order.items) ...[
            Card(
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: RemoteImage(url: item.imageUrl),
                  ),
                ),
                title: Text(item.productName),
                subtitle: Text(
                  '${item.quantity} × ${formatMoney(item.unitPrice)}',
                ),
                trailing: Text(formatMoney(item.lineTotal)),
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          _Line(label: 'Subtotal', value: formatMoney(order.subtotal)),
          _Line(label: 'IVA', value: formatMoney(order.tax)),
          _Line(label: 'Envío', value: formatMoney(order.shipping)),
          const Divider(),
          _Line(
            label: 'Total',
            value: formatMoney(order.total),
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
