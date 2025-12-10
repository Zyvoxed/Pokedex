import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_details.dart';

class PokemonService {
  Future<PokemonDetails> fetchPokemonDetails(int id) async {
    // 1) Fetch main Pokémon data
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon/$id'),
    );
    final pokemonJson = json.decode(response.body);

    // Extract description
    final speciesResponse = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon-species/$id'),
    );
    final speciesJson = json.decode(speciesResponse.body);

    String description = '';
    for (var entry in speciesJson['flavor_text_entries']) {
      if (entry['language']['name'] == 'en') {
        description = entry['flavor_text']
            .replaceAll('\n', ' ')
            .replaceAll('\f', ' ');
        break;
      }
    }

    // 2) Fetch species details
    final region = speciesJson['generation']['name']
        .replaceAll('-', ' ')
        .toUpperCase();

    final baseFriendship = speciesJson['base_happiness'].toString();
    final growthRate = speciesJson['growth_rate']['name'];

    // Breeding Info
    final genderRate = speciesJson['gender_rate'];
    String genderRatio = '';

    if (genderRate == -1) {
      genderRatio = "Genderless";
    } else {
      double female = (genderRate / 8) * 100;
      double male = 100 - female;
      genderRatio = "♂ $male% / ♀ $female%";
    }

    final eggCycles = speciesJson['hatch_counter'].toString();
    final eggGroups = List<String>.from(
      speciesJson['egg_groups'].map((g) => g['name']),
    );

    // 3) Fetch training info
    final baseExp = pokemonJson['base_experience'].toString();
    final catchRate = speciesJson['capture_rate'].toString();

    // 4) Weakness & Strength (Type damage relations)
    List<String> weaknesses = [];
    List<String> strongAgainst = [];

    for (var t in pokemonJson['types']) {
      final typeUrl = t['type']['url'];
      final typeRes = await http.get(Uri.parse(typeUrl));
      final typeJson = json.decode(typeRes.body);

      weaknesses.addAll(
        (typeJson['damage_relations']['double_damage_from'] as List).map(
          (e) => e['name'],
        ),
      );

      strongAgainst.addAll(
        (typeJson['damage_relations']['double_damage_to'] as List).map(
          (e) => e['name'],
        ),
      );
    }

    weaknesses = weaknesses.toSet().toList();
    strongAgainst = strongAgainst.toSet().toList();

    return PokemonDetails.fromJson(
      pokemonJson,
      description,
      weaknesses: weaknesses,
      strongAgainst: strongAgainst,
      region: region,
      evYield: "",
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
