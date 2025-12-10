import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/pokemon_details.dart';

class PokemonProvider with ChangeNotifier {
  List<PokemonDetails> _pokemonList = [];
  List<PokemonDetails> get pokemonList => _pokemonList;

  int _offset = 0;
  bool _isLoading = false;
  bool _hasNext = true;

  String _searchQuery = '';
  String _selectedType = '';
  String? _selectedRegion;

  List<String> _types = [];
  List<String> get types => _types;

  List<String> _regions = [];
  List<String> get regions => _regions;

  String get searchQuery => _searchQuery;
  String get selectedType => _selectedType;
  String? get selectedRegion => _selectedRegion;

  PokemonProvider() {
    fetchTypes();
    fetchRegions();
  }

  Future<void> fetchPokemon({int limit = 20}) async {
    if (_isLoading || !_hasNext) return;
    _isLoading = true;

    try {
      final response = await http.get(
        Uri.parse(
          'https://pokeapi.co/api/v2/pokemon?offset=$_offset&limit=$limit',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];

        if (results.isEmpty) {
          _hasNext = false;
        } else {
          final futures = results.map((p) async {
            final detailResponse = await http.get(Uri.parse(p['url']));
            if (detailResponse.statusCode == 200) {
              final detailJson = json.decode(detailResponse.body);

              // Fetch species info
              final speciesResponse = await http.get(
                Uri.parse(
                  'https://pokeapi.co/api/v2/pokemon-species/${detailJson['id']}',
                ),
              );

              String description = '';
              String region = '';
              int? catchRate;
              int? baseFriendship;
              String? growthRate;
              String? genderRatio;
              String? eggCycles;
              List<String> eggGroups = [];

              if (speciesResponse.statusCode == 200) {
                final speciesJson = json.decode(speciesResponse.body);

                // Description
                final flavorTextEntries =
                    speciesJson['flavor_text_entries'] as List;
                final englishText = flavorTextEntries.firstWhere(
                  (f) => f['language']['name'] == 'en',
                  orElse: () => null,
                );
                description = englishText != null
                    ? (englishText['flavor_text'] as String).replaceAll(
                        '\n',
                        ' ',
                      )
                    : '';

                // Region
                if (speciesJson['generation'] != null) {
                  final genUrl = speciesJson['generation']['url'];
                  final genResponse = await http.get(Uri.parse(genUrl));
                  if (genResponse.statusCode == 200) {
                    final genJson = json.decode(genResponse.body);
                    region = genJson['main_region']['name'];
                  }
                }

                // Training and Breeding info
                catchRate = speciesJson['capture_rate'];
                baseFriendship = speciesJson['base_happiness'];
                growthRate = speciesJson['growth_rate']['name'];

                // Gender Ratio
                final genderRate = speciesJson['gender_rate'];
                if (genderRate == -1) {
                  genderRatio = 'Genderless';
                } else {
                  final male = (8 - genderRate) * 12.5;
                  final female = genderRate * 12.5;
                  genderRatio =
                      '♂ ${male.toStringAsFixed(1)}% / ♀ ${female.toStringAsFixed(1)}%';
                }

                eggCycles = speciesJson['hatch_counter'] != null
                    ? '${(speciesJson['hatch_counter'] + 1) * 255} steps'
                    : null;

                eggGroups = List<String>.from(
                  speciesJson['egg_groups'].map((e) => e['name']),
                );
              }

              // Weaknesses & Strong Against
              final weaknesses = await _fetchWeaknesses(detailJson);
              final strongAgainst = await _fetchStrongAgainst(detailJson);

              // EV Yield
              final evYield = _getEVYield(detailJson);

              return PokemonDetails.fromJson(
                detailJson,
                description,
                weaknesses: weaknesses,
                strongAgainst: strongAgainst,
                region: region,
                evYield: evYield,
                catchRate: catchRate?.toString() ?? 'N/A',
                baseFriendship: baseFriendship?.toString() ?? 'N/A',
                baseExp: detailJson['base_experience']?.toString() ?? 'N/A',
                growthRate: growthRate ?? 'N/A',
                genderRatio: genderRatio ?? 'N/A',
                eggCycles: eggCycles ?? 'N/A',
                eggGroups: eggGroups,
              );
            }
            return null;
          }).toList();

          final details = await Future.wait(futures);
          _pokemonList.addAll(details.whereType<PokemonDetails>());
          _offset += limit;
          notifyListeners();
        }
      } else {
        throw Exception('Failed to load Pokémon');
      }
    } catch (e) {
      print('Error fetching Pokémon: $e');
    }

    _isLoading = false;
  }

  Future<void> fetchTypes() async {
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/type'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _types = List<String>.from(data['results'].map((t) => t['name']));
      notifyListeners();
    }
  }

  Future<void> fetchRegions() async {
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/region'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _regions = List<String>.from(data['results'].map((r) => r['name']));
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  void selectType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  void selectRegion(String? region) {
    _selectedRegion = region;
    notifyListeners();
  }

  List<PokemonDetails> get filteredPokemon {
    var list = _pokemonList;
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((p) => p.name.toLowerCase().contains(_searchQuery))
          .toList();
    }
    if (_selectedType.isNotEmpty) {
      list = list
          .where((p) => p.types.contains(_selectedType.toLowerCase()))
          .toList();
    }
    if (_selectedRegion != null && _selectedRegion!.isNotEmpty) {
      list = list
          .where(
            (p) => p.region.toLowerCase() == _selectedRegion!.toLowerCase(),
          )
          .toList();
    }
    return list;
  }

  // Helper functions
  Future<List<String>> _fetchWeaknesses(Map detailJson) async {
    List<String> weaknesses = [];
    for (var typeEntry in detailJson['types']) {
      final typeUrl = typeEntry['type']['url'];
      final typeResponse = await http.get(Uri.parse(typeUrl));
      if (typeResponse.statusCode == 200) {
        final typeJson = json.decode(typeResponse.body);
        weaknesses.addAll(
          List<String>.from(
            typeJson['damage_relations']['double_damage_from'].map(
              (t) => t['name'],
            ),
          ),
        );
      }
    }
    return weaknesses.toSet().toList();
  }

  Future<List<String>> _fetchStrongAgainst(Map detailJson) async {
    List<String> strong = [];
    for (var typeEntry in detailJson['types']) {
      final typeUrl = typeEntry['type']['url'];
      final typeResponse = await http.get(Uri.parse(typeUrl));
      if (typeResponse.statusCode == 200) {
        final typeJson = json.decode(typeResponse.body);
        strong.addAll(
          List<String>.from(
            typeJson['damage_relations']['double_damage_to'].map(
              (t) => t['name'],
            ),
          ),
        );
      }
    }
    return strong.toSet().toList();
  }

  String _getEVYield(Map detailJson) {
    final evParts = <String>[];
    for (var s in detailJson['stats']) {
      if (s['effort'] > 0) {
        final statName = s['stat']['name']
            .split('-')
            .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' ');
        evParts.add('${s['effort']} $statName');
      }
    }
    return evParts.isNotEmpty ? evParts.join(', ') : 'None';
  }
}
