import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../state/cart_controller.dart';
import '../utils/currency.dart';
import '../widgets/shop_app_bar.dart';

/// Read-only final screen. It is stateless because checkout only presents the
/// cart snapshot and a confirmation message; the router guards access to it.
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({
    super.key,
    required this.cartController,
    required this.orderId,
  });

  final CartController cartController;
  final String orderId;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const BrandMark()),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Padding and purchase rows become more compact on narrow phones.
            final compact = constraints.maxWidth < 360;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 12 : 18,
                    compact ? 20 : 28,
                    compact ? 12 : 18,
                    40,
                  ),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 62,
                        height: 62,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 36,
                          color: colors.onSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text('ORDER CONFIRMED', style: text.displaySmall),
                    const SizedBox(height: 8),
                    Text(
                      'Your pair is secured. Thanks for shopping SOLE/SELECT.',
                      style: text.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ORDER ID: $orderId',
                      key: const Key('order-id'),
                      style: text.labelSmall,
                    ),
                    const SizedBox(height: 30),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(compact ? 12 : 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PURCHASE SUMMARY', style: text.labelLarge),
                            const SizedBox(height: 14),
                            ...cartController.items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: _PurchaseLine(
                                  itemName: item.product.name,
                                  imageAsset: item.product.imageAsset,
                                  productAndSize:
                                      '${item.product.id} · SIZE US ${item.size}',
                                  quantityAndPrice:
                                      '${item.quantity} × ${formatPeso(item.product.price)}',
                                  subtotal: formatPeso(item.subtotal),
                                ),
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Text('TOTAL', style: text.titleMedium),
                                ),
                                Flexible(
                                  child: Text(
                                    formatPeso(cartController.total),
                                    key: const Key('confirmation-total'),
                                    textAlign: TextAlign.end,
                                    style: text.titleLarge,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: () {
                        cartController.clear();
                        context.go('/');
                      },
                      child: const Text('CONTINUE SHOPPING'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PurchaseLine extends StatelessWidget {
  const _PurchaseLine({
    required this.itemName,
    required this.imageAsset,
    required this.productAndSize,
    required this.quantityAndPrice,
    required this.subtotal,
  });

  final String itemName;
  final String imageAsset;
  final String productAndSize;
  final String quantityAndPrice;
  final String subtotal;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        // On very narrow cards, the subtotal moves below the product instead
        // of competing with its image and title for horizontal space.
        final compact = constraints.maxWidth < 330;
        final product = Row(
          children: [
            SizedBox.square(
              dimension: compact ? 50 : 58,
              child: Image.asset(imageAsset, fit: BoxFit.contain),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(itemName, style: text.titleMedium),
                  Text(productAndSize, style: text.bodySmall),
                  Text(quantityAndPrice, style: text.bodySmall),
                ],
              ),
            ),
          ],
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              product,
              const SizedBox(height: 8),
              Text(subtotal, textAlign: TextAlign.end, style: text.labelLarge),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: product),
            const SizedBox(width: 12),
            Text(subtotal, style: text.labelLarge),
          ],
        );
      },
    );
  }
}
