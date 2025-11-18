import 'package:flutter/material.dart';
import 'package:juego_happy/screens/character_selection_screen.dart';
import 'package:juego_happy/screens/store_screen.dart';
import 'package:juego_happy/services/game_data_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GameDataService _gameData = GameDataService();
  int _coins = 0;
  String _selectedCharacter = 'default';
  late AnimationController _idleAnimationController;

  @override
  void initState() {
    super.initState();
    _loadGameData();
    _idleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _idleAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadGameData() async {
    final coins = await _gameData.getCoins();
    final character = await _gameData.getSelectedCharacter();
    setState(() {
      _coins = coins;
      _selectedCharacter = character;
    });
  }

  String _getCharacterImage() {
    switch (_selectedCharacter) {
      case 'warrior':
        return 'assets/images/sprites/char_warrior.png';
      case 'mage':
        return 'assets/images/sprites/char_mage.png';
      case 'archer':
        return 'assets/images/sprites/char_archer.png';
      case 'rogue':
        return 'assets/images/sprites/char_rogue.png';
      case 'healer':
        return 'assets/images/sprites/char_healer.png';
      case 'adventurer':
        return 'assets/images/sprites/char_adventurer.png';
      default:
        return 'assets/images/sprites/char_warrior.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo de la arena
          Positioned.fill(
            child: Image.asset(
              'assets/images/lobby_background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
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
                );
              },
            ),
          ),

          // Overlay oscuro para mejor contraste
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.2),
            ),
          ),

          // Personaje en el centro con animación idle
          Center(
            child: AnimatedBuilder(
              animation: _idleAnimationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _idleAnimationController.value * 20 - 10),
                  child: Transform.scale(
                    scale: 1.0 + (_idleAnimationController.value * 0.05),
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyan.withValues(alpha: 0.3),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        _getCharacterImage(),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // UI Superpuesta
          SafeArea(
            child: Column(
              children: [
                // Header superior
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botón de perfil/configuración
                      _CircularIconButton(
                        icon: Icons.person,
                        color: Colors.blue.shade700,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Perfil - Próximamente')),
                          );
                        },
                      ),

                      // Monedas
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade700,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                              color: Colors.amber.shade300, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.monetization_on,
                                color: Colors.white, size: 28),
                            const SizedBox(width: 8),
                            Text(
                              '$_coins',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Botón de notificaciones
                      _CircularIconButton(
                        icon: Icons.notifications,
                        color: Colors.orange.shade700,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sin notificaciones')),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Botones inferiores
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Botón Personajes
                      _LobbyButton(
                        icon: Icons.groups,
                        label: 'PERSONAJES',
                        color: Colors.purple.shade600,
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CharacterSelectionScreen(),
                            ),
                          );
                          _loadGameData();
                        },
                      ),

                      // Botón JUGAR (más grande)
                      _PlayButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CharacterSelectionScreen(),
                            ),
                          );
                          _loadGameData();
                        },
                      ),

                      // Botón Tienda
                      _LobbyButton(
                        icon: Icons.shopping_bag,
                        label: 'TIENDA',
                        color: Colors.green.shade600,
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StoreScreen(),
                            ),
                          );
                          _loadGameData();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Botón circular para iconos en el header
class _CircularIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _CircularIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: color,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}

// Botón de lobby estilo Brawl Stars
class _LobbyButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _LobbyButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: color,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: Container(
                width: 80,
                height: 80,
                alignment: Alignment.center,
                child: Icon(icon, color: Colors.white, size: 40),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.8),
                offset: const Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Botón de JUGAR principal
class _PlayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _PlayButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.shade400,
                Colors.green.shade700,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.6),
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: Container(
                width: 100,
                height: 100,
                alignment: Alignment.center,
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 60),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'JUGAR',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.8),
                offset: const Offset(2, 2),
                blurRadius: 4,
              ),
              Shadow(
                color: Colors.green.withValues(alpha: 0.5),
                offset: const Offset(0, 0),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
