import 'dart:async';
import 'dart:convert';

import 'package:emerald_pokedex/models/pokemon.dart';
import 'package:emerald_pokedex/services/pokemon_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'fixtures/pokemon_fixtures.dart';

void main() {
  test(
    'limits an oversized response to the first 30 Legendary species and caches it',
    () async {
      var calls = 0;
      final service = PokemonService(
        client: MockClient((request) async {
          calls++;
          expect(request.method, 'POST');
          expect(request.url.toString(), 'https://graphql.pokeapi.co/v1beta2');
          expect(request.headers['Content-Type'], 'application/json');
          final query = jsonDecode(request.body)['query'] as String;
          expect(query, contains('is_legendary: {_eq: true}'));
          expect(query, contains('limit: 30'));
          return http.Response(
            fixture([
              ...allLegendaries.reversed,
              entry(1, 'bulbasaur', legendary: false),
              entry(151, 'mew', legendary: false),
            ]),
            200,
          );
        }),
      );
      addTearDown(service.dispose);
      final pokemon = await service.fetchPokemon();
      expect(pokemon, hasLength(30));
      expect(pokemon.first.id, 144);
      expect(pokemon.last.id, 641);
      expect(pokemon.every((pokemon) => pokemon.isLegendary), isTrue);
      expect(
        pokemon.map((pokemon) => pokemon.name),
        containsAll(['mewtwo', 'rayquaza', 'dialga', 'tornadus']),
      );
      expect(pokemon.any((pokemon) => pokemon.id > 641), isFalse);
      expect(() => pokemon.clear(), throwsUnsupportedError);
      expect(await service.fetchPokemon(), pokemon);
      expect(calls, 1);
    },
  );

  test('excludes ordinary and Mythical species from the archive', () async {
    final service = PokemonService(
      client: MockClient(
        (_) async => http.Response(
          fixture([
            entry(1, 'bulbasaur', legendary: false),
            entry(150, 'mewtwo'),
            entry(151, 'mew', legendary: false),
            entry(493, 'arceus', legendary: false),
          ]),
          200,
        ),
      ),
    );
    addTearDown(service.dispose);
    expect((await service.fetchPokemon()).map((pokemon) => pokemon.name), [
      'mewtwo',
    ]);
  });

  test('an empty result stays retryable', () async {
    var calls = 0;
    final service = PokemonService(
      client: MockClient(
        (_) async => http.Response(
          fixture(++calls == 1 ? [] : [entry(150, 'mewtwo')]),
          200,
        ),
      ),
    );
    addTearDown(service.dispose);
    expect(await service.fetchPokemon(), isEmpty);
    expect(await service.fetchPokemon(), hasLength(1));
    expect(calls, 2);
  });

  for (final failure in [
    http.Response('unavailable', 503),
    http.Response('rate limited', 429),
    http.Response(
      jsonEncode({
        'errors': [
          {'message': 'Query failed'},
        ],
        'data': {
          'pokemonspecies': [entry(150, 'mewtwo')],
        },
      }),
      200,
    ),
  ]) {
    test(
      'HTTP or GraphQL failure can recover without caching partial data: ${failure.statusCode} ${failure.body}',
      () async {
        var calls = 0;
        final service = PokemonService(
          client: MockClient(
            (_) async => ++calls == 1 ? failure : http.Response(fixture(), 200),
          ),
        );
        addTearDown(service.dispose);
        await expectLater(
          service.fetchPokemon(),
          throwsA(isA<PokemonServiceException>()),
        );
        expect(await service.fetchPokemon(), hasLength(3));
        expect(calls, 2);
      },
    );
  }

  for (final body in [
    'not json',
    '[]',
    '{}',
    '{"data":null}',
    '{"data":{"pokemonspecies":{}}}',
    '{"data":{"pokemonspecies":[null]}}',
    fixture([
      {'id': 150, 'name': 42, 'is_legendary': true},
    ]),
    fixture([
      {'id': 0, 'name': 'mewtwo', 'is_legendary': true},
    ]),
    fixture([
      {'id': '150', 'name': 'mewtwo', 'is_legendary': true},
    ]),
    fixture([
      {'id': 150, 'name': ' ', 'is_legendary': true},
    ]),
    fixture([
      {'id': 150, 'name': 'mewtwo'},
    ]),
    fixture([
      {'id': 150, 'name': 'mewtwo', 'is_legendary': 'true'},
    ]),
  ]) {
    test('malformed payload becomes a readable error: $body', () async {
      final service = PokemonService(
        client: MockClient((_) async => http.Response(body, 200)),
      );
      addTearDown(service.dispose);
      await expectLater(
        service.fetchPokemon(),
        throwsA(
          isA<PokemonServiceException>().having(
            (e) => e.message,
            'message',
            contains('unreadable'),
          ),
        ),
      );
    });
  }

  test('network failures become a connection message', () async {
    final service = PokemonService(
      client: MockClient(
        (_) async => throw http.ClientException('network down'),
      ),
    );
    addTearDown(service.dispose);
    await expectLater(
      service.fetchPokemon(),
      throwsA(
        isA<PokemonServiceException>().having(
          (e) => e.message,
          'message',
          contains('connection'),
        ),
      ),
    );
  });

  test('slow requests time out with a retryable message', () async {
    final pending = Completer<http.Response>();
    final service = PokemonService(
      timeout: const Duration(milliseconds: 1),
      client: MockClient((_) => pending.future),
    );
    addTearDown(service.dispose);
    await expectLater(
      service.fetchPokemon(),
      throwsA(
        isA<PokemonServiceException>().having(
          (e) => e.message,
          'message',
          contains('too long'),
        ),
      ),
    );
    pending.complete(http.Response(fixture([]), 200));
  });

  test('models use sprites from the correct generation and preserve IDs', () {
    final rayquaza = Pokemon.fromJson(entry(384, 'rayquaza'));
    final terapagos = Pokemon.fromJson(entry(1024, 'terapagos'));
    expect(rayquaza.number, '384');
    expect(rayquaza.imageUrl, endsWith('/generation-iii/emerald/384.png'));
    expect(terapagos.number, '1024');
    expect(terapagos.imageUrl, endsWith('/sprites/pokemon/1024.png'));
    expect(Pokemon.fromJson(entry(250, 'ho-oh')).displayName, 'Ho-Oh');
    expect(Pokemon.fromJson(entry(772, 'type-null')).displayName, 'Type: Null');
    expect(Pokemon.fromJson(entry(785, 'tapu-koko')).displayName, 'tapu koko');
  });
}
