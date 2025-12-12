import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/pokemon_grid.dart';
import '../pages/home_page.dart';
import 'package:google_fonts/google_fonts.dart';

class Pokedex extends StatefulWidget {
  const Pokedex({super.key});

  @override
  State<Pokedex> createState() => _PokedexState();
}

class _PokedexState extends State<Pokedex> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PokemonProvider>(context, listen: false);
    provider.fetchPokemon();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        provider.fetchPokemon();
      }
    });
  }

  void _showFilterDialog(PokemonProvider provider) {
    String selectedType = provider.selectedType;
    String selectedRegion = provider.selectedRegion ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Center(
            child: Text(
              'Filter Pokémon',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedType.isEmpty ? null : selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  filled: false,
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 239, 99, 99),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 239, 99, 99),
                    ),
                  ),
                ),
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black),
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
                  selectedType = value ?? '';
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRegion.isEmpty ? null : selectedRegion,
                decoration: const InputDecoration(
                  labelText: 'Region',
                  filled: false,
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 239, 99, 99),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 239, 99, 99),
                    ),
                  ),
                ),
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black),
                items: [
                  const DropdownMenuItem(value: '', child: Text('All Regions')),
                  ...provider.regions.map(
                    (region) => DropdownMenuItem(
                      value: region,
                      child: Text(region.toUpperCase()),
                    ),
                  ),
                ],
                onChanged: (value) {
                  selectedRegion = value ?? '';
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 239, 99, 99),
              ),
              onPressed: () {
                provider.selectType(selectedType);
                provider.selectRegion(selectedRegion);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const headerColor = Color.fromARGB(255, 239, 99, 99);

    return Scaffold(
      backgroundColor: headerColor,
      body: Column(
        children: [
          // Shorter Red Header
          Container(
            padding: const EdgeInsets.fromLTRB(
              16,
              55,
              16,
              12,
            ), // Reduced padding
            color: headerColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      'Pokédex',
                      style: GoogleFonts.exo2(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12), // Reduced spacing
                Consumer<PokemonProvider>(
                  builder: (context, provider, _) => Row(
                    children: [
                      Expanded(
                        child: Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(10),
                          child: TextField(
                            onChanged: provider.search,
                            decoration: InputDecoration(
                              hintText: 'Search Pokémon',
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
                          onTap: () => _showFilterDialog(provider),
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
                ),
              ],
            ),
          ),

          // White Container with Pokemon Grid
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: PokemonGrid(scrollController: _scrollController),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
