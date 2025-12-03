import 'dart:math';
import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:video_player/video_player.dart';
>>>>>>> master
import 'package:juego_happy/screens/character_selection_screen.dart';
import 'package:juego_happy/screens/level_map_screen.dart';
import 'package:juego_happy/screens/store_screen.dart';
import 'package:juego_happy/services/game_data_service.dart';
import 'package:juego_happy/services/audio_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GameDataService _gameData = GameDataService();
  final AudioService _audioService = AudioService();
  int _coins = 0;
  final int _gems = 50;
  String _selectedCharacter = 'default';

  late AnimationController _breatheController;
  late AnimationController _particlesController;
<<<<<<< HEAD
=======
  late VideoPlayerController _backgroundVideoController;
>>>>>>> master

  @override
  void initState() {
    super.initState();
    _loadGameData();

    // Iniciar música de menú
    _audioService.playMenuMusic();

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
<<<<<<< HEAD
=======

    _backgroundVideoController = VideoPlayerController.asset('assets/videos/home_background.mp4')
      ..initialize().then((_) {
        _backgroundVideoController.setLooping(true);
        _backgroundVideoController.play();
        setState(() {});
      });
    
    // Add listener to refresh UI when video updates (important for size/state changes)
    _backgroundVideoController.addListener(() {
      if (mounted) setState(() {});
    });
>>>>>>> master
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _particlesController.dispose();
<<<<<<< HEAD
=======
    _backgroundVideoController.dispose();
>>>>>>> master
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
        return 'assets/images/sprites/char_adventurer.png';
    }
  }

  Future<void> _addFreeCoins() async {
    // Dar 100 monedas gratis cada vez que se presiona
    final newCoins = _coins + 100;
    await _gameData.saveCoins(newCoins);
    setState(() {
      _coins = newCoins;
    });

    // Mostrar mensaje
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.yellow),
              const SizedBox(width: 8),
              const Text(
                '¡+100 monedas gratis!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
<<<<<<< HEAD
            child: Image.asset(
              'assets/images/lobby_background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: const [
                        Color(0xFF1A0F2E), // Deep dark purple
                        Color(0xFF0D1B2A), // Dark navy blue
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Atmospheric gradient overlay for depth
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3, 0.7],
                ),
              ),
            ),
          ),

          // Vignette effect for cinematic look
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),
=======
            child: _backgroundVideoController.value.isInitialized
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _backgroundVideoController.value.size.width,
                        height: _backgroundVideoController.value.size.height,
                        child: VideoPlayer(_backgroundVideoController),
                      ),
                    ),
                  )
                : Image.asset(
                    'assets/images/lobby_background.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF1A0F2E),
                      );
                    },
                  ),
          ),

          // Atmospheric gradient overlay removed for clearer video
          // Positioned.fill(
          //   child: Container(
          //     decoration: BoxDecoration(
          //       gradient: LinearGradient(
          //         begin: Alignment.topCenter,
          //         end: Alignment.bottomCenter,
          //         colors: [
          //           Colors.black.withOpacity( 0.4),
          //           Colors.black.withOpacity( 0.1),
          //           Colors.transparent,
          //         ],
          //         stops: const [0.0, 0.3, 0.7],
          //       ),
          //     ),
          //   ),
          // ),

          // Vignette effect removed for clearer video
          // Positioned.fill(
          //   child: Container(
          //     decoration: BoxDecoration(
          //       gradient: RadialGradient(
          //         center: Alignment.center,
          //         radius: 1.0,
          //         colors: [
          //           Colors.transparent,
          //           Colors.black.withOpacity( 0.3),
          //         ],
          //         stops: const [0.5, 1.0],
          //       ),
          //     ),
          //   ),
          // ),
