import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/product.dart';
import '../state/cart_controller.dart';
import '../utils/currency.dart';
import '../widgets/shop_app_bar.dart';

/// Stateful because the selected size and add/view-cart button change after
/// user interaction. The product itself remains immutable.
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.cartController,
  });

  final Product product;
  final CartController cartController;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late int _selectedSize;
  int? _lastAddedSize;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.product.sizes.first;
  }

  void _addToCart() {
    // Updating the shared controller also updates the badge, cart, and total.
    widget.cartController.add(widget.product, _selectedSize);
    setState(() => _lastAddedSize = _selectedSize);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${widget.product.name}, size $_selectedSize added to your cart.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BrandMark(),
        actions: [
          CartIconButton(cartController: widget.cartController),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Tablets use a side-by-side composition; phones stack the image
            // and information in a vertically scrollable list.
            if (constraints.maxWidth >= 760) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _ProductImage(product: widget.product)),
                        const SizedBox(width: 40),
                        Expanded(
                          child: SingleChildScrollView(
                            child: _ProductInformation(
                              product: widget.product,
                              selectedSize: _selectedSize,
                              lastAddedSize: _lastAddedSize,
                              onSizeSelected: (size) =>
                                  setState(() => _selectedSize = size),
                              onAdd: _addToCart,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final pagePadding = constraints.maxWidth < 360 ? 12.0 : 18.0;
            return ListView(
              padding: EdgeInsets.fromLTRB(
                pagePadding,
                pagePadding,
                pagePadding,
                32,
              ),
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: _ProductImage(product: widget.product),
                ),
                SizedBox(height: constraints.maxWidth < 360 ? 20 : 28),
                _ProductInformation(
                  product: widget.product,
                  selectedSize: _selectedSize,
                  lastAddedSize: _lastAddedSize,
                  onSizeSelected: (size) =>
                      setState(() => _selectedSize = size),
                  onAdd: _addToCart,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    // Card and Image are explicit rubric widgets. Hero animates the matching
    // catalog image into this larger detail image during navigation.
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Padding(
          padding: EdgeInsets.all(
            MediaQuery.sizeOf(context).width < 360 ? 14 : 24,
          ),
          child: Hero(
            tag: 'product-${product.id}',
            child: Image.asset(
              product.imageAsset,
              fit: BoxFit.contain,
              semanticLabel: '${product.name} sneaker',
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductInformation extends StatelessWidget {
  const _ProductInformation({
    required this.product,
    required this.selectedSize,
    required this.lastAddedSize,
    required this.onSizeSelected,
    required this.onAdd,
  });

  final Product product;
  final int selectedSize;
  final int? lastAddedSize;
  final ValueChanged<int> onSizeSelected;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    // This section is stateless: the parent owns changing values and passes
    // both data and callbacks down as constructor parameters.
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${product.releaseLabel} · ${product.category}'.toUpperCase(),
          style: text.labelSmall?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 5),
        Text(
          'PRODUCT ID: ${product.id}',
          key: const Key('product-id'),
          style: text.labelSmall?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Text(product.name, style: text.displaySmall),
        const SizedBox(height: 8),
        Text(
          product.colorway,
          style: text.titleMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 18),
        Text(formatPeso(product.price), style: text.headlineSmall),
        const SizedBox(height: 28),
        Text(product.description, style: text.bodyLarge),
        const SizedBox(height: 28),
        Row(
          children: [
            Text('SELECT SIZE', style: text.labelLarge),
            const Spacer(),
            Text('US MEN', style: text.labelSmall),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          // Wrap moves size chips to another line on narrow screens.
          spacing: 8,
          runSpacing: 8,
          children: product.sizes.map((size) {
            final selected = size == selectedSize;
            return ChoiceChip(
              label: Text(size.toString()),
              selected: selected,
              onSelected: (_) => onSizeSelected(size),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            key: const Key('add-to-cart'),
            // The action stays available after an addition so the shopper can
            // select another size of the same product and add a separate line.
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('ADD TO CART'),
          ),
        ),
        if (lastAddedSize != null) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const Key('view-cart'),
              onPressed: () => context.push('/cart'),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: Text('VIEW CART · SIZE $lastAddedSize ADDED'),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.verified_outlined, color: colors.secondary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Original concept product · Quality checked',
                style: text.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _ProductFacts(product: product),
      ],
    );
  }
}

class _ProductFacts extends StatelessWidget {
  const _ProductFacts({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ExpansionTile(
            leading: const Icon(Icons.layers_outlined),
            title: const Text('MATERIALS & BUILD'),
            childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(product.materials),
              ),
            ],
          ),
          const Divider(height: 1),
          ExpansionTile(
            leading: const Icon(Icons.straighten_rounded),
            title: const Text('FIT & SIZING'),
            childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(product.fitNote),
              ),
            ],
          ),
          const Divider(height: 1),
          const ListTile(
            leading: Icon(Icons.local_shipping_outlined),
            title: Text('DELIVERY'),
            subtitle: Text('Free over ₱7,000 · Estimated 2–4 business days'),
          ),
        ],
      ),
    );
  }
}
