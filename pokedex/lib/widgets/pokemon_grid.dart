import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import '../pages/pokemon_details_page.dart';
import '../utils/pokemon_color.dart';

// Capitalize first letter
String capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

class PokemonGrid extends StatelessWidget {
  final ScrollController scrollController;

  const PokemonGrid({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Consumer<PokemonProvider>(
      builder: (context, provider, _) {
        final pokemons = provider.filteredPokemon;

        if (pokemons.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final screenWidth = MediaQuery.of(context).size.width;
        final cardWidth = (screenWidth - 24) / 2; // 2 columns with spacing
        final cardHeight = cardWidth; // square card

        return GridView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: cardWidth / cardHeight, // 1 → square
          ),
          itemCount: pokemons.length,
          itemBuilder: (context, index) {
            final pokemon = pokemons[index];
            final typeColor = pokemon.types.isNotEmpty
                ? PokemonColor.fromType(pokemon.types.first)
                : Colors.grey;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PokemonDetailsPage(name: pokemon.name),
                  ),
                );
              },
              child: Card(
                color: typeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      pokemon.imageUrl,
                      height: cardHeight * 0.5, // half of card height
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      capitalize(pokemon.name),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
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
  }
}
