import 'package:flutter/material.dart';

import '../models/product.dart';
import '../utils/currency.dart';

/// Static product information never changes, so each catalog card is a
/// StatelessWidget. Interaction only asks the router to open the detail page.
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Pulling values from ThemeData keeps the card correct in both light and
    // dark mode without hardcoded screen-level colors.
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // The parent supplies navigation behavior; this reusable widget only
        // presents one product and reports taps.
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ColoredBox(
                      color: colors.surfaceContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Hero(
                          tag: 'product-${product.id}',
                          child: Image.asset(
                            product.imageAsset,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            semanticLabel: '${product.name} sneaker',
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        child: Text(
                          product.releaseLabel.toUpperCase(),
                          style: text.labelSmall?.copyWith(fontSize: 9),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 12, 13, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${product.category.toUpperCase()} · ${product.id}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.colorway,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(formatPeso(product.price), style: text.labelLarge),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
