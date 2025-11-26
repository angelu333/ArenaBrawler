enum SpecialAbility {
  rapidFire,      // Disparo rápido
  superShot,      // Disparo poderoso
  heal,           // Curación
  speedBoost,     // Velocidad aumentada
  shield,         // Escudo temporal
  multiShot,      // Disparo múltiple
}

class CharacterModel {
  final String id;
  final String name;
  final String description;
  final String spriteAsset;
  final int price;
  final double baseHealth;
  final double baseSpeed;
  final double attackDamage;
  final double attackCooldownSec;
  final SpecialAbility specialAbility;
  final String specialAbilityName;
  final String specialAbilityDescription;
  final double specialAbilityCooldown; // En segundos
  final int framesPerAnimation;
  final double stepTime;

  const CharacterModel({
    required this.id,
    required this.name,
    required this.description,
    required this.spriteAsset,
    required this.price,
    required this.baseHealth,
    required this.baseSpeed,
    required this.attackDamage,
    required this.attackCooldownSec,
    required this.specialAbility,
    required this.specialAbilityName,
    required this.specialAbilityDescription,
    this.specialAbilityCooldown = 10.0,
    this.framesPerAnimation = 4,
    this.stepTime = 0.15,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      spriteAsset: json['spriteAsset'] as String,
      price: json['price'] as int,
      baseHealth: (json['baseHealth'] as num).toDouble(),
      baseSpeed: (json['baseSpeed'] as num).toDouble(),
      attackDamage: (json['attackDamage'] as num).toDouble(),
      attackCooldownSec: (json['attackCooldownSec'] as num).toDouble(),
      specialAbility: SpecialAbility.values[json['specialAbility'] as int? ?? 0],
      specialAbilityName: json['specialAbilityName'] as String? ?? '',
      specialAbilityDescription: json['specialAbilityDescription'] as String? ?? '',
      specialAbilityCooldown: (json['specialAbilityCooldown'] as num?)?.toDouble() ?? 10.0,
      framesPerAnimation: json['framesPerAnimation'] as int? ?? 4,
      stepTime: (json['stepTime'] as num?)?.toDouble() ?? 0.15,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'spriteAsset': spriteAsset,
      'price': price,
      'baseHealth': baseHealth,
      'baseSpeed': baseSpeed,
      'attackDamage': attackDamage,
      'attackCooldownSec': attackCooldownSec,
      'specialAbility': specialAbility.index,
      'specialAbilityName': specialAbilityName,
      'specialAbilityDescription': specialAbilityDescription,
      'specialAbilityCooldown': specialAbilityCooldown,
      'framesPerAnimation': framesPerAnimation,
      'stepTime': stepTime,
    };
  }
}