>>>>>>> master

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

          // PERSONAJE GIGANTE - Parado en el suelo con iluminación mejorada
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
                        // Main character glow
                        BoxShadow(
<<<<<<< HEAD
                          color: Colors.cyan.withValues(alpha: 0.4),
=======
                          color: Colors.cyan.withOpacity( 0.4),
>>>>>>> master
                          blurRadius: 100,
                          spreadRadius: 20,
                        ),
                        // Secondary purple glow for depth
                        BoxShadow(
<<<<<<< HEAD
                          color: Colors.purple.withValues(alpha: 0.3),
=======
                          color: Colors.purple.withOpacity( 0.3),
>>>>>>> master
                          blurRadius: 80,
                          spreadRadius: 40,
                        ),
                        // Ground shadow
                        BoxShadow(
<<<<<<< HEAD
                          color: Colors.black.withValues(alpha: 0.6),
=======
                          color: Colors.black.withOpacity( 0.6),
>>>>>>> master
                          blurRadius: 60,
                          spreadRadius: -10,
                          offset: const Offset(0, 50),
                        ),
                        // Rim light effect
                        BoxShadow(
<<<<<<< HEAD
                          color: Colors.yellow.withValues(alpha: 0.2),
=======
                          color: Colors.yellow.withOpacity( 0.2),
>>>>>>> master
                          blurRadius: 120,
                          spreadRadius: 10,
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
                      GestureDetector(
                        onTap: _addFreeCoins,
                        child: _ResourceBar(
                          icon: 'assets/images/coins/coin_icon.png',
                          amount: _coins,
                          accentColor: const Color(0xFFFFA726),
                          showAddIcon:
                              true, // Mostrar icono "+" para indicar que es clickeable
                        ),
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

          // Title text only - No card blocking character
          Positioned(
            top: 90,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '¡Prepárate para la batalla!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18, // Reducido de 24 a 18
                  fontWeight: FontWeight.w900,
                  fontFamily: 'GameFont',
                  letterSpacing: 2,
                  shadows: [
                    // Black outline for readability
                    for (var i = 0; i < 8; i++)
                      Shadow(
                        color: Colors.black,
                        offset: Offset(
                          cos(i * pi / 4) * 3,
                          sin(i * pi / 4) * 3,
                        ),
                        blurRadius: 0,
                      ),
                    // Cyan glow
                    Shadow(
<<<<<<< HEAD
                      color: Colors.cyan.withValues(alpha: 0.8),
=======
                      color: Colors.cyan.withOpacity( 0.8),
>>>>>>> master
                      blurRadius: 20,
                      offset: Offset.zero,
                    ),
                    Shadow(
<<<<<<< HEAD
                      color: Colors.cyan.withValues(alpha: 0.5),
=======
                      color: Colors.cyan.withOpacity( 0.5),
>>>>>>> master
                      blurRadius: 40,
                      offset: Offset.zero,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // BOTONES DE MENÚ - Columna vertical a la izquierda (sin scroll)
          Positioned(
            left: 8,
            top: screenHeight * 0.28,
            bottom: screenHeight * 0.18,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SideMenuButton(
                    iconImage: 'assets/images/icons/heroes_icon.png',
                    label: 'PERSONAJES',
                    onPressed: () async {
<<<<<<< HEAD
=======
                      _backgroundVideoController.pause();
>>>>>>> master
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const CharacterSelectionScreen(selectOnly: true),
                        ),
                      );
<<<<<<< HEAD
=======
                      _backgroundVideoController.play();
>>>>>>> master
                      _loadGameData();
                    },
                  ),
                  const SizedBox(height: 8),
                  _SideMenuButton(
                    iconImage: 'assets/images/icons/shop_icon.png',
                    label: 'TIENDA',
                    onPressed: () async {
<<<<<<< HEAD
=======
                      _backgroundVideoController.pause();
>>>>>>> master
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StoreScreen(),
                        ),
                      );
<<<<<<< HEAD
=======
                      _backgroundVideoController.play();
>>>>>>> master
                      _loadGameData();
                    },
                  ),
                  const SizedBox(height: 8),
                  _SideMenuButton(
                    iconImage: 'assets/images/icons/news_icon.png',
                    label: 'MAPA',
                    onPressed: () async {
<<<<<<< HEAD
=======
                      _backgroundVideoController.pause();
>>>>>>> master
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LevelMapScreen(),
                        ),
                      );
<<<<<<< HEAD
=======
                      _backgroundVideoController.play();
>>>>>>> master
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
<<<<<<< HEAD
=======
                _backgroundVideoController.pause();
>>>>>>> master
                // Ir directamente al mapa de niveles
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LevelMapScreen(),
                  ),
                );
<<<<<<< HEAD
=======
                _backgroundVideoController.play();
