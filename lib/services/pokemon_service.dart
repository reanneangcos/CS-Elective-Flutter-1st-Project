import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

class PokemonServiceException implements Exception {
  const PokemonServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}

class PokemonService {
  PokemonService({
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  static const limit = 30;
  static final endpoint = Uri.https('graphql.pokeapi.co', '/v1beta2');

  // Request the first 30 Legendary species in National Pokédex order.
  static const query =
      '''
    query LegendaryPokemon {
      pokemonspecies(
        where: {is_legendary: {_eq: true}}
        order_by: {id: asc}
        limit: $limit
      ) {
        id
        name
        is_legendary
      }
    }
  ''';

  final http.Client _client;
  final Duration timeout;
  List<Pokemon>? _cache;

  /// One HTTP response produces one list, so a Future is the correct abstraction.
  /// Successful results are cached for this service's lifetime.
  Future<List<Pokemon>> fetchPokemon({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) return _cache!;

    try {
      final response = await _client
          .post(
            endpoint,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'query': query}),
          )
          .timeout(timeout);
      if (response.statusCode != 200) {
        throw const PokemonServiceException(
          'The Pokémon lab is unavailable. Please try again.',
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid response.');
      }
      // GraphQL can report a failed query even with an HTTP 200 response.
      final errors = decoded['errors'];
      if (errors != null && (errors is! List || errors.isNotEmpty)) {
        throw const PokemonServiceException(
          'The Legendary archive is unavailable. Please try again.',
        );
      }
      final data = decoded['data'];
      if (data is! Map<String, dynamic> || data['pokemonspecies'] is! List) {
        throw const FormatException('Missing species list.');
      }
      final results = data['pokemonspecies'] as List;
      final pokemon =
          results
              .map((entry) {
                if (entry is! Map<String, dynamic>) {
                  throw const FormatException('Invalid list entry.');
                }
                return Pokemon.fromJson(entry);
              })
              .where((pokemon) => pokemon.isLegendary)
              .toList()
            ..sort((a, b) => a.id.compareTo(b.id));
      // Enforce the cap locally too, even if the API returns extra entries.
      final limited = List<Pokemon>.unmodifiable(pokemon.take(limit));
      // Keep empty responses retryable; cache only a populated list.
      if (limited.isNotEmpty) _cache = limited;
      return limited;
    } on TimeoutException {
      throw const PokemonServiceException(
        'The connection took too long. Please try again.',
      );
    } on http.ClientException {
      throw const PokemonServiceException(
        'Could not reach the Pokémon lab. Check your connection and try again.',
      );
    } on FormatException {
      throw const PokemonServiceException(
        'The lab sent unreadable data. Please try again.',
      );
    }
  }

  void dispose() => _client.close();
}
