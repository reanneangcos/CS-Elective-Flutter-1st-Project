import 'package:flutter/foundation.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';

class PokemonProvider extends ChangeNotifier {
  PokemonProvider({PokemonService? service})
    : _service = service ?? PokemonService();

  final PokemonService _service;

  List<Pokemon> _pokemonList = [];
  bool _isLoading = false;
  String? _errorMessage;
  Pokemon? _selectedPokemon;

  List<Pokemon> get pokemonList => List.unmodifiable(_pokemonList);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Pokemon? get selectedPokemon => _selectedPokemon;
  bool get hasError => _errorMessage != null;
  bool get isEmpty =>
      !_isLoading && _errorMessage == null && _pokemonList.isEmpty;

  void selectPokemon(Pokemon? pokemon) {
    _selectedPokemon = pokemon;
    notifyListeners();
  }

  Future<void> fetchPokemon({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _service.fetchPokemon(forceRefresh: forceRefresh);
      _pokemonList = results;
      _errorMessage = null;
    } on PokemonServiceException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isDisposed = false;

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _service.dispose();
    super.dispose();
  }
}