>>>>>>> master
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
    for (int i = 0; i < 50; i++) {
      final x = (random.nextDouble() * size.width);
      final y = ((random.nextDouble() * size.height) +
              (animationValue * size.height * 0.5)) %
          size.height;
      final radius = random.nextDouble() * 4 + 1;

      // Varied particle colors for more magical effect
      final colorChoice = i % 3;
      Color particleColor;
      if (colorChoice == 0) {
<<<<<<< HEAD
        particleColor = Colors.white.withValues(alpha: 0.4);
      } else if (colorChoice == 1) {
        particleColor = Colors.cyan.withValues(alpha: 0.3);
      } else {
        particleColor = Colors.purple.withValues(alpha: 0.25);
=======
        particleColor = Colors.white.withOpacity( 0.4);
      } else if (colorChoice == 1) {
        particleColor = Colors.cyan.withOpacity( 0.3);
      } else {
        particleColor = Colors.purple.withOpacity( 0.25);
>>>>>>> master
      }

      final paint = Paint()
        ..color = particleColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), radius, paint);

      // Add glow effect to some particles
      if (i % 5 == 0) {
        final glowPaint = Paint()
<<<<<<< HEAD
          ..color = particleColor.withValues(alpha: 0.1)
=======
          ..color = particleColor.withOpacity( 0.1)
>>>>>>> master
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), radius * 2, glowPaint);
      }
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
<<<<<<< HEAD
        color: Colors.black.withValues(alpha: 0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
=======
        color: Colors.black.withOpacity( 0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.8),
>>>>>>> master
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
<<<<<<< HEAD
            color: Colors.white.withValues(alpha: 0.4),
=======
            color: Colors.white.withOpacity( 0.4),
>>>>>>> master
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
  final bool showAddIcon;

  const _ResourceBar({
    required this.icon,
    required this.amount,
    required this.accentColor,
    this.showAddIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
<<<<<<< HEAD
        color: Colors.black.withValues(alpha: 0.7),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.9),
=======
        color: Colors.black.withOpacity( 0.7),
        border: Border.all(
          color: Colors.black.withOpacity( 0.9),
>>>>>>> master
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
<<<<<<< HEAD
            color: Colors.black.withValues(alpha: 0.8),
=======
            color: Colors.black.withOpacity( 0.8),
>>>>>>> master
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
<<<<<<< HEAD
                color: Colors.white.withValues(alpha: 0.5),
=======
                color: Colors.white.withOpacity( 0.5),
>>>>>>> master
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
          // Icono "+" para indicar que es clickeable
          if (showAddIcon)
            Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 16,
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
          width: 70, // Aumentado de 65 a 70
          height: 70, // Aumentado de 65 a 70
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: RadialGradient(
              colors: [
<<<<<<< HEAD
                const Color(0xFF2D3748).withValues(alpha: 0.9),
                const Color(0xFF1A202C).withValues(alpha: 0.95),
=======
                const Color(0xFF2D3748).withOpacity( 0.9),
                const Color(0xFF1A202C).withOpacity( 0.95),
>>>>>>> master
              ],
            ),
            border: Border.all(
              color: const Color(0xFF4A5568),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
<<<<<<< HEAD
                color: Colors.black.withValues(alpha: 0.8),
=======
                color: Colors.black.withOpacity( 0.8),
>>>>>>> master
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
<<<<<<< HEAD
                color: Colors.cyan.withValues(alpha: 0.2),
=======
                color: Colors.cyan.withOpacity( 0.2),
>>>>>>> master
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
        const SizedBox(height: 3),
        // Label sin overflow
        Container(
          width: 78, // Aumentado de 75 a 78
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 3),
          decoration: BoxDecoration(
<<<<<<< HEAD
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.9),
=======
            color: Colors.black.withOpacity( 0.8),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.black.withOpacity( 0.9),
>>>>>>> master
              width: 2,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 7, // Reducido de 9 a 7
              fontWeight: FontWeight.bold,
              fontFamily: 'GameFont',
              letterSpacing: 0.5,
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
<<<<<<< HEAD
            color: Colors.yellow.withValues(alpha: 0.7),
=======
            color: Colors.yellow.withOpacity( 0.7),
>>>>>>> master
            blurRadius: 30,
            spreadRadius: 8,
          ),
          BoxShadow(
<<<<<<< HEAD
            color: Colors.black.withValues(alpha: 0.9),
=======
            color: Colors.black.withOpacity( 0.9),
>>>>>>> master
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
<<<<<<< HEAD
              color: Colors.orange.withValues(alpha: 0.5),
=======
              color: Colors.orange.withOpacity( 0.5),
>>>>>>> master
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
