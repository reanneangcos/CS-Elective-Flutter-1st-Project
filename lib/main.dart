import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/pokemon_provider.dart';
import 'screens/pokedex_screen.dart';
import 'theme/emerald_theme.dart';

void main() => runApp(
  ChangeNotifierProvider(
    create: (_) => PokemonProvider()..fetchPokemon(),
    child: const EmeraldPokedexApp(),
  ),
);

class EmeraldPokedexApp extends StatelessWidget {
  const EmeraldPokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emerald Pokédex',
      debugShowCheckedModeBanner: false,
      theme: EmeraldTheme.theme,
      home: const PokedexScreen(),
    );
  }
}
