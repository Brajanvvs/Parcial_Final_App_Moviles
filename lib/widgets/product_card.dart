import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../models/catalog_item.dart';
import 'remote_image.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onAdd,
    this.horizontal = false,
  });

  final CatalogItem item;
  final VoidCallback onTap;
  final VoidCallback? onAdd;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    return horizontal
        ? _HorizontalCard(item: item, onTap: onTap, onAdd: onAdd)
        : _GridCard(item: item, onTap: onTap);
  }
}

class _GridCard extends StatelessWidget {
  const _GridCard({required this.item, required this.onTap});

  final CatalogItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE6EBF0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
                        child: Hero(
                          tag: 'catalog-${item.id}',
                          child: RemoteImage(url: item.imageUrl),
                        ),
                      ),
                    ),
                    if (item.discountPercent > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _DiscountBadge(percent: item.discountPercent),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.brand,
                      style: const TextStyle(
                        color: AlkostoColors.sky,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        fontSize: 13,
                        color: AlkostoColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (item.discountPercent > 0)
                      Text(
                        formatMoney(item.oldPrice),
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: AlkostoColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    Text(
                      formatMoney(item.price),
                      style: const TextStyle(
                        color: AlkostoColors.orangeDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HorizontalCard extends StatelessWidget {
  const _HorizontalCard({required this.item, required this.onTap, this.onAdd});

  final CatalogItem item;
  final VoidCallback onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 268,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AlkostoColors.orange.withValues(alpha: 0.55),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 108,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(14),
                        ),
                        child: Hero(
                          tag: 'catalog-${item.id}',
                          child: RemoteImage(url: item.imageUrl),
                        ),
                      ),
                      if (item.discountPercent > 0)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: _DiscountBadge(percent: item.discountPercent),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.brand,
                          style: const TextStyle(
                            color: AlkostoColors.sky,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (item.discountPercent > 0)
                          Text(
                            formatMoney(item.oldPrice),
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: AlkostoColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                formatMoney(item.price),
                                style: const TextStyle(
                                  color: AlkostoColors.orangeDark,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (onAdd != null)
                              Material(
                                color: AlkostoColors.orange,
                                borderRadius: BorderRadius.circular(8),
                                child: InkWell(
                                  onTap: onAdd,
                                  borderRadius: BorderRadius.circular(8),
                                  child: const SizedBox(
                                    width: 34,
                                    height: 34,
                                    child: Icon(
                                      Icons.add_shopping_cart,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: AlkostoColors.orange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$percent%',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }
}
