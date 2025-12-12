import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/favorites_bloc.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../utils/pokemon_color.dart';
import '../pages/pokemon_details_page.dart';
import 'package:google_fonts/google_fonts.dart';

// Capitalize first letter
String capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    const headerColor = Color.fromARGB(255, 239, 99, 99);

    return Scaffold(
      backgroundColor: headerColor,
      body: Column(
        children: [
          // Red Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 55, 16, 12), // lower header
            color: headerColor,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Text(
                  'Favorites',
                  style: GoogleFonts.exo2(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // White Container with Favorites Grid
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 12,
                  ),
                  child: BlocBuilder<FavoritesBloc, FavoritesState>(
                    builder: (context, state) {
                      if (state.favorites.isEmpty) {
                        return const Center(
                          child: Text('No favorite Pokémon yet'),
                        );
                      }

                      final screenWidth = MediaQuery.of(context).size.width;
                      final cardWidth = (screenWidth - 24) / 2;
                      final cardHeight = cardWidth;

                      return GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: cardWidth / cardHeight,
                        ),
                        itemCount: state.favorites.length,
                        itemBuilder: (context, index) {
                          final pokemon = state.favorites[index];

                          return FutureBuilder<PokemonDetails>(
                            future: PokemonService.fetchPokemonDetails(
                              pokemon.name,
                            ),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Card(
                                  color: Colors.grey[300],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final details = snapshot.data!;
                              final typeColor = details.types.isNotEmpty
                                  ? PokemonColor.fromType(details.types.first)
                                  : Colors.grey;

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PokemonDetailsPage(
                                        name: pokemon.name,
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  color: typeColor.withOpacity(0.8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 6,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Image.network(
                                            details.imageUrl,
                                            height: cardHeight * 0.5,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  capitalize(details.name),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Color.fromARGB(
                                                    255,
                                                    239,
                                                    99,
                                                    99,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: const Text(
                                                        'Remove Favorite?',
                                                      ),
                                                      content: Text(
                                                        'Are you sure you want to remove ${details.name} from favorites?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                              ),
                                                          child: const Text(
                                                            'Cancel',
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                const Color.fromARGB(
                                                                  255,
                                                                  239,
                                                                  99,
                                                                  99,
                                                                ),
                                                          ),
                                                          onPressed: () {
                                                            context
                                                                .read<
                                                                  FavoritesBloc
                                                                >()
                                                                .add(
                                                                  RemoveFavorite(
                                                                    pokemon,
                                                                  ),
                                                                );
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                          child: const Text(
                                                            'Remove',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
