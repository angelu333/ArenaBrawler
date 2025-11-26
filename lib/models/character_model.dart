enum SpecialAbility {
  rapidFire, // Disparo rápido
  superShot, // Disparo poderoso
  heal, // Curación
  speedBoost, // Velocidad aumentada
  shield, // Escudo temporal
  multiShot, // Disparo múltiple
}

class CharacterModel {
  final String id;
  final String name;
  final String description;
  final String spriteAsset;
  final String profileAsset; // Imagen de perfil (no spritesheet)
  final int price;
  final double baseHealth;
  final double baseSpeed;
  final double attackDamage;
  final double attackCooldownSec;
  final SpecialAbility specialAbility;
  final String specialAbilityName;
  final String specialAbilityDescription;
  final double specialAbilityCooldown; // En segundos

  const CharacterModel({
    required this.id,
    required this.name,
    required this.description,
    required this.spriteAsset,
    required this.profileAsset,
    required this.price,
    required this.baseHealth,
    required this.baseSpeed,
    required this.attackDamage,
    required this.attackCooldownSec,
    required this.specialAbility,
    required this.specialAbilityName,
    required this.specialAbilityDescription,
    this.specialAbilityCooldown = 10.0,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      spriteAsset: json['spriteAsset'] as String,
      profileAsset:
          json['profileAsset'] as String? ?? 'sprites/char_${json['id']}.png',
      price: json['price'] as int,
      baseHealth: (json['baseHealth'] as num).toDouble(),
      baseSpeed: (json['baseSpeed'] as num).toDouble(),
      attackDamage: (json['attackDamage'] as num).toDouble(),
      attackCooldownSec: (json['attackCooldownSec'] as num).toDouble(),
      specialAbility:
          SpecialAbility.values[json['specialAbility'] as int? ?? 0],
      specialAbilityName: json['specialAbilityName'] as String? ?? '',
      specialAbilityDescription:
          json['specialAbilityDescription'] as String? ?? '',
      specialAbilityCooldown:
          (json['specialAbilityCooldown'] as num?)?.toDouble() ?? 10.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'spriteAsset': spriteAsset,
      'profileAsset': profileAsset,
      'price': price,
      'baseHealth': baseHealth,
      'baseSpeed': baseSpeed,
      'attackDamage': attackDamage,
      'attackCooldownSec': attackCooldownSec,
      'specialAbility': specialAbility.index,
      'specialAbilityName': specialAbilityName,
      'specialAbilityDescription': specialAbilityDescription,
      'specialAbilityCooldown': specialAbilityCooldown,
    };
  }
}
