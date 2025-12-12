import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import '../utils/pokemon_color.dart';
import 'home_page.dart';
import 'ability_details_page.dart';
import 'package:google_fonts/google_fonts.dart';

class AbilitiesPage extends StatefulWidget {
  const AbilitiesPage({super.key});

  @override
  State<AbilitiesPage> createState() => _AbilitiesPageState();
}

class _AbilitiesPageState extends State<AbilitiesPage> {
  String selectedType = '';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PokemonProvider>(context);

    // Filter abilities based on type and search query
    final filteredAbilities =
        provider.pokemonList
            .where(
              (p) =>
                  selectedType.isEmpty ||
                  p.types.contains(selectedType.toLowerCase()),
            )
            .expand((p) => p.abilities)
            .toSet()
            .where(
              (ability) =>
                  ability.toLowerCase().contains(searchQuery.toLowerCase()),
            )
            .toList()
          ..sort();

    const headerColor = Color.fromARGB(255, 239, 99, 99);

    return Scaffold(
      backgroundColor: headerColor,
      body: Column(
        children: [
          // Red header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 55, 16, 12),
            color: headerColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button + title
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomePage()),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Abilities',
                      style: GoogleFonts.exo2(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Search bar + filter button inside header
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(10),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search Ability',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () {
                          _showTypeFilterDialog(provider);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.filter_list,
                            color: headerColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // White container with grid
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ), // top & bottom gap
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredAbilities.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2.2,
                        ),
                    itemBuilder: (context, index) {
                      final ability = filteredAbilities[index];

                      final pokemonWithAbility = provider.pokemonList
                          .firstWhere(
                            (p) =>
                                p.abilities.contains(ability) &&
                                (selectedType.isEmpty ||
                                    p.types.contains(
                                      selectedType.toLowerCase(),
                                    )),
                          );
                      final typeColor = pokemonWithAbility.types.isNotEmpty
                          ? PokemonColor.fromType(
                              pokemonWithAbility.types.first,
                            )
                          : Colors.grey;

                      return GestureDetector(
                        onTap: () {
                          final abilityType =
                              pokemonWithAbility.types.isNotEmpty
                              ? pokemonWithAbility.types.first
                              : 'normal';

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AbilityDetailsPage(
                                abilityUrl:
                                    'https://pokeapi.co/api/v2/ability/${ability.toLowerCase()}',
                                type: abilityType,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              ability.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
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

  void _showTypeFilterDialog(PokemonProvider provider) {
    String tempSelectedType = selectedType;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter by Type'),
          content: DropdownButtonFormField<String>(
            value: tempSelectedType.isEmpty ? null : tempSelectedType,
            decoration: const InputDecoration(
              labelText: 'Type',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: '', child: Text('All Types')),
              ...provider.types.map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.toUpperCase()),
                ),
              ),
            ],
            onChanged: (value) {
              tempSelectedType = value ?? '';
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 239, 99, 99),
              ),
              onPressed: () {
                setState(() {
                  selectedType = tempSelectedType;
                });
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}
