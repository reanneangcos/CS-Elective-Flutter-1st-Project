import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/cart_item.dart';
import '../state/cart_controller.dart';
import '../utils/currency.dart';
import '../widgets/shop_app_bar.dart';

/// Cart quantities and totals change after user interaction, so this screen is
/// a StatefulWidget that listens to the shared cart controller and rebuilds.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.cartController});

  final CartController cartController;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Listening connects ChangeNotifier state to this StatefulWidget.
    widget.cartController.addListener(_cartChanged);
  }

  @override
  void didUpdateWidget(CartScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cartController != widget.cartController) {
      oldWidget.cartController.removeListener(_cartChanged);
      widget.cartController.addListener(_cartChanged);
    }
  }

  void _cartChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.cartController.removeListener(_cartChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = widget.cartController;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const BrandMark()),
      body: SafeArea(
        child: cart.isEmpty
            ? _EmptyCart(onShop: () => context.go('/'))
            : LayoutBuilder(
                builder: (context, constraints) {
                  // Large screens place the summary beside the list. Phones
                  // keep everything in one scroll view to prevent overflow.
                  final horizontal = constraints.maxWidth >= 900;
                  final pagePadding = constraints.maxWidth < 360 ? 12.0 : 18.0;

                  Widget buildLine(int index) {
                    final item = cart.items[index];
                    return _CartLine(
                      item: item,
                      onIncrease: () => cart.increment(item.lineId),
                      onDecrease: () => cart.decrement(item.lineId),
                      onRemove: () => cart.remove(item.lineId),
                    );
                  }

                  final list = ListView.separated(
                    padding: EdgeInsets.all(pagePadding),
                    itemCount: cart.items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) => buildLine(index),
                  );

                  if (horizontal) {
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1400),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: list),
                            SizedBox(
                              width: 340,
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: _CartSummary(cart: cart),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return CustomScrollView(
                    key: const Key('cart-scroll'),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          pagePadding,
                          22,
                          pagePadding,
                          16,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Text('YOUR CART', style: text.headlineSmall),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: pagePadding),
                        sliver: SliverList.builder(
                          itemCount: cart.items.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: buildLine(index),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          pagePadding,
                          6,
                          pagePadding,
                          24,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: _CartSummary(cart: cart),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _CartLine extends StatelessWidget {
  const _CartLine({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Card(
      key: Key('cart-line-${item.lineId}'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The line's own available width decides whether controls sit beside
          // product details or move onto a second row.
          final compact = constraints.maxWidth < 360;
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.product.name, style: text.titleMedium),
              const SizedBox(height: 3),
              Text(
                '${item.product.id} · SIZE US ${item.size}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 2),
              Text(
                item.product.colorway,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              Text(
                formatPeso(item.subtotal),
                key: Key('subtotal-${item.lineId}'),
                style: text.labelLarge,
              ),
            ],
          );
          final quantity = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _QuantityButton(
                icon: Icons.remove_rounded,
                tooltip: 'Decrease quantity',
                onPressed: onDecrease,
              ),
              SizedBox(
                width: 42,
                child: Text(
                  item.quantity.toString(),
                  key: Key('quantity-${item.lineId}'),
                  textAlign: TextAlign.center,
                  style: text.titleMedium,
                ),
              ),
              _QuantityButton(
                icon: Icons.add_rounded,
                tooltip: 'Increase quantity',
                onPressed: onIncrease,
              ),
            ],
          );
          final image = SizedBox.square(
            dimension: compact ? 72 : 94,
            child: Image.asset(
              item.product.imageAsset,
              fit: BoxFit.contain,
              semanticLabel: '${item.product.name} sneaker',
            ),
          );
          final removeButton = IconButton(
            tooltip: 'Remove item',
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded),
          );

          return Padding(
            padding: const EdgeInsets.all(12),
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          image,
                          const SizedBox(width: 10),
                          Expanded(child: details),
                          removeButton,
                        ],
                      ),
                      const SizedBox(height: 12),
                      quantity,
                    ],
                  )
                : Row(
                    children: [
                      image,
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            details,
                            const SizedBox(height: 10),
                            quantity,
                          ],
                        ),
                      ),
                      removeButton,
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 36,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
        child: Tooltip(message: tooltip, child: Icon(icon, size: 18)),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.cart});

  final CartController cart;

  @override
  Widget build(BuildContext context) {
    // Values are recomputed by CartController and supplied on every cart
    // rebuild, so this display-only section stays stateless.
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ORDER SUMMARY', style: text.labelLarge),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: Text('${cart.totalQuantity} ITEM(S)')),
                Flexible(
                  child: Text(formatPeso(cart.total), textAlign: TextAlign.end),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text('TOTAL', style: text.titleMedium)),
                Flexible(
                  child: Text(
                    formatPeso(cart.total),
                    key: const Key('cart-total'),
                    textAlign: TextAlign.end,
                    style: text.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('checkout-button'),
                onPressed: () {
                  final orderId = cart.beginCheckout();
                  context.go('/checkout/$orderId');
                },
                child: const Text('CHECKOUT'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onShop});

  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 64),
            const SizedBox(height: 18),
            Text(
              'YOUR CART IS EMPTY',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Find a pair worth adding to your rotation.'),
            const SizedBox(height: 24),
            FilledButton(onPressed: onShop, child: const Text('SHOP DROPS')),
          ],
        ),
      ),
    );
  }
}
