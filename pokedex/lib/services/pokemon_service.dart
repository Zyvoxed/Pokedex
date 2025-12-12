import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';
import '../utils/text_utils.dart';

class PokemonService {
  static Future<PokemonDetails> fetchPokemonDetails(String name) async {
    // Fetch basic Pokémon data
    final pokemonResponse = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon/$name'),
    );

    if (pokemonResponse.statusCode != 200) {
      throw Exception('Failed to load Pokémon');
    }

    final pokemonJson = json.decode(pokemonResponse.body);

    // Fetch species info for description, region, breeding, and training
    final speciesResponse = await http.get(
      Uri.parse(
        'https://pokeapi.co/api/v2/pokemon-species/${pokemonJson['id']}',
      ),
    );

    String description = '';
    String region = '';
    String evYield = '';
    String catchRate = '';
    String baseFriendship = '';
    String baseExp = '';
    String growthRate = '';
    String genderRatio = '';
    String eggCycles = '';
    List<String> eggGroups = [];

    if (speciesResponse.statusCode == 200) {
      final speciesJson = json.decode(speciesResponse.body);

      // Description
      final flavorTextEntries = speciesJson['flavor_text_entries'] as List;
      final englishText = flavorTextEntries.firstWhere(
        (f) => f['language']['name'] == 'en',
        orElse: () => null,
      );
      description = englishText != null
          ? (englishText['flavor_text'] as String).replaceAll('\n', ' ')
          : '';

      // Region from generation
      if (speciesJson['generation'] != null) {
        final genUrl = speciesJson['generation']['url'];
        final genResponse = await http.get(Uri.parse(genUrl));
        if (genResponse.statusCode == 200) {
          final genJson = json.decode(genResponse.body);
          region = genJson['main_region']['name'];
        }
      }

      // Training info
      evYield =
          (pokemonJson['stats'] != null && pokemonJson['stats'].isNotEmpty)
          ? speciesJson['base_happiness'].toString()
          : 'N/A';
      catchRate = speciesJson['capture_rate']?.toString() ?? 'N/A';
      baseFriendship = speciesJson['base_happiness']?.toString() ?? 'N/A';
      baseExp = pokemonJson['base_experience']?.toString() ?? 'N/A';
      growthRate = speciesJson['growth_rate'] != null
          ? capitalize(speciesJson['growth_rate']['name'])
          : 'N/A';

      // Breeding info
      if (speciesJson['gender_rate'] != null) {
        int rate = speciesJson['gender_rate'];
        if (rate == -1) {
          genderRatio = 'Genderless';
        } else {
          double malePercent = (8 - rate) / 8 * 100;
          double femalePercent = rate / 8 * 100;
          genderRatio =
              'Male: ${malePercent.toStringAsFixed(1)}%, Female: ${femalePercent.toStringAsFixed(1)}%';
        }
      }

      eggCycles = speciesJson['hatch_counter'] != null
          ? ((speciesJson['hatch_counter'] + 1) * 255 / 60).toStringAsFixed(0)
          : 'N/A';

      if (speciesJson['egg_groups'] != null) {
        eggGroups = (speciesJson['egg_groups'] as List<dynamic>)
            .map<String>((e) => e['name'].toString())
            .toList();
      }
    }

    // Weaknesses / Strong Against
    List<String> weaknesses = [];
    List<String> strongAgainst = [];

    for (var typeEntry in pokemonJson['types']) {
      final typeUrl = typeEntry['type']['url'];
      final typeResponse = await http.get(Uri.parse(typeUrl));
      if (typeResponse.statusCode == 200) {
        final typeJson = json.decode(typeResponse.body);
        final damageRelations = typeJson['damage_relations'];

        weaknesses.addAll(
          List<String>.from(
            damageRelations['double_damage_from'].map((t) => t['name']),
          ),
        );

        strongAgainst.addAll(
          List<String>.from(
            damageRelations['double_damage_to'].map((t) => t['name']),
          ),
        );
      }
    }

    weaknesses = weaknesses.toSet().toList();
    strongAgainst = strongAgainst.toSet().toList();

    return PokemonDetails.fromJson(
      pokemonJson,
      description,
      weaknesses: weaknesses,
      strongAgainst: strongAgainst,
      region: region,
      evYield: evYield,
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
