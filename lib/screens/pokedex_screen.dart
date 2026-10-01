import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../theme/emerald_theme.dart';
import '../widgets/dex_header.dart';
import '../widgets/dex_state_panel.dart';
import '../widgets/pokemon_card.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key, this.service});
  final PokemonService? service;

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  late final PokemonService _service;
  late Future<List<Pokemon>> _pokemonFuture;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _query = '';
  bool _sortByName = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? PokemonService();
    // A stable Future: search, sorting, and rebuilds must not refetch the API.
    _pokemonFuture = _service.fetchPokemon();
  }

  void _retry() {
    if (!mounted) return;
    final retryFuture = _service.fetchPokemon();
    setState(() {
      _pokemonFuture = retryFuture;
    });
  }

  void _search(String value) {
    setState(() => _query = value.trim().toLowerCase());
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  void _clearSearch() {
    _searchController.clear();
    _search('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    // Close only the service this screen owns. FutureBuilder manages its own
    // completion callbacks safely when the widget leaves the tree.
    if (widget.service == null) _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width < 600 ? 14 : 32,
              ),
              child: Column(
                children: [
                  const DexHeader(),
                  Expanded(
                    child: Container(
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
                      child: FutureBuilder<List<Pokemon>>(
                        future: _pokemonFuture,
                        builder: (context, snapshot) {
                          final ready =
                              snapshot.connectionState ==
                                  ConnectionState.done &&
                              !snapshot.hasError;
                          final all = ready
                              ? snapshot.data ?? <Pokemon>[]
                              : <Pokemon>[];
                          final visible = all.where((pokemon) {
                            final numberQuery = _query.replaceFirst(
                              RegExp(r'^#'),
                              '',
                            );
                            return pokemon.name.contains(_query) ||
                                pokemon.displayName.toLowerCase().contains(
                                  _query,
                                ) ||
                                pokemon.number.contains(numberQuery);
                          }).toList();
                          if (_sortByName) {
                            visible.sort((a, b) => a.name.compareTo(b.name));
                          }
                          return Column(
                            children: [
                              _toolbar(all.length, ready),
                              Expanded(child: _content(snapshot, all, visible)),
                              _footer(visible.length, all.length, ready),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Text(
                      'Every legend has a story.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: EmeraldTheme.mint.withValues(alpha: .8),
                        fontSize: 10,
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

  Widget _toolbar(int count, bool ready) => Column(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        color: EmeraldTheme.green,
        child: Row(
          children: [
            const Icon(
              Icons.grid_view_rounded,
              size: 18,
              color: EmeraldTheme.paper,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'LEGENDARY INDEX',
                style: EmeraldTheme.pixel(12, color: EmeraldTheme.paper),
              ),
            ),
            Text(
              ready
                  ? '${count.toString().padLeft(2, '0')} ENTRIES'
                  : 'CONNECTING',
              style: const TextStyle(fontSize: 10, color: EmeraldTheme.paper),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _search,
                enabled: ready && count > 0,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Name or number…',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: EmeraldTheme.muted,
                  ),
                  prefixIcon: const Icon(Icons.search, size: 21),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.close, size: 18),
                        ),
                  filled: true,
                  fillColor: const Color(0xFFFAF9EC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 15,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: EmeraldTheme.line, width: 2),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: EmeraldTheme.line, width: 2),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: EmeraldTheme.green, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Tooltip(
              message: _sortByName ? 'Sort by number' : 'Sort by name',
              child: OutlinedButton(
                onPressed: !ready || count == 0
                    ? null
                    : () {
                        setState(() => _sortByName = !_sortByName);
                        if (_scrollController.hasClients) {
                          _scrollController.jumpTo(0);
                        }
                      },
                style: OutlinedButton.styleFrom(
                  shape: const RoundedRectangleBorder(),
                  minimumSize: const Size(76, 50),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  side: const BorderSide(color: EmeraldTheme.line, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.swap_vert, size: 18),
                    const SizedBox(width: 5),
                    Text(
                      _sortByName ? 'A–Z' : 'No.',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _content(
    AsyncSnapshot<List<Pokemon>> snapshot,
    List<Pokemon> all,
    List<Pokemon> visible,
  ) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const DexStatePanel(
        title: 'Opening the Pokédex…',
        message: 'Connecting to the lab. Gathering 30 Legendary Pokémon.',
        loading: true,
      );
    }
    if (snapshot.hasError) {
      final error = snapshot.error;
      return DexStatePanel(
        title: 'Connection interrupted',
        message: error is PokemonServiceException
            ? error.message
            : 'Something went wrong while loading the Pokédex. Please try again.',
        actionLabel: 'TRY AGAIN',
        onAction: _retry,
      );
    }
    if (all.isEmpty) {
      return DexStatePanel(
        title: 'No entries yet',
        message: 'The lab returned no Legendary Pokémon. Try connecting again.',
        actionLabel: 'RELOAD POKÉDEX',
        onAction: _retry,
      );
    }
    if (visible.isEmpty) {
      return DexStatePanel(
        title: 'No Pokémon found',
        message:
            'Try the name or National Pokédex number of a Pokémon in this collection.',
        actionLabel: 'CLEAR SEARCH',
        onAction: _clearSearch,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) => Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: GridView.builder(
          key: const PageStorageKey('pokemon-grid'),
          controller: _scrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 0, 20, 20),
          itemCount: visible.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: (constraints.maxWidth / 175).floor().clamp(2, 5),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: .92,
          ),
          itemBuilder: (context, index) => PokemonCard(
            key: ValueKey(visible[index].id),
            pokemon: visible[index],
          ),
        ),
      ),
    );
  }

  Widget _footer(int count, int total, bool ready) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    decoration: const BoxDecoration(
      color: Color(0xFFE4EBD2),
      border: Border(top: BorderSide(color: EmeraldTheme.line, width: 2)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            ready ? '$count / $total Pokémon' : 'Waiting for data…',
            style: const TextStyle(fontSize: 10),
          ),
        ),
        const Text(
          'DATA: PokéAPI',
          style: TextStyle(fontSize: 10, color: EmeraldTheme.muted),
        ),
      ],
    ),
  );
}
