import 'package:emerald_pokedex/models/pokemon.dart';
import 'package:emerald_pokedex/providers/pokemon_provider.dart';
import 'package:emerald_pokedex/services/pokemon_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'fixtures/pokemon_fixtures.dart';

void main() {
  group('PokemonProvider', () {
    test('initial state is correct', () {
      final provider = PokemonProvider(
        service: PokemonService(
          client: MockClient((_) async => http.Response(fixture(), 200)),
        ),
      );
      addTearDown(provider.dispose);

      expect(provider.pokemonList, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.selectedPokemon, isNull);
      expect(provider.hasError, isFalse);
    });

    test(
      'fetchPokemon updates loading, pokemonList, and error state on success',
      () async {
        final provider = PokemonProvider(
          service: PokemonService(
            client: MockClient((_) async => http.Response(fixture(), 200)),
          ),
        );
        addTearDown(provider.dispose);

        final future = provider.fetchPokemon();
        expect(provider.isLoading, isTrue);

        await future;

        expect(provider.isLoading, isFalse);
        expect(provider.hasError, isFalse);
        expect(provider.pokemonList.length, 3);
        expect(provider.pokemonList.first.name, 'mewtwo');
      },
    );

    test('fetchPokemon handles error response correctly', () async {
      final provider = PokemonProvider(
        service: PokemonService(
          client: MockClient((_) async => http.Response('', 500)),
        ),
      );
      addTearDown(provider.dispose);

      await provider.fetchPokemon();

      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isTrue);
      expect(provider.errorMessage, isNotNull);
      expect(provider.pokemonList, isEmpty);
    });

    test('selectPokemon updates selectedPokemon state', () {
      final provider = PokemonProvider(
        service: PokemonService(
          client: MockClient((_) async => http.Response(fixture(), 200)),
        ),
      );
      addTearDown(provider.dispose);

      const testPokemon = Pokemon(id: 150, name: 'mewtwo', isLegendary: true);
      provider.selectPokemon(testPokemon);

      expect(provider.selectedPokemon, equals(testPokemon));
    });
  });
}
