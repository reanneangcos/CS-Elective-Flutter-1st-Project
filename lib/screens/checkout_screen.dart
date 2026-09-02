import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../state/cart_controller.dart';
import '../utils/currency.dart';
import '../widgets/shop_app_bar.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key, required this.cartController});

  final CartController cartController;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const BrandMark()),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 28, 18, 40),
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
                Text('ORDER SS-2026-0901', style: text.labelSmall),
                const SizedBox(height: 30),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PURCHASE SUMMARY', style: text.labelLarge),
                        const SizedBox(height: 14),
                        ...cartController.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                SizedBox.square(
                                  dimension: 58,
                                  child: Image.asset(
                                    item.product.imageAsset,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: text.titleMedium,
                                      ),
                                      Text(
                                        '${item.quantity} × ${formatPeso(item.product.price)}',
                                        style: text.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  formatPeso(item.subtotal),
                                  style: text.labelLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text('TOTAL', style: text.titleMedium),
                            const Spacer(),
                            Text(
                              formatPeso(cartController.total),
                              key: const Key('confirmation-total'),
                              style: text.titleLarge,
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
        ),
      ),
    );
  }
}
