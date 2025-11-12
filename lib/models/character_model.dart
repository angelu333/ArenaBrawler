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
    };
  }
}
