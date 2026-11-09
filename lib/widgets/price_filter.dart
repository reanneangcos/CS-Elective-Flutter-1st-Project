import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/shop_provider.dart';
import '../utils/format.dart';

/// Price range slider. Dragging only updates the labels; the Supabase query
/// runs once the thumb is released (onChangeEnd).
class PriceFilter extends StatelessWidget {
  const PriceFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final theme = Theme.of(context);
    final range = shop.priceRange;
    final steps = ((shop.maxBound - shop.minBound) / ShopProvider.priceStep).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.payments_outlined, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text('Price range', style: theme.textTheme.labelLarge),
            const SizedBox(width: 8),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  '${peso(range.start)} – ${peso(range.end)}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        RangeSlider(
          min: shop.minBound,
          max: shop.maxBound,
          divisions: steps > 0 ? steps : null,
          values: range,
          labels: RangeLabels(peso(range.start), peso(range.end)),
          onChanged: shop.previewPriceRange,
          onChangeEnd: shop.applyPriceRange,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(peso(shop.minBound), style: theme.textTheme.bodySmall),
            Text(peso(shop.maxBound), style: theme.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}
