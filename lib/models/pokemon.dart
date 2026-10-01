/// One species in the archive, with its National Pokédex number.
class Pokemon {
  const Pokemon({
    required this.id,
    required this.name,
    required this.isLegendary,
  });

  final int id;
  final String name;
  final bool isLegendary;

  String get number => id.toString().padLeft(3, '0');

  // Preserve Emerald sprites for its generations, then use the general
  // sprite collection for newer species. Each species appears once.
  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/'
      'sprites/pokemon/${id <= 386 ? 'versions/generation-iii/emerald/' : ''}$id.png';

  String get displayName => switch (name) {
    'ho-oh' => 'Ho-Oh',
    'type-null' => 'Type: Null',
    _ => name.replaceAll('-', ' '),
  };

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final id = json['id'];
    final isLegendary = json['is_legendary'];
    if (name is! String ||
        name.trim().isEmpty ||
        id is! int ||
        id < 1 ||
        isLegendary is! bool) {
      throw const FormatException('Invalid Pokémon species.');
    }
    return Pokemon(id: id, name: name.trim(), isLegendary: isLegendary);
  }
}
