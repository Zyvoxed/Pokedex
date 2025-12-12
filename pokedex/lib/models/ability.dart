class Ability {
  final String name;
  final String effect;
  final String shortEffect;
  final String generation;

  Ability({
    required this.name,
    required this.effect,
    required this.shortEffect,
    required this.generation,
  });

  factory Ability.fromJson(Map<String, dynamic> json) {
    // Get English effect entry
    final effectEntry = (json['effect_entries'] as List).firstWhere(
      (e) => e['language']['name'] == 'en',
      orElse: () => null,
    );

    return Ability(
      name: json['name'],
      effect: effectEntry != null ? effectEntry['effect'] : '',
      shortEffect: effectEntry != null ? effectEntry['short_effect'] : '',
      generation: json['generation']['name'],
    );
  }
}
