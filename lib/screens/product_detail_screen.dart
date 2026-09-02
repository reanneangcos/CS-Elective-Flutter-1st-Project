import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/product.dart';
import '../state/cart_controller.dart';
import '../utils/currency.dart';
import '../widgets/shop_app_bar.dart';

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
  bool _added = false;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.product.sizes.first;
  }

  void _addToCart() {
    widget.cartController.add(widget.product);
    setState(() => _added = true);
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
            if (constraints.maxWidth >= 760) {
              return Padding(
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
                          added: _added,
                          onSizeSelected: (size) =>
                              setState(() => _selectedSize = size),
                          onAdd: _addToCart,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: _ProductImage(product: widget.product),
                ),
                const SizedBox(height: 28),
                _ProductInformation(
                  product: widget.product,
                  selectedSize: _selectedSize,
                  added: _added,
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
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.all(24),
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
    required this.added,
    required this.onSizeSelected,
    required this.onAdd,
  });

  final Product product;
  final int selectedSize;
  final bool added;
  final ValueChanged<int> onSizeSelected;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${product.releaseLabel} · ${product.category}'.toUpperCase(),
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
            onPressed: added ? () => context.push('/cart') : onAdd,
            icon: Icon(added ? Icons.shopping_bag_outlined : Icons.add_rounded),
            label: Text(added ? 'VIEW CART' : 'ADD TO CART'),
          ),
        ),
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
