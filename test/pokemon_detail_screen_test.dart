import 'package:emerald_pokedex/models/pokemon.dart';
import 'package:emerald_pokedex/providers/pokemon_provider.dart';
import 'package:emerald_pokedex/screens/pokemon_detail_screen.dart';
import 'package:emerald_pokedex/services/pokemon_service.dart';
import 'package:emerald_pokedex/theme/emerald_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets(
    'PokemonDetailScreen displays selected pokemon details from provider',
    (tester) async {
      final provider = PokemonProvider(
        service: PokemonService(
          client: MockClient((_) async => http.Response('', 200)),
        ),
      );
      addTearDown(provider.dispose);

      const testPokemon = Pokemon(id: 150, name: 'mewtwo', isLegendary: true);
      provider.selectPokemon(testPokemon);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: MaterialApp(
            theme: EmeraldTheme.theme,
            home: const PokemonDetailScreen(),
          ),
        ),
      );

      expect(find.text('POKÉMON DETAILS'), findsOneWidget);
      expect(find.text('NO. 150'), findsOneWidget);
      expect(find.text('MEWTWO'), findsOneWidget);
      expect(find.text('★ LEGENDARY SPECIES ★'), findsOneWidget);
    },
  );
}
