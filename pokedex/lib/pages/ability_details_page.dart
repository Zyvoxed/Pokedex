import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/ability.dart';
import '../utils/pokemon_color.dart';
import 'package:google_fonts/google_fonts.dart';

class AbilityDetailsPage extends StatefulWidget {
  final String abilityUrl;
  final String type;

  const AbilityDetailsPage({
    super.key,
    required this.abilityUrl,
    required this.type,
  });

  @override
  State<AbilityDetailsPage> createState() => _AbilityDetailsPageState();
}

class _AbilityDetailsPageState extends State<AbilityDetailsPage> {
  Ability? ability;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAbilityDetails();
  }

  Future<void> fetchAbilityDetails() async {
    try {
      final response = await http.get(Uri.parse(widget.abilityUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          ability = Ability.fromJson(data);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load ability details');
      }
    } catch (e) {
      print('Error fetching ability: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = PokemonColor.fromType(widget.type);

    return Scaffold(
      backgroundColor: typeColor,
      appBar: AppBar(
        backgroundColor: typeColor,
        elevation: 0,
        title: Text(
          ability?.name.toUpperCase() ?? "LOADING...",
          style: GoogleFonts.exo2(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ability == null
          ? const Center(
              child: Text(
                'Failed to load ability details',
                style: TextStyle(fontSize: 16),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ⭐ TYPE CHIP BELOW TITLE
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      label: Text(
                        widget.type.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      backgroundColor: PokemonColor.fromType(
                        widget.type,
                      ).withOpacity(0.85),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // White rounded container
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 30,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // EFFECT
                          const Text(
                            "Effect",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ability!.effect,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                          const SizedBox(height: 28),

                          // SHORT EFFECT
                          const Text(
                            "Short Effect",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ability!.shortEffect,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                          const SizedBox(height: 28),

                          // GENERATION
                          const Text(
                            "Generation",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ability!.generation.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
