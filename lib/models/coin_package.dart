import 'package:flutter/material.dart';

class CoinPackage {
  final String id;
  final String name;
  final String description;
  final int coins;
  final int price; // Precio en pesos
  final IconData icon;
  final Color color;
  final String? imagePath; // Ruta opcional de imagen

  const CoinPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.coins,
    required this.price,
    required this.icon,
    required this.color,
    this.imagePath,
  });

  static final List<CoinPackage> packages = [
    const CoinPackage(
      id: 'small_bag',
      name: 'Bolsa de Monedas',
      description: 'Una pequeña bolsa con monedas',
      coins: 100,
      price: 50,
      icon: Icons.shopping_bag,
      color: Colors.brown,
      imagePath: 'coins/coin_icon.png',
    ),
    const CoinPackage(
      id: 'medium_pouch',
      name: 'Bolsa Grande',
      description: 'Una bolsa más grande llena de monedas',
      coins: 250,
      price: 100,
      icon: Icons.work,
      color: Colors.grey,
      imagePath: 'coins/coin_icon.png',
    ),
    const CoinPackage(
      id: 'small_chest',
      name: 'Cofre de Monedas',
      description: 'Un cofre pequeño repleto de monedas',
      coins: 500,
      price: 200,
      icon: Icons.inventory_2,
      color: Colors.blue,
      imagePath: 'coins/coin_icon.png',
    ),
    const CoinPackage(
      id: 'large_chest',
      name: 'Cofre Grande',
      description: 'Un cofre grande con muchas monedas',
      coins: 1000,
      price: 350,
      icon: Icons.inventory,
      color: Colors.purple,
      imagePath: 'coins/coin_icon.png',
    ),
    const CoinPackage(
      id: 'treasure_chest',
      name: 'Cofre del Tesoro',
      description: 'Un cofre legendario lleno de riquezas',
      coins: 2500,
      price: 800,
      icon: Icons.diamond,
      color: Colors.amber,
      imagePath: 'coins/coin_icon.png',
    ),
    const CoinPackage(
      id: 'mega_vault',
      name: 'Bóveda Mega',
      description: 'La máxima cantidad de monedas',
      coins: 5000,
      price: 2000,
      icon: Icons.account_balance,
      color: Colors.red,
      imagePath: 'coins/coin_icon.png',
    ),
  ];
}
