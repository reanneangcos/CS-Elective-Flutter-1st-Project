import 'package:flutter/material.dart';

import '../theme/emerald_theme.dart';
import 'pokeball.dart';

class DexHeader extends StatelessWidget {
  const DexHeader({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 600;
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: compact ? 22 : 32,
          horizontal: 4,
        ),
        child: Row(
          children: [
            Pokeball(size: compact ? 44 : 60),
            SizedBox(width: compact ? 12 : 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'POKÉDEX',
                    style: EmeraldTheme.pixel(
                      compact ? 29 : 42,
                      color: EmeraldTheme.paper,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'EMERALD EDITION',
                    style: EmeraldTheme.pixel(
                      compact ? 10 : 12,
                      color: EmeraldTheme.mint,
                    ),
                  ),
                ],
              ),
            ),
            if (!compact)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        color: const Color(0xFFBCE080),
                      ),
                      const SizedBox(width: 9),
                      const Text(
                        'NATIONAL ARCHIVE',
                        style: TextStyle(
                          color: EmeraldTheme.mint,
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '001 — 030',
                    style: EmeraldTheme.pixel(18, color: EmeraldTheme.paper),
                  ),
                ],
              ),
          ],
        ),
      );
    },
  );
}
