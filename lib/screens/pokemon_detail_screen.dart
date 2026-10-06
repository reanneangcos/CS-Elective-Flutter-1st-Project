import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pokemon_provider.dart';
import '../theme/emerald_theme.dart';
import '../widgets/pokeball.dart';

class PokemonDetailScreen extends StatelessWidget {
  const PokemonDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PokemonProvider>();
    final pokemon = provider.selectedPokemon;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1D5540), EmeraldTheme.forest, Color(0xFF0D302B)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Header / Back navigation
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: EmeraldTheme.paper,
                            foregroundColor: EmeraldTheme.line,
                            side: const BorderSide(
                              color: EmeraldTheme.line,
                              width: 2,
                            ),
                            shape: const RoundedRectangleBorder(),
                          ),
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: Text('BACK', style: EmeraldTheme.pixel(11)),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'POKÉMON DETAILS',
                          style: EmeraldTheme.pixel(
                            14,
                            color: EmeraldTheme.mint,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: EmeraldTheme.paper,
                          border: Border.all(
                            color: const Color(0xFF0A2A23),
                            width: 3,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF0A2A23),
                              offset: Offset(6, 6),
                            ),
                          ],
                        ),
                        child: pokemon == null
                            ? Center(
                                child: Text(
                                  'No Pokémon selected.',
                                  style: EmeraldTheme.pixel(12),
                                ),
                              )
                            : Column(
                                children: [
                                  // Top bar
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    color: EmeraldTheme.green,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'NO. ${pokemon.number}',
                                          style: EmeraldTheme.pixel(
                                            13,
                                            color: EmeraldTheme.paper,
                                          ),
                                        ),
                                        const Pokeball(size: 20),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Image view
                                  Expanded(
                                    child: Center(
                                      child: Container(
                                        width: 220,
                                        height: 220,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEAF0D8),
                                          border: Border.all(
                                            color: const Color(0xFFDFE7CB),
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            110,
                                          ),
                                        ),
                                        child: Image.network(
                                          pokemon.imageUrl,
                                          fit: BoxFit.contain,
                                          filterQuality: FilterQuality.none,
                                          frameBuilder:
                                              (
                                                context,
                                                child,
                                                frame,
                                                synchronous,
                                              ) => synchronous || frame != null
                                              ? child
                                              : const Center(
                                                  child: Pokeball(
                                                    size: 48,
                                                    muted: true,
                                                  ),
                                                ),
                                          errorBuilder:
                                              (
                                                context,
                                                error,
                                                stackTrace,
                                              ) => const Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Pokeball(
                                                    size: 48,
                                                    muted: true,
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'No Image Available',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Name section
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE4EBD2),
                                      border: Border(
                                        top: BorderSide(
                                          color: EmeraldTheme.line,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          pokemon.displayName.toUpperCase(),
                                          style: EmeraldTheme.pixel(18),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          pokemon.isLegendary
                                              ? '★ LEGENDARY SPECIES ★'
                                              : 'SPECIES ENTRY',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: EmeraldTheme.muted,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
