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
  static final endpoint = Uri.https('pokeapi.co', '/api/v2/pokemon', {
    'limit': '$limit',
    'offset': '0',
  });

  final http.Client _client;
  final Duration timeout;
  List<Pokemon>? _cache;

  /// One HTTP response produces one list, so a Future is the correct abstraction.
  /// Successful results are cached for this service's lifetime.
  Future<List<Pokemon>> fetchPokemon() async {
    if (_cache != null) return _cache!;
    try {
      final response = await _client.get(endpoint).timeout(timeout);
      if (response.statusCode != 200) {
        throw const PokemonServiceException(
          'The Pokémon lab is unavailable. Please try again.',
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['results'] is! List) {
        throw const FormatException('Missing results list.');
      }
      final results = decoded['results'] as List;
      final pokemon = results.take(limit).map((entry) {
        if (entry is! Map<String, dynamic>) {
          throw const FormatException('Invalid list entry.');
        }
        return Pokemon.fromJson(entry);
      }).toList()..sort((a, b) => a.id.compareTo(b.id));
      // Keep empty responses retryable; cache only a populated list.
      if (pokemon.isNotEmpty) _cache = List.unmodifiable(pokemon);
      return List.unmodifiable(pokemon);
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
