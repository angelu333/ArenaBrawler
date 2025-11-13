import 'package:flutter/material.dart';
import 'package:juego_happy/screens/character_selection_screen.dart';
import 'package:juego_happy/screens/store_screen.dart';
import 'package:juego_happy/services/game_data_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GameDataService _gameData = GameDataService();
  int _coins = 0;

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    final coins = await _gameData.getCoins();
    setState(() {
      _coins = coins;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade900,
              Colors.blue.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header con monedas
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade700,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.monetization_on, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            '$_coins',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Título del juego
              const Text(
                'ARENA BRAWLER',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(3, 3),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // Botón Jugar
              _MenuButton(
                text: 'JUGAR',
                icon: Icons.play_arrow,
                color: Colors.green,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CharacterSelectionScreen(),
                    ),
                  );
                  _loadCoins(); // Recargar monedas al volver
                },
              ),

              const SizedBox(height: 20),

              // Botón Tienda
              _MenuButton(
                text: 'TIENDA',
                icon: Icons.shopping_cart,
                color: Colors.orange,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StoreScreen(),
                    ),
                  );
                  _loadCoins(); // Recargar monedas al volver
                },
              ),

              const SizedBox(height: 20),

              // Botón Configuración (placeholder)
              _MenuButton(
                text: 'CONFIGURACIÓN',
                icon: Icons.settings,
                color: Colors.blue,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Próximamente...')),
                  );
                },
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
