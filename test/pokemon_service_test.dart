import 'dart:async';
import 'dart:convert';

import 'package:emerald_pokedex/models/pokemon.dart';
import 'package:emerald_pokedex/services/pokemon_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, dynamic> entry(int id, [String name = 'bulbasaur']) => {
  'name': name,
  'url': 'https://pokeapi.co/api/v2/pokemon/$id/',
};

void main() {
  test(
    'loads at most 30 entries, orders IDs, and caches the successful list',
    () async {
      var calls = 0;
      final service = PokemonService(
        client: MockClient((request) async {
          calls++;
          expect(request.url.host, 'pokeapi.co');
          expect(request.url.path, '/api/v2/pokemon');
          expect(request.url.queryParameters, {'limit': '30', 'offset': '0'});
          return http.Response(
            jsonEncode({'results': List.generate(35, (i) => entry(i + 1))}),
            200,
          );
        }),
      );
      addTearDown(service.dispose);
      final pokemon = await service.fetchPokemon();
      expect(pokemon, hasLength(30));
      expect(pokemon.first.id, 1);
      expect(pokemon.last.id, 30);
      expect(pokemon.first.imageUrl, endsWith('/generation-iii/emerald/1.png'));
      expect(await service.fetchPokemon(), pokemon);
      expect(calls, 1);
    },
  );

  test('an empty result stays retryable', () async {
    var calls = 0;
    final service = PokemonService(
      client: MockClient((_) async {
        calls++;
        return http.Response(
          jsonEncode({
            'results': calls == 1 ? [] : [entry(1)],
          }),
          200,
        );
      }),
    );
    addTearDown(service.dispose);
    expect(await service.fetchPokemon(), isEmpty);
    expect(await service.fetchPokemon(), hasLength(1));
    expect(calls, 2);
  });

  test('a failed request can recover on retry', () async {
    var calls = 0;
    final service = PokemonService(
      client: MockClient((_) async {
        return ++calls == 1
            ? http.Response('unavailable', 503)
            : http.Response(
                jsonEncode({
                  'results': [entry(1)],
                }),
                200,
              );
      }),
    );
    addTearDown(service.dispose);
    await expectLater(
      service.fetchPokemon(),
      throwsA(isA<PokemonServiceException>()),
    );
    expect(await service.fetchPokemon(), hasLength(1));
  });

  for (final body in [
    'not json',
    '{}',
    '{"results":{}}',
    '{"results":[{"name":42}]}',
    '{"results":[{"name":"bulbasaur","url":"bad"}]}',
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
    pending.complete(http.Response('{"results":[]}', 200));
  });

  test('model preserves ID and formats Nidoran for display', () {
    final pokemon = Pokemon.fromJson(entry(29, 'nidoran-f'));
    expect(pokemon.number, '029');
    expect(pokemon.displayName, 'Nidoran ♀');
  });
}
