import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/products.dart';
import '../models/product.dart';
import '../state/cart_controller.dart';
import '../widgets/product_card.dart';
import '../widgets/shop_app_bar.dart';

enum ProductSort { featured, priceLow, priceHigh }

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.cartController,
    required this.onToggleTheme,
  });

  final CartController cartController;
  final VoidCallback onToggleTheme;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _categories = [
    'All',
    'Lifestyle',
    'Performance',
    'Court',
    'Trail',
  ];

  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  ProductSort _sort = ProductSort.featured;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _columnsFor(double width) {
    if (width >= 1100) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  List<Product> get _visibleProducts {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = products.where((product) {
      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      final matchesQuery =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.colorway.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    switch (_sort) {
      case ProductSort.featured:
        return filtered;
      case ProductSort.priceLow:
        return filtered..sort((a, b) => a.price.compareTo(b.price));
      case ProductSort.priceHigh:
        return filtered..sort((a, b) => b.price.compareTo(a.price));
    }
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _selectedCategory = 'All';
      _sort = ProductSort.featured;
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final visibleProducts = _visibleProducts;

    return Scaffold(
      appBar: AppBar(
        title: const BrandMark(),
        actions: [
          ThemeToggleButton(onPressed: widget.onToggleTheme),
          CartIconButton(cartController: widget.cartController),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: colors.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              child: Text(
                'FREE DELIVERY ON ORDERS OVER ₱7,000  •  ORIGINAL CONCEPT PRODUCTS',
                textAlign: TextAlign.center,
                style: text.labelSmall?.copyWith(color: colors.onSecondary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('THE LATEST DROP', style: text.labelSmall),
                  const SizedBox(height: 6),
                  Text(
                    'Find your next pair.',
                    style: text.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Eight independent silhouettes, curated for every rotation.',
                    style: text.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SearchBar(
                    controller: _searchController,
                    hintText: 'Search the catalog',
                    leading: const Icon(Icons.search_rounded),
                    onChanged: (_) => setState(() {}),
                    trailing: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                      PopupMenuButton<ProductSort>(
                        tooltip: 'Sort products',
                        initialValue: _sort,
                        onSelected: (value) => setState(() => _sort = value),
                        icon: const Icon(Icons.swap_vert_rounded),
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: ProductSort.featured,
                            child: Text('Featured'),
                          ),
                          PopupMenuItem(
                            value: ProductSort.priceLow,
                            child: Text('Price: low to high'),
                          ),
                          PopupMenuItem(
                            value: ProductSort.priceHigh,
                            child: Text('Price: high to low'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category.toUpperCase()),
                            selected: _selectedCategory == category,
                            showCheckmark: false,
                            onSelected: (_) =>
                                setState(() => _selectedCategory = category),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Row(
                children: [
                  Text('SHOP ALL', style: text.titleMedium),
                  const Spacer(),
                  Text(
                    '${visibleProducts.length} RESULT${visibleProducts.length == 1 ? '' : 'S'}',
                    style: text.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: visibleProducts.isEmpty
                  ? _NoResults(onClear: _clearFilters)
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = _columnsFor(constraints.maxWidth);
                        final ratio = columns == 2 ? 0.66 : 0.72;
                        return GridView.builder(
                          key: const Key('product-grid'),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                          itemCount: visibleProducts.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: ratio,
                              ),
                          itemBuilder: (context, index) {
                            final product = visibleProducts[index];
                            return ProductCard(
                              product: product,
                              onTap: () =>
                                  context.push('/product/${product.id}'),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 54),
            const SizedBox(height: 14),
            Text(
              'NO PAIRS FOUND',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Try another name, color, or category.'),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: onClear,
              child: const Text('CLEAR FILTERS'),
            ),
          ],
        ),
      ),
    );
  }
}
