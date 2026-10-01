import 'dart:convert';
import 'dart:io';

Map<String, dynamic> entry(int id, String name, {bool legendary = true}) => {
  'id': id,
  'name': name,
  'is_legendary': legendary,
};

String fixture([List<Map<String, dynamic>>? species]) => jsonEncode({
  'data': {
    'pokemonspecies':
        species ??
        [entry(150, 'mewtwo'), entry(249, 'lugia'), entry(384, 'rayquaza')],
  },
});

// Snapshot of the live PokéAPI query, retained for deterministic offline tests.
final allLegendaries =
    (jsonDecode(
              File('test/fixtures/legendary_species.json').readAsStringSync(),
            )['data']['pokemonspecies']
            as List)
        .cast<Map<String, dynamic>>();
