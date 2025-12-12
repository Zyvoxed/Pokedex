import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../utils/pokemon_color.dart';
import '../bloc/favorites_bloc.dart';

// Capitalize the first letter
String capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

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
    _pokemonDetails = PokemonService.fetchPokemonDetails(widget.name);
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
              Text(
                'Region: ${pokemon.region}',
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
                        label: Text(t),
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
                        label: Text(t),
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
                'Egg Groups: ${pokemon.eggGroups.join(', ')}',
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
                      ability,
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

        // Stats Tab
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: pokemon.stats.map((s) {
              final statName = s['name'] as String;
              final displayName = PokemonColor.displayName(statName);
              final statValue = s['value'] as int;
              final maxValue = 150;
              final barColor = PokemonColor.statColor(statName);

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
                    // Favorite Button
                    Positioned(
                      top: 60,
                      right: 8,
                      child: BlocBuilder<FavoritesBloc, FavoritesState>(
                        builder: (context, state) {
                          final isFavorite = state.favorites.any(
                            (p) =>
                                p.name.toLowerCase() ==
                                pokemon.name.toLowerCase(),
                          );
                          return IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              final bloc = context.read<FavoritesBloc>();
                              final simplePokemon = Pokemon(
                                name: pokemon.name,
                                url:
                                    'https://pokeapi.co/api/v2/pokemon/${pokemon.id}/', // can be any valid URL for ID
                              );

                              if (isFavorite) {
                                bloc.add(RemoveFavorite(simplePokemon));
                              } else {
                                bloc.add(AddFavorite(simplePokemon));
                              }
                            },
                          );
                        },
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
                                Text(
                                  capitalize(pokemon.name),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 33,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 0),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: pokemon.types
                                      .map(
                                        (t) => Chip(
                                          label: Text(t),
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
