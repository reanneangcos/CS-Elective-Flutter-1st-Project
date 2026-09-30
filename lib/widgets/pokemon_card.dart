import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../theme/emerald_theme.dart';
import 'pokeball.dart';

class PokemonCard extends StatelessWidget {
  const PokemonCard({super.key, required this.pokemon});
  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Number ${pokemon.id}, ${pokemon.displayName}',
    child: ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9E9),
          border: Border.all(color: EmeraldTheme.line, width: 2),
          boxShadow: const [
            BoxShadow(color: Color(0xFFD6DEC4), offset: Offset(3, 3)),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'No. ${pokemon.number}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: EmeraldTheme.muted,
                    ),
                  ),
                  const Pokeball(size: 15, muted: true),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 62,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF0D8),
                        border: Border.all(color: const Color(0xFFDFE7CB)),
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    Image.network(
                      pokemon.imageUrl,
                      width: constraints.maxHeight.clamp(64, 128),
                      height: constraints.maxHeight.clamp(64, 128),
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                      frameBuilder: (context, child, frame, synchronous) =>
                          synchronous || frame != null
                          ? child
                          : const Pokeball(size: 32, muted: true),
                      errorBuilder: (context, error, stack) => const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Pokeball(size: 32, muted: true),
                          SizedBox(height: 4),
                          Text('No image', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 11),
              decoration: const BoxDecoration(
                color: Color(0xFFE4EBD2),
                border: Border(top: BorderSide(color: EmeraldTheme.line)),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  pokemon.displayName.toUpperCase(),
                  style: EmeraldTheme.pixel(13),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
