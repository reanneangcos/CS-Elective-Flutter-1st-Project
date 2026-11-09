import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/shop_provider.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final theme = Theme.of(context);
    final disabled = shop.loading;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.outlined(
              tooltip: 'Previous page',
              onPressed: shop.hasPrevious && !disabled ? shop.previousPage : null,
              icon: const Icon(Icons.chevron_left),
            ),
            const SizedBox(width: 4),
            for (final p in _visiblePages(shop.page, shop.totalPages))
              p == null
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text('…'),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _PageButton(
                        label: '${p + 1}',
                        selected: p == shop.page,
                        onTap: disabled ? null : () => shop.goToPage(p),
                      ),
                    ),
            const SizedBox(width: 4),
            IconButton.outlined(
              tooltip: 'Next page',
              onPressed: shop.hasNext && !disabled ? shop.nextPage : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Page ${shop.page + 1} of ${shop.totalPages}',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  /// Up to 5 page numbers around the current page, with first/last and
  /// gaps (null) when there are many pages.
  List<int?> _visiblePages(int current, int total) {
    if (total <= 5) return List.generate(total, (i) => i);
    final pages = <int?>{0, total - 1};
    for (var i = current - 1; i <= current + 1; i++) {
      if (i > 0 && i < total - 1) pages.add(i);
    }
    final sorted = pages.whereType<int>().toList()..sort();
    final result = <int?>[];
    for (var i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i] - sorted[i - 1] > 1) result.add(null);
      result.add(sorted[i]);
    }
    return result;
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(40, 40)),
      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    return selected
        ? FilledButton(style: style, onPressed: onTap, child: Text(label))
        : TextButton(style: style, onPressed: onTap, child: Text(label));
  }
}
