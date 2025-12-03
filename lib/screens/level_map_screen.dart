import 'package:flutter/material.dart';
import 'package:juego_happy/data/character_data.dart';
import 'package:juego_happy/game/flame_game_wrapper.dart';
import 'package:juego_happy/game/level2_wrapper.dart';
import 'package:juego_happy/models/level_data.dart';
import 'package:juego_happy/services/game_data_service.dart';
import 'package:juego_happy/services/audio_service.dart';

class LevelMapScreen extends StatefulWidget {
  const LevelMapScreen({super.key});

  @override
  State<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends State<LevelMapScreen> {
  final GameDataService _gameData = GameDataService();
  final AudioService _audioService = AudioService();
  Map<int, Map<String, dynamic>> _progress = {};
  int _currentLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await _gameData.getLevelProgress();
    final current = await _gameData.getCurrentLevel();
    setState(() {
      _progress = progress;
      _currentLevel = current;
    });
  }

  bool _isLevelUnlocked(int levelId) {
    return _progress[levelId]?['isUnlocked'] ?? (levelId == 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Fondo (Imagen generada)
          Image.asset(
            'assets/images/level_map_background_v2.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.black,
                child: const Center(
                  child: Text(
                    'Background not found',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),

          // 2. Botones de Nivel (Posicionados sobre los "huecos")

          // Nivel 1: Lava (Anillo dorado)
          Align(
            alignment: const Alignment(-0.60, 0.02),
            child: _LevelButton(
              levelId: 1,
              type: _LevelButtonType.orange,
              isUnlocked: _isLevelUnlocked(1),
              onTap: () => _onLevelTap(1),
            ),
          ),

          // Nivel 2: Laberinto (Entrada de piedra)
          Align(
            alignment: const Alignment(0.06, 0.04),
            child: _LevelButton(
              levelId: 2,
              type: _LevelButtonType.blue,
              isUnlocked: _isLevelUnlocked(2),
              onTap: () => _onLevelTap(2),
            ),
          ),

          // Nivel 3: Castillo (Portón)
          Align(
            alignment: const Alignment(0.66, -0.02),
            child: _LevelButton(
              levelId: 3,
              type: _LevelButtonType.lock,
              isUnlocked: _isLevelUnlocked(3),
              onTap: () => _onLevelTap(3),
            ),
          ),

          // 3. Botón Atrás (Sobre el cartel de madera)
          Align(
            alignment: const Alignment(-0.935, -0.95),
            child: _BackButton(
              onTap: () {
                _audioService.playClickSound();
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onLevelTap(int levelId) {
    if (!_isLevelUnlocked(levelId)) {
      _audioService.playClickSound(); // Sonido de "bloqueado" o click
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Completa el nivel anterior para desbloquear!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    // Buscar datos del nivel
    final level = LevelData.allLevels.firstWhere(
      (l) => l.id == levelId,
      orElse: () => LevelData.allLevels[0],
    );

    _startLevel(level);
  }

  void _startLevel(LevelData level) async {
    // Obtener personaje seleccionado
    final selectedCharId = await _gameData.getSelectedCharacter();
    final character = CharacterData.availableCharacters.firstWhere(
      (c) => c.id == selectedCharId,
      orElse: () => CharacterData.availableCharacters[0],
    );

    if (!mounted) return;

    // Detener música del menú antes de entrar al nivel
    await _audioService.stopMusic();

    // Navegar según el nivel
    if (level.id == 2) {
      // Nivel 2: Laberinto
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Level2Wrapper(selectedCharacter: character),
        ),
      );
    } else {
      // Otros niveles: Arena
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FlameGameWrapper(
            selectedCharacter: character,
            levelId: level.id,
          ),
        ),
      );
    }

    // Al volver del nivel, reanudar música del menú
    await _audioService.playMenuMusic();

    // Recargar progreso
    _loadProgress();
  }
}

enum _LevelButtonType { orange, blue, lock }

class _LevelButton extends StatefulWidget {
  final int levelId;
  final _LevelButtonType type;
  final bool isUnlocked;
  final VoidCallback onTap;

  const _LevelButton({
    required this.levelId,
    required this.type,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  State<_LevelButton> createState() => _LevelButtonState();
}

class _LevelButtonState extends State<_LevelButton> {
  bool _isPressed = false;
  final AudioService _audioService = AudioService();

  @override
  Widget build(BuildContext context) {
    // Si es tipo lock y no está desbloqueado, mostramos el candado
    // Si está desbloqueado, mostramos un estilo genérico o el que corresponda (ej. castillo)
    // Para simplificar, si es lock y está desbloqueado, lo mostramos como un botón "final" (rojo/púrpura)

    final isLockedMode =
        widget.type == _LevelButtonType.lock && !widget.isUnlocked;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _audioService.playClickSound(); // Sonido "clac" inmediato
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0,
        duration:
            const Duration(milliseconds: 100), // Rápido para sentir el "clic"
        child: isLockedMode ? _buildLockSprite() : _buildLevelSprite(),
      ),
    );
  }

  Widget _buildLockSprite() {
    // Sprite D (Candado)
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.grey.shade700,
            Colors.black,
          ],
          center: const Alignment(-0.2, -0.2),
          radius: 0.8,
        ),
        border: Border.all(color: Colors.grey.shade600, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.lock,
          size: 28,
          color: Colors.amber.shade700,
          shadows: const [
            Shadow(color: Colors.black, blurRadius: 5, offset: Offset(1, 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelSprite() {
    // Determinar colores según tipo
    List<Color> gradientColors;
    Color borderColor;
    Color textColor;

    if (widget.type == _LevelButtonType.orange) {
      // Nivel 1: Lava (Naranja/Dorado)
      if (_isPressed) {
        // Sprite B2 (Presionado: Oscuro, menos brillo)
        gradientColors = [
          const Color(0xFFD84315), // Deep Orange 800
          const Color(0xFFBF360C), // Deep Orange 900
        ];
        borderColor = const Color(0xFF8D6E63); // Darker gold/brown
      } else {
        // Sprite B1 (Normal: Brillante)
        gradientColors = [
          const Color(0xFFFFAB00), // Amber A700
          const Color(0xFFFF6D00), // Orange A700
        ];
        borderColor = const Color(0xFFFFD700); // Gold
      }
      textColor = Colors.white;
    } else if (widget.type == _LevelButtonType.blue) {
      // Nivel 2: Laberinto (Azul/Plata)
      if (_isPressed) {
        // Sprite C2 (Presionado)
        gradientColors = [
          const Color(0xFF0277BD), // Light Blue 800
          const Color(0xFF01579B), // Light Blue 900
        ];
        borderColor = const Color(0xFF90A4AE); // Dark silver
      } else {
        // Sprite C1 (Normal)
        gradientColors = [
          const Color(0xFF4FC3F7), // Light Blue 300
          const Color(0xFF0288D1), // Light Blue 700
        ];
        borderColor = const Color(0xFFE0E0E0); // Silver
      }
      textColor = Colors.white;
    } else {
      // Nivel 3 Desbloqueado (Castillo - Púrpura/Rojo)
      if (_isPressed) {
        gradientColors = [
          const Color(0xFF6A1B9A),
          const Color(0xFF4A148C),
        ];
        borderColor = const Color(0xFFBDBDBD);
      } else {
        gradientColors = [
          const Color(0xFFAB47BC),
          const Color(0xFF7B1FA2),
        ];
        borderColor = const Color(0xFFFFD700);
      }
      textColor = Colors.white;
    }

    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: gradientColors,
          center: const Alignment(-0.3, -0.3), // Highlight offset
          radius: 1.0,
        ),
        border: Border.all(
          color: borderColor,
          width: 3,
        ),
        boxShadow: _isPressed
            ? [] // No shadow when pressed (sunk effect)
            : [
                BoxShadow(
                  color: gradientColors.last.withOpacity(0.6),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Center(
        child: Text(
          '${widget.levelId}',
          style: TextStyle(
            fontFamily:
                'GameFont', // Asegúrate de tener esta fuente o usa una default
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: textColor,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(2, 2),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatefulWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 45,
          height: 45,
          decoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFFFFE082), // Cream/Gold color
              size: 36,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(2, 2),
                  blurRadius: 3,
                ),
                Shadow(
                  color: Color(0xFF3E2723), // Dark wood shadow
                  offset: Offset(-1, -1),
                  blurRadius: 0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
