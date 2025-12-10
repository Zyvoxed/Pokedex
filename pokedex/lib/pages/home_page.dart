import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/pokemon_grid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
              // Type selection
              DropdownButtonFormField<String>(
                value: selectedType.isEmpty ? null : selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  filled: false,
                  labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: const Color.fromARGB(255, 239, 99, 99),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: const Color.fromARGB(255, 239, 99, 99),
                    ),
                  ),
                ),
                dropdownColor: const Color.fromARGB(255, 255, 255, 255),
                style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
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
              // Region selection
              DropdownButtonFormField<String>(
                value: selectedRegion.isEmpty ? null : selectedRegion,
                decoration: const InputDecoration(
                  labelText: 'Region',
                  filled: false,
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: const Color.fromARGB(255, 239, 99, 99),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: const Color.fromARGB(255, 239, 99, 99),
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
    return Scaffold(
      body: Column(
        children: [
          // Top title & search
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pokédex Lite',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                                fillColor: Colors.grey[200],
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
                                color: const Color.fromARGB(255, 239, 99, 99),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.filter_list),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Body: Pokémon Grid
          Expanded(child: PokemonGrid(scrollController: _scrollController)),
        ],
      ),
    );
  }
}
