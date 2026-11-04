class Pokemon {
  final int id;
  final String name;
  final String imageUrl;

  const Pokemon({required this.id, required this.name, required this.imageUrl});

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final String name = json['name'] as String;
    final String url = json['url'] as String;
    final int id = _extractIdFromUrl(url);
    return Pokemon(
      id: id,
      name: name,
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': 'https://pokeapi.co/api/v2/pokemon/$id/',
    };
  }

  static int _extractIdFromUrl(String url) {
    final segments = url.split('/').where((s) => s.isNotEmpty).toList();
    return int.parse(segments.last);
  }
}

class PokemonListResponse {
  final int count;
  final List<Pokemon> results;

  const PokemonListResponse({required this.count, required this.results});

  factory PokemonListResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawResults = json['results'] as List<dynamic>;
    return PokemonListResponse(
      count: json['count'] as int,
      results: rawResults
          .map((e) => Pokemon.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
