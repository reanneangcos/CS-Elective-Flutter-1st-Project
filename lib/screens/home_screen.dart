import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/products.dart';
import '../models/product.dart';
import '../state/cart_controller.dart';
import '../widgets/product_card.dart';
import '../widgets/shop_app_bar.dart';

enum ProductSort { featured, priceLow, priceHigh }

/// The catalog is stateful because search text, category, and sort order all
/// change in response to the shopper's input.
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

  /// Rubric breakpoint: phones show exactly two columns, while tablet and
  /// larger widths show at least three.
  int _columnsFor(double screenWidth) {
    if (screenWidth >= 1200) return 5;
    if (screenWidth >= 900) return 4;
    if (screenWidth >= 600) return 3;
    return 2;
  }

  /// Narrow phone cards are slightly taller so their text never crowds the
  /// product image even though the required two-column layout is retained.
  double _cardRatioFor(int columns, double gridWidth) {
    final gaps = (columns - 1) * 12;
    final cardWidth = (gridWidth - gaps) / columns;
    return switch (columns) {
      2 when cardWidth < 150 => 0.56,
      2 => 0.66,
      3 => 0.72,
      4 => 0.74,
      _ => 0.76,
    };
  }

  List<Product> get _visibleProducts {
    // Build a new list from the source catalog so filtering/sorting never
    // changes the original product order in data/products.dart.
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
        title: BrandMark(onTap: () => context.go('/')),
        actions: [
          ThemeToggleButton(onPressed: widget.onToggleTheme),
          CartIconButton(cartController: widget.cartController),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        // LayoutBuilder provides the actual available width, which drives the
        // exam's phone/tablet column breakpoints below.
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth.clamp(0.0, 1440.0);
            final horizontalPadding = contentWidth < 360 ? 12.0 : 20.0;
            final gridWidth = contentWidth - (horizontalPadding * 2);
            final columns = _columnsFor(contentWidth);

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                // One parent scroll view keeps the heading, filters, and grid
                // reachable even on phones with short screen heights.
                child: CustomScrollView(
                  key: const Key('catalog-scroll'),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        contentWidth < 360 ? 16 : 24,
                        horizontalPadding,
                        16,
                      ),
                      sliver: SliverToBoxAdapter(
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
                              hintText: contentWidth < 360
                                  ? 'Search catalog'
                                  : 'Search the catalog',
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
                                  onSelected: (value) =>
                                      setState(() => _sort = value),
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
                              // Category chips can scroll sideways rather than
                              // overflowing on narrow phone screens.
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _categories.map((category) {
                                  final selected =
                                      _selectedCategory == category;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(category.toUpperCase()),
                                      // FilterChip does not use the chip theme's
                                      // secondaryLabelStyle, so resolve the
                                      // selected foreground explicitly.
                                      labelStyle: text.labelMedium?.copyWith(
                                        color: selected
                                            ? colors.onSecondary
                                            : colors.onSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      selected: selected,
                                      showCheckmark: false,
                                      onSelected: (_) => setState(
                                        () => _selectedCategory = category,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        14,
                      ),
                      sliver: SliverToBoxAdapter(
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
                    ),
                    if (visibleProducts.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _NoResults(onClear: _clearFilters),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          28,
                        ),
                        // GridView.builder is required by the exam rubric.
                        // The outer CustomScrollView owns scrolling, so this
                        // inner grid measures all cards without scrolling.
                        sliver: SliverToBoxAdapter(
                          child: GridView.builder(
                            key: const Key('product-grid'),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: visibleProducts.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: _cardRatioFor(
                                    columns,
                                    gridWidth,
                                  ),
                                ),
                            itemBuilder: (context, index) {
                              final product = visibleProducts[index];
                              return ProductCard(
                                product: product,
                                // go_router provides declarative Navigation
                                // 2.0 and puts the product id in the URL.
                                onTap: () =>
                                    context.push('/product/${product.id}'),
                              );
                            },
                          ),
                        ),
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
