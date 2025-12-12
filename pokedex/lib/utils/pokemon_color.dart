import 'package:flutter/material.dart';

class PokemonColor {
  static const Map<String, Color> typeColors = {
    'normal': Color(0xFFA8A77A),
    'fire': Color(0xFFEE8130),
    'water': Color(0xFF6390F0),
    'electric': Color(0xFFF7D02C),
    'grass': Color(0xFF7AC74C),
    'ice': Color(0xFF96D9D6),
    'fighting': Color(0xFFC22E28),
    'poison': Color(0xFFA33EA1),
    'ground': Color(0xFFE2BF65),
    'flying': Color(0xFFA98FF3),
    'psychic': Color(0xFFF95587),
    'bug': Color(0xFFA6B91A),
    'rock': Color(0xFFB6A136),
    'ghost': Color(0xFF735797),
    'dragon': Color(0xFF6F35FC),
    'dark': Color(0xFF705746),
    'steel': Color(0xFFB7B7CE),
    'fairy': Color(0xFFD685AD),
  };

  static Color fromType(String type) {
    return typeColors[type.toLowerCase()] ?? Colors.grey;
  }

  // Returns a darker shade for type chips
  static Color darker(String type, [double amount = 0.1]) {
    final color = fromType(type);
    final hsl = HSLColor.fromColor(color);
    final darkerHsl = hsl.withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    );
    return darkerHsl.toColor();
  }

  // Stat colors
  static const Map<String, Color> statColors = {
    'hp': Colors.red,
    'attack': Colors.orange,
    'defense': Color(0xFFF5E03C),
    'special-attack': Colors.purple,
    'special-defense': Colors.green,
    'speed': Colors.blue,
  };

  static Color statColor(String stat) {
    return statColors[stat.toLowerCase()] ?? Colors.grey;
  }

  // Stat display names
  static const Map<String, String> statDisplayNames = {
    'hp': 'HP',
    'attack': 'Attack',
    'defense': 'Defense',
    'special-attack': 'Sp.Atk',
    'special-defense': 'Sp.Def',
    'speed': 'Speed',
  };

  static String displayName(String stat) {
    return statDisplayNames[stat.toLowerCase()] ?? stat;
  }
}
