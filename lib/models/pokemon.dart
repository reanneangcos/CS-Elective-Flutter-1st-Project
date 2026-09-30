/// A list entry only: this activity intentionally has no detail screen.
class Pokemon {
  const Pokemon({required this.id, required this.name});

  final int id;
  final String name;

  String get number => id.toString().padLeft(3, '0');

  // The list endpoint supplies a resource URL, but no image. Its ID maps to
  // PokéAPI's sprite repository, avoiding 30 additional detail requests.
  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/'
      'sprites/pokemon/versions/generation-iii/emerald/$id.png';

  String get displayName => switch (name) {
    'nidoran-f' => 'Nidoran ♀',
    'nidoran-m' => 'Nidoran ♂',
    _ => name.replaceAll('-', ' '),
  };

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final url = json['url'];
    if (name is! String || name.trim().isEmpty || url is! String) {
      throw const FormatException('Invalid Pokémon list entry.');
    }
    final uri = Uri.tryParse(url);
    final parts = uri?.pathSegments.where((part) => part.isNotEmpty).toList();
    final id = parts == null || parts.isEmpty ? null : int.tryParse(parts.last);
    if (uri?.host != 'pokeapi.co' ||
        parts == null ||
        parts.length != 4 ||
        parts[0] != 'api' ||
        parts[1] != 'v2' ||
        parts[2] != 'pokemon' ||
        id == null ||
        id < 1) {
      throw const FormatException('Invalid Pokémon resource URL.');
    }
    return Pokemon(id: id, name: name.trim());
  }
}
