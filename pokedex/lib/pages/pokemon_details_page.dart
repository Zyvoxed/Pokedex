import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/pokemon_details.dart';
import '../utils/pokemon_color.dart';

// Capitalize first letter
String capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

// Define color mapping for stats
Map<String, Color> statColors = {
  'hp': Colors.red,
  'attack': Colors.orange,
  'defense': Colors.yellow.shade700,
  'special-attack': Colors.purple,
  'special-defense': Colors.green,
  'speed': Colors.blue,
};

// Abbreviated stat display names
final Map<String, String> statDisplayNames = {
  'hp': 'HP',
  'attack': 'Attack',
  'defense': 'Defense',
  'special-attack': 'Sp.Atk',
  'special-defense': 'Sp.Def',
  'speed': 'Speed',
};

class PokemonDetailsPage extends StatefulWidget {
  final String name;

  const PokemonDetailsPage({super.key, required this.name});

  @override
  State<PokemonDetailsPage> createState() => _PokemonDetailsPageState();
}

class _PokemonDetailsPageState extends State<PokemonDetailsPage>
    with SingleTickerProviderStateMixin {
  late Future<PokemonDetails> _pokemonDetails;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pokemonDetails = fetchPokemonDetails(widget.name);
  }

  Future<PokemonDetails> fetchPokemonDetails(String name) async {
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
          ? speciesJson['base_happiness']
                .toString() // Placeholder, will calculate EVs later
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
        eggGroups = List<String>.from(
          speciesJson['egg_groups'].map((e) => e['name']),
        );
      }
    }

    // Compute Weaknesses and Strong Against based on types
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

  Widget buildTabContent(PokemonDetails pokemon) {
    return TabBarView(
      controller: _tabController,
      children: [
        // About Tab
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                pokemon.description,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16),

              // Region, Height & Weight
              Text(
                'Region: ${capitalize(pokemon.region)}',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                'Height: ${pokemon.height} m',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                'Weight: ${pokemon.weight} kg',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 50),

              // Weaknesses
              const Text(
                'Weaknesses',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: pokemon.weaknesses
                    .map(
                      (t) => Chip(
                        label: Text(capitalize(t)),
                        backgroundColor: PokemonColor.fromType(
                          t,
                        ).withOpacity(0.8),
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),

              // Strong Against
              const Text(
                'Strong Against',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: pokemon.strongAgainst
                    .map(
                      (t) => Chip(
                        label: Text(capitalize(t)),
                        backgroundColor: PokemonColor.fromType(
                          t,
                        ).withOpacity(0.8),
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 50),

              // Training Info
              const Text(
                'Training',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'EV Yield: ${pokemon.evYield}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Catch Rate: ${pokemon.catchRate}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Base Friendship: ${pokemon.baseFriendship}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Base Exp: ${pokemon.baseExp}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Growth Rate: ${pokemon.growthRate}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Breeding Info
              const Text(
                'Breeding',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Gender Ratio: ${pokemon.genderRatio}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Egg Cycles: ${pokemon.eggCycles}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Egg Groups: ${pokemon.eggGroups.map(capitalize).join(', ')}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),

        // Abilities Tab
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3,
            ),
            itemCount: pokemon.abilities.length,
            itemBuilder: (context, index) {
              final ability = pokemon.abilities[index];
              return Card(
                color: PokemonColor.fromType(
                  pokemon.types.first,
                ).withOpacity(0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      capitalize(ability),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Stats Tab with colored bars
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: pokemon.stats.map((s) {
              final statName = s['name'] as String;
              final displayName =
                  statDisplayNames[statName.toLowerCase()] ??
                  capitalize(statName);
              final statValue = s['value'] as int;
              final maxValue = 150; // max stat for scaling
              final barColor =
                  statColors[statName.toLowerCase()] ?? Colors.grey;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    SizedBox(width: 100, child: Text(displayName)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: statValue / maxValue,
                          minHeight: 10,
                          backgroundColor: Colors.grey[300],
                          color: barColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('$statValue'),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return FutureBuilder<PokemonDetails>(
      future: _pokemonDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final pokemon = snapshot.data!;
        final bgColor = PokemonColor.fromType(pokemon.types.first);

        return Scaffold(
          backgroundColor: bgColor,
          body: Column(
            children: [
              Container(
                height: screenHeight * 0.5,
                color: bgColor,
                child: Stack(
                  children: [
                    Positioned(
                      top: 55,
                      left: 8,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Positioned(
                      top: 110,
                      left: 16,
                      right: 16,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name
                                Text(
                                  capitalize(pokemon.name),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 33,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 0),
                                // Type Chips
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: pokemon.types
                                      .map(
                                        (t) => Chip(
                                          label: Text(capitalize(t)),
                                          backgroundColor:
                                              PokemonColor.fromType(
                                                t,
                                              ).withOpacity(0.8),
                                          labelStyle: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                          // Pokémon number aligned with the name baseline
                          Baseline(
                            baseline: 42,
                            baselineType: TextBaseline.alphabetic,
                            child: Text(
                              '#${pokemon.id.toString().padLeft(3, '0')}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: screenHeight * 0.27,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 195,
                              width: 195,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.15),
                              ),
                            ),
                            Image.network(
                              pokemon.imageUrl,
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: screenHeight * 0.5,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(width: 3.0, color: bgColor),
                        insets: const EdgeInsets.symmetric(horizontal: 70),
                      ),
                      tabs: const [
                        Tab(text: 'About'),
                        Tab(text: 'Abilities'),
                        Tab(text: 'Stats'),
                      ],
                    ),
                    Expanded(child: buildTabContent(pokemon)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
