import 'dart:math';
import 'package:flutter/material.dart';
import 'package:juego_happy/screens/character_selection_screen.dart';
import 'package:juego_happy/screens/level_map_screen.dart';
import 'package:juego_happy/screens/store_screen.dart';
import 'package:juego_happy/services/game_data_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GameDataService _gameData = GameDataService();
  int _coins = 0;
  final int _gems = 50;
  String _selectedCharacter = 'default';

  late AnimationController _breatheController;
  late AnimationController _particlesController;

  @override
  void initState() {
    super.initState();
    _loadGameData();

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _particlesController.dispose();
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo
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
                      colors: [Colors.purple.shade900, Colors.blue.shade900],
                    ),
                  ),
                );
              },
            ),
          ),

          // Overlay oscuro
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.2),
            ),
          ),

          // Partículas
          AnimatedBuilder(
            animation: _particlesController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlesPainter(_particlesController.value),
                size: Size.infinite,
              );
            },
          ),

          // PERSONAJE GIGANTE - Parado en el suelo
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _breatheController,
              builder: (context, child) {
                final breatheOffset =
                    sin(_breatheController.value * 2 * pi) * 10;
                return Transform.translate(
                  offset: Offset(0, breatheOffset),
                  child: Container(
                    height: screenHeight * 0.75,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withValues(alpha: 0.5),
                          blurRadius: 80,
                          spreadRadius: 30,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      _getCharacterImage(),
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                );
              },
            ),
          ),

          // Header superior
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón perfil
                  _HeaderButton(
                    color: const Color(0xFF4A90E2),
                    iconImage: null,
                    icon: Icons.person,
                    onPressed: () {},
                  ),

                  // Recursos
                  Row(
                    children: [
                      _ResourceBar(
                        icon: 'assets/images/coins/coin_icon.png',
                        amount: _coins,
                        accentColor: const Color(0xFFFFA726),
                      ),
                      const SizedBox(width: 10),
                      _ResourceBar(
                        icon: 'assets/images/coins/gem_icon.png',
                        amount: _gems,
                        accentColor: const Color(0xFFAB47BC),
                      ),
                    ],
                  ),

                  // Botón noticias
                  _HeaderButton(
                    color: const Color(0xFFFF6F00),
                    iconImage: 'assets/images/icons/news_icon.png',
                    icon: Icons.notifications,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),

          // BOTONES DE MENÚ - Columna vertical a la izquierda (sin overflow)
          Positioned(
            left: 8,
            top: screenHeight * 0.2,
            child: SizedBox(
              height: screenHeight * 0.6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SideMenuButton(
                    iconImage: 'assets/images/icons/heroes_icon.png',
                    label: 'PERSONAJES',
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
                  SizedBox(height: screenHeight * 0.02),
                  _SideMenuButton(
                    iconImage: 'assets/images/icons/shop_icon.png',
                    label: 'TIENDA',
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
                  SizedBox(height: screenHeight * 0.02),
                  _SideMenuButton(
                    iconImage: 'assets/images/icons/news_icon.png',
                    label: 'MAPA',
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LevelMapScreen(),
                        ),
                      );
                      _loadGameData();
                    },
                  ),
                ],
              ),
            ),
          ),

          // BOTÓN JUGAR - Rectángulo amarillo en esquina inferior derecha
          Positioned(
            right: 15,
            bottom: 40,
            child: _PlayButtonUnified(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CharacterSelectionScreen(),
                  ),
                );
                _loadGameData();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Partículas
class ParticlesPainter extends CustomPainter {
  final double animationValue;
  final Random random = Random(42);

  ParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      final x = (random.nextDouble() * size.width);
      final y = ((random.nextDouble() * size.height) +
              (animationValue * size.height * 0.5)) %
          size.height;
      final radius = random.nextDouble() * 3 + 1;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) => true;
}

// Botón del header
class _HeaderButton extends StatelessWidget {
  final Color color;
  final String? iconImage;
  final IconData icon;
  final VoidCallback onPressed;

  const _HeaderButton({
    required this.color,
    this.iconImage,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.black.withValues(alpha: 0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 3,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: iconImage != null
                  ? Image.asset(
                      iconImage!,
                      width: 30,
                      height: 30,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(icon, color: Colors.white, size: 28),
                    )
                  : Icon(icon, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}

// Barra de recursos estilo Brawl Stars
class _ResourceBar extends StatelessWidget {
  final String icon;
  final int amount;
  final Color accentColor;

  const _ResourceBar({
    required this.icon,
    required this.amount,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.black.withValues(alpha: 0.7),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.9),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono con fondo de color
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              icon,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                  size: 24),
            ),
          ),
          const SizedBox(width: 8),
          // Cantidad con outline
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              '$amount',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontFamily: 'GameFont',
                shadows: [
                  for (var i = 0; i < 8; i++)
                    Shadow(
                      color: Colors.black,
                      offset: Offset(
                        cos(i * pi / 4) * 2,
                        sin(i * pi / 4) * 2,
                      ),
                      blurRadius: 0,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Botón de menú lateral con label - Optimizado para no overflow
class _SideMenuButton extends StatelessWidget {
  final String iconImage;
  final String label;
  final VoidCallback onPressed;

  const _SideMenuButton({
    required this.iconImage,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón con diseño mejorado
        Container(
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: RadialGradient(
              colors: [
                const Color(0xFF2D3748).withValues(alpha: 0.9),
                const Color(0xFF1A202C).withValues(alpha: 0.95),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF4A5568),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.cyan.withValues(alpha: 0.2),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  iconImage,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.menu, color: Colors.white, size: 38),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Label pequeño con ancho fijo
        Container(
          width: 75,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.9),
              width: 2,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 7,
                fontWeight: FontWeight.w900,
                fontFamily: 'GameFont',
                shadows: [
                  for (var i = 0; i < 8; i++)
                    Shadow(
                      color: Colors.black,
                      offset: Offset(
                        cos(i * pi / 4) * 1,
                        sin(i * pi / 4) * 1,
                      ),
                      blurRadius: 0,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Botón JUGAR unificado - Rectángulo amarillo grande estilo Brawl Stars
class _PlayButtonUnified extends StatelessWidget {
  final VoidCallback onPressed;

  const _PlayButtonUnified({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      height: 75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.withValues(alpha: 0.7),
            blurRadius: 30,
            spreadRadius: 8,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.9),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFDD835),
              Color(0xFFF9A825),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFFFF59D),
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.5),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(18),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'JUGAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'GameFont',
                      letterSpacing: 3,
                      shadows: [
                        for (var i = 0; i < 8; i++)
                          Shadow(
                            color: Colors.black,
                            offset: Offset(
                              cos(i * pi / 4) * 3,
                              sin(i * pi / 4) * 3,
                            ),
                            blurRadius: 0,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
