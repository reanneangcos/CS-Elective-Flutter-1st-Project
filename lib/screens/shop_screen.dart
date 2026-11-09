import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/jersey.dart';
import '../providers/shop_provider.dart';
import '../widgets/jersey_card.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/price_filter.dart';
import 'jersey_detail_sheet.dart';
import 'jersey_form_sheet.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final shop = context.read<ShopProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final jersey = await showJerseyForm(context);
    if (jersey == null) return;
    try {
      await shop.addJersey(jersey);
      messenger.showSnackBar(SnackBar(content: Text('Added ${jersey.playerName}')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not add: $e')));
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.inverseSurface,
        foregroundColor: scheme.onInverseSurface,
        titleSpacing: 16,
        title: const Row(
          children: [
            Icon(Icons.sports_basketball, color: Color(0xFFF97316)),
            SizedBox(width: 10),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('COURTSIDE KITS',
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: context.read<ShopProvider>().refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Add jersey'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 960;
          final filters = _Filters(
            searchController: _searchController,
            onChanged: _scrollToTop,
          );
          final results = _Results(
            scrollController: _scrollController,
            header: wide ? null : filters,
            onPageChanged: _scrollToTop,
          );

          if (!wide) return results;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 320,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: filters,
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: results),
            ],
          );
        },
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.searchController, required this.onChanged});

  final TextEditingController searchController;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: searchController,
          onChanged: (v) {
            shop.setSearch(v);
            onChanged();
          },
          decoration: InputDecoration(
            hintText: 'Search player or team',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchController.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      searchController.clear();
                      shop.setSearch('');
                    },
                  ),
            filled: true,
            fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: const PriceFilter(),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final e in [null, ...Jersey.editions])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(e ?? 'All'),
                    selected: shop.edition == e,
                    onSelected: (_) {
                      shop.setEdition(e);
                      onChanged();
                    },
                  ),
                ),
            ],
          ),
        ),
        if (shop.hasActiveFilters)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                searchController.clear();
                shop.clearFilters();
              },
              icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
              label: const Text('Clear filters'),
            ),
          ),
      ],
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({
    required this.scrollController,
    required this.onPageChanged,
    this.header,
  });

  final ScrollController scrollController;
  final VoidCallback onPageChanged;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final theme = Theme.of(context);

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final columns = width < 600 ? 2 : 3;

      return Stack(
        children: [
          RefreshIndicator(
            onRefresh: shop.refresh,
            child: CustomScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (header != null)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    sliver: SliverToBoxAdapter(child: header),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      shop.totalCount == 0
                          ? (shop.loading ? 'Loading jerseys…' : 'No jerseys found')
                          : 'Showing ${shop.firstShown}–${shop.lastShown} of ${shop.totalCount} jerseys',
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
                if (shop.error != null)
                  SliverToBoxAdapter(child: _ErrorBox(message: shop.error!))
                else if (shop.jerseys.isEmpty && !shop.loading)
                  const SliverToBoxAdapter(child: _EmptyState())
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverOpacity(
                      opacity: shop.loading ? 0.5 : 1,
                      sliver: SliverGrid.builder(
                        itemCount: shop.jerseys.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.66,
                        ),
                        itemBuilder: (context, i) {
                          final jersey = shop.jerseys[i];
                          return JerseyCard(
                            jersey: jersey,
                            onTap: () => showJerseyDetails(context, jersey),
                          );
                        },
                      ),
                    ),
                  ),
                if (shop.totalCount > 0)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
                    sliver: SliverToBoxAdapter(
                      child: _PaginationWithScroll(onPageChanged: onPageChanged),
                    ),
                  ),
              ],
            ),
          ),
          if (shop.loading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(minHeight: 3),
            ),
        ],
      );
    });
  }
}

/// Scrolls back to the top of the grid whenever the page number changes.
class _PaginationWithScroll extends StatefulWidget {
  const _PaginationWithScroll({required this.onPageChanged});
  final VoidCallback onPageChanged;

  @override
  State<_PaginationWithScroll> createState() => _PaginationWithScrollState();
}

class _PaginationWithScrollState extends State<_PaginationWithScroll> {
  int? _lastPage;

  @override
  Widget build(BuildContext context) {
    final page = context.select<ShopProvider, int>((s) => s.page);
    if (_lastPage != null && _lastPage != page) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onPageChanged());
    }
    _lastPage = page;
    return const PaginationBar();
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Column(
        children: [
          Icon(Icons.checkroom_outlined, size: 56, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text('No jerseys match these filters', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Try widening the price range.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Material(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: scheme.onErrorContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(message, style: TextStyle(color: scheme.onErrorContainer)),
              ),
              TextButton(
                onPressed: context.read<ShopProvider>().refresh,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
