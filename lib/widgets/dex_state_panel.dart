import 'package:flutter/material.dart';

import '../theme/emerald_theme.dart';
import 'pokeball.dart';

class DexStatePanel extends StatelessWidget {
  const DexStatePanel({
    super.key,
    required this.title,
    required this.message,
    this.loading = false,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final bool loading;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxHeight < 350;
      return Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(compact ? 16 : 28),
          child: Semantics(
            liveRegion: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Pokeball(size: compact ? 32 : 54),
                SizedBox(height: compact ? 12 : 24),
                Text(
                  title,
                  style: EmeraldTheme.pixel(compact ? 15 : 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: compact ? 12 : 13, height: 1.6),
                  ),
                ),
                if (loading) ...[
                  const SizedBox(height: 28),
                  const SizedBox(
                    width: 150,
                    child: LinearProgressIndicator(
                      minHeight: 6,
                      color: EmeraldTheme.green,
                      backgroundColor: EmeraldTheme.line,
                      semanticsLabel: 'Loading Pokémon',
                    ),
                  ),
                ],
                if (onAction != null) ...[
                  SizedBox(height: compact ? 12 : 24),
                  FilledButton(onPressed: onAction, child: Text(actionLabel!)),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}
