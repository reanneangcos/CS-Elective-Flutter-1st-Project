import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/jersey.dart';
import '../providers/shop_provider.dart';
import '../utils/format.dart';
import '../widgets/jersey_art.dart';
import '../widgets/jersey_card.dart' show surname;
import 'jersey_form_sheet.dart';

Future<void> showJerseyDetails(BuildContext context, Jersey jersey) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<ShopProvider>(),
      child: _JerseyDetails(jersey: jersey),
    ),
  );
}

class _JerseyDetails extends StatelessWidget {
  const _JerseyDetails({required this.jersey});
  final Jersey jersey;

  Future<void> _edit(BuildContext context) async {
    final shop = context.read<ShopProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final updated = await showJerseyForm(context, initial: jersey);
    if (updated == null) return;
    try {
      await shop.updateJersey(updated);
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text('Updated ${updated.playerName}')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Update failed: $e')));
    }
  }

  Future<void> _delete(BuildContext context) async {
    final shop = context.read<ShopProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete jersey?'),
        content: Text('${jersey.playerName} (${jersey.edition}) will be removed from the shop.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await shop.deleteJersey(jersey);
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text('Deleted ${jersey.playerName}')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: SizedBox(
              width: 200,
              child: JerseyArt(
                primary: jersey.primary,
                secondary: jersey.secondary,
                number: jersey.number,
                label: surname(jersey.playerName),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(jersey.playerName,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          Text('${jersey.team} · #${jersey.number} · ${jersey.edition} Edition',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(peso(jersey.price),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                  )),
              const Spacer(),
              Text(jersey.stock == 0 ? 'Sold out' : '${jersey.stock} in stock',
                  style: theme.textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _delete(context),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _edit(context),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
