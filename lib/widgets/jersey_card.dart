import 'package:flutter/material.dart';

import '../models/jersey.dart';
import '../utils/format.dart';
import 'jersey_art.dart';

String surname(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  return parts.isEmpty ? '' : parts.last;
}

class JerseyCard extends StatelessWidget {
  const JerseyCard({super.key, required this.jersey, required this.onTap});

  final Jersey jersey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      jersey.secondary.withValues(alpha: 0.18),
                      jersey.primary.withValues(alpha: 0.10),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: JerseyArt(
                        primary: jersey.primary,
                        secondary: jersey.secondary,
                        number: jersey.number,
                        label: surname(jersey.playerName),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: _Tag(text: jersey.edition.toUpperCase()),
                    ),
                    if (jersey.stock <= 5)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: _Tag(
                          text: jersey.stock == 0 ? 'SOLD OUT' : 'ONLY ${jersey.stock} LEFT',
                          color: scheme.error,
                          textColor: scheme.onError,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jersey.playerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    jersey.team,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    peso(jersey.price),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, this.color, this.textColor});

  final String text;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color ?? scheme.inverseSurface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: textColor ?? scheme.onInverseSurface,
        ),
      ),
    );
  }
}
