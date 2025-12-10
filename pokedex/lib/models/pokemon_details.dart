class PokemonDetails {
  final String name;
  final int id;
  final double height;
  final double weight;
  final List<String> types;
  final List<String> abilities;
  final String imageUrl;
  final List<Map<String, dynamic>> stats;
  final List<String> moves;
  final String description;

  // New fields
  final List<String> weaknesses;
  final List<String> strongAgainst;
  final String region;
  final String evYield;
  final String catchRate;
  final String baseFriendship;
  final String baseExp;
  final String growthRate;
  final String genderRatio;
  final String eggCycles;
  final List<String> eggGroups;

  PokemonDetails({
    required this.name,
    required this.id,
    required this.height,
    required this.weight,
    required this.types,
    required this.abilities,
    required this.imageUrl,
    required this.stats,
    required this.moves,
    required this.description,
    required this.weaknesses,
    required this.strongAgainst,
    required this.region,
    required this.evYield,
    required this.catchRate,
    required this.baseFriendship,
    required this.baseExp,
    required this.growthRate,
    required this.genderRatio,
    required this.eggCycles,
    required this.eggGroups,
  });

  factory PokemonDetails.fromJson(
    Map<String, dynamic> pokemonJson,
    String description, {
    required List<String> weaknesses,
    required List<String> strongAgainst,
    required String region,
    required String evYield,
    required String catchRate,
    required String baseFriendship,
    required String baseExp,
    required String growthRate,
    required String genderRatio,
    required String eggCycles,
    required List<String> eggGroups,
  }) {
    // Compute EV Yield string from stats
    final evParts = <String>[];
    for (var s in pokemonJson['stats']) {
      final effort = s['effort'] as int;
      if (effort > 0) {
        final statName = s['stat']['name'];
        final displayName = statName
            .split('-')
            .map((w) => w[0].toUpperCase() + w.substring(1))
            .join(' ');
        evParts.add('$effort $displayName');
      }
    }
    final evYieldString = evParts.isNotEmpty ? evParts.join(', ') : 'None';

    return PokemonDetails(
      name: pokemonJson['name'],
      id: pokemonJson['id'],
      height: (pokemonJson['height'] / 10),
      weight: (pokemonJson['weight'] / 10),
      types: List<String>.from(
        pokemonJson['types'].map((t) => t['type']['name']),
      ),
      abilities: List<String>.from(
        pokemonJson['abilities'].map((a) => a['ability']['name']),
      ),
      imageUrl:
          pokemonJson['sprites']['other']['official-artwork']['front_default'],
      stats: List<Map<String, dynamic>>.from(
        pokemonJson['stats'].map(
          (s) => {
            'name': s['stat']['name'],
            'value': s['base_stat'],
            'effort': s['effort'],
          },
        ),
      ),
      moves: List<String>.from(
        pokemonJson['moves'].map((m) => m['move']['name']),
      ),
      description: description,
      weaknesses: weaknesses,
      strongAgainst: strongAgainst,
      region: region,
      evYield: evYieldString,
      catchRate: catchRate,
      baseFriendship: baseFriendship,
      baseExp: baseExp,
      growthRate: growthRate,
      genderRatio: genderRatio,
      eggCycles: eggCycles,
      eggGroups: eggGroups,
    );
  }
}
