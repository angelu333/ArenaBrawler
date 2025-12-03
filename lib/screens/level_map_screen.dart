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

<<<<<<< HEAD
class _LevelMapScreenState extends State<LevelMapScreen>
    with SingleTickerProviderStateMixin {
  final GameDataService _gameData = GameDataService();
  Map<int, Map<String, dynamic>> _progress = {};
  int _currentLevel = 1;
  late AnimationController _pulseController;
=======
class _LevelMapScreenState extends State<LevelMapScreen> {
  final GameDataService _gameData = GameDataService();
  final AudioService _audioService = AudioService();
  Map<int, Map<String, dynamic>> _progress = {};
  int _currentLevel = 1;
>>>>>>> master

  @override
  void initState() {
    super.initState();
    _loadProgress();
<<<<<<< HEAD
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
=======
>>>>>>> master
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

<<<<<<< HEAD
  bool _isLevelCompleted(int levelId) {
    return _progress[levelId]?['isCompleted'] ?? false;
  }

  int _getLevelStars(int levelId) {
    return _progress[levelId]?['stars'] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade300,
              Colors.green.shade200,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Fondo decorativo
            _buildBackground(),

            // Mapa de niveles
            CustomPaint(
              size: Size(size.width, size.height),
              painter: LevelPathPainter(
                levels: LevelData.allLevels,
                connections: LevelData.connections,
                progress: _progress,
              ),
            ),

            // Nodos de niveles
            ...LevelData.allLevels.map((level) {
              return _buildLevelNode(
                level,
                size,
                _isLevelUnlocked(level.id),
                _isLevelCompleted(level.id),
                _getLevelStars(level.id),
                level.id == _currentLevel,
              );
            }),

            // Header
            _buildHeader(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: CloudsPainter(),
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.5),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: 12),
              const Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'MAPA DE NIVELES',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelNode(
    LevelData level,
    Size screenSize,
    bool isUnlocked,
    bool isCompleted,
    int stars,
    bool isCurrent,
  ) {
    final isLandscape = screenSize.width > screenSize.height;
    final nodeSize = isLandscape ? 60.0 : 80.0;
    final x = level.position.x * screenSize.width;
    final y = level.position.y * screenSize.height;

    return Positioned(
      left: x - nodeSize / 2,
      top: y - nodeSize / 2,
      child: GestureDetector(
        onTap:
            isUnlocked ? () => _onLevelTap(level) : () => _showLockedMessage(),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale =
                isCurrent ? 1.0 + (_pulseController.value * 0.1) : 1.0;

            return Transform.scale(
              scale: scale,
              child: Column(
                children: [
                  // Nodo del nivel
                  Container(
                    width: nodeSize,
                    height: nodeSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _getNodeColors(
                          isUnlocked,
                          isCompleted,
                          isCurrent,
                          level.difficulty,
                        ),
                      ),
                      border: Border.all(
                        color: isCurrent ? Colors.yellow : Colors.white,
                        width: isCurrent ? 4 : 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                        if (isCurrent)
                          BoxShadow(
                            color: Colors.yellow.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Número del nivel
                        Center(
                          child: Text(
                            '${level.id}',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: isLandscape ? 24 : 32,
                              fontWeight: FontWeight.bold,
                              color: isUnlocked
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              shadows: const [
                                Shadow(
                                  color: Colors.black,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Icono de bloqueado
                        if (!isUnlocked)
                          Center(
                            child: Icon(
                              Icons.lock,
                              size: isLandscape ? 30 : 40,
                              color: Colors.white70,
                            ),
                          ),

                        // Check de completado
                        if (isCompleted)
                          Positioned(
                            top: 3,
                            right: 3,
                            child: Container(
                              padding: EdgeInsets.all(isLandscape ? 2 : 4),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                size: isLandscape ? 14 : 20,
                                color: Colors.white,
                              ),
                            ),
                          ),

                        // Indicador de jugador actual
                        if (isCurrent)
                          Positioned(
                            bottom: isLandscape ? -8 : -10,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Icon(
                                Icons.person,
                                size: isLandscape ? 20 : 30,
                                color: Colors.yellow,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: isLandscape ? 4 : 8),

                  // Estrellas
                  if (isCompleted && !isLandscape)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        return Icon(
                          index < stars ? Icons.star : Icons.star_border,
                          size: 12,
                          color: Colors.amber,
                        );
                      }),
                    ),

                  // Nombre del nivel (solo en vertical)
                  if (isUnlocked && !isLandscape)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        level.name,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Color> _getNodeColors(
    bool isUnlocked,
    bool isCompleted,
    bool isCurrent,
    int difficulty,
  ) {
    if (!isUnlocked) {
      return [Colors.grey.shade700, Colors.grey.shade900];
    }

    if (isCompleted) {
      return [Colors.green.shade400, Colors.green.shade700];
    }

    if (isCurrent) {
      return [Colors.blue.shade400, Colors.blue.shade700];
    }

    // Color según dificultad
    switch (difficulty) {
      case 1:
        return [Colors.green.shade300, Colors.green.shade600];
      case 2:
        return [Colors.blue.shade300, Colors.blue.shade600];
      case 3:
        return [Colors.orange.shade300, Colors.orange.shade600];
      case 4:
        return [Colors.red.shade300, Colors.red.shade600];
      case 5:
        return [Colors.purple.shade300, Colors.purple.shade600];
      default:
        return [Colors.grey.shade300, Colors.grey.shade600];
    }
  }

  void _onLevelTap(LevelData level) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(level.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(level.description),
            const SizedBox(height: 16),
            Text('Dificultad: ${'⭐' * level.difficulty}'),
            Text('Enemigos: ${level.enemyCount}'),
            Text('Recompensa: ${level.coinsReward} monedas'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startLevel(level);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('¡JUGAR!'),
=======
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
            alignment: const Alignment(-0.92, -0.88),
            child: _BackButton(
              onTap: () {
                _audioService.playClickSound();
                Navigator.pop(context);
              },
            ),
>>>>>>> master
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  void _showLockedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Completa el nivel anterior para desbloquear!'),
        backgroundColor: Colors.red,
      ),
    );
=======
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
>>>>>>> master
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
<<<<<<< HEAD
    final audioService = AudioService();
    await audioService.stopMusic();

    // Navegar según el nivel
    if (level.id == 2) {
      // Nivel 2: Laberinto con guardias y diamante
=======
    await _audioService.stopMusic();

    // Navegar según el nivel
    if (level.id == 2) {
      // Nivel 2: Laberinto
>>>>>>> master
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Level2Wrapper(selectedCharacter: character),
        ),
      );
    } else {
<<<<<<< HEAD
      // Otros niveles: Juego normal de arena
=======
      // Otros niveles: Arena
>>>>>>> master
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
<<<<<<< HEAD
    await audioService.playMenuMusic();
=======
    await _audioService.playMenuMusic();
>>>>>>> master

    // Recargar progreso
    _loadProgress();
  }
}

<<<<<<< HEAD
// Painter para dibujar los caminos entre niveles
class LevelPathPainter extends CustomPainter {
  final List<LevelData> levels;
  final Map<int, List<int>> connections;
  final Map<int, Map<String, dynamic>> progress;

  LevelPathPainter({
    required this.levels,
    required this.connections,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Dibujar conexiones
    connections.forEach((fromId, toIds) {
      final fromLevel = levels.firstWhere((l) => l.id == fromId);
      final fromPos = Offset(
        fromLevel.position.x * size.width,
        fromLevel.position.y * size.height,
      );

      for (final toId in toIds) {
        final toLevel = levels.firstWhere((l) => l.id == toId);
        final toPos = Offset(
          toLevel.position.x * size.width,
          toLevel.position.y * size.height,
        );

        // Color del camino según si está desbloqueado
        final isUnlocked = progress[toId]?['isUnlocked'] ?? false;
        paint.color =
            isUnlocked ? Colors.yellow.shade700 : Colors.brown.shade700;

        // Dibujar línea con curva
        final path = Path();
        path.moveTo(fromPos.dx, fromPos.dy);

        // Punto de control para curva
        final controlPoint = Offset(
          (fromPos.dx + toPos.dx) / 2,
          (fromPos.dy + toPos.dy) / 2 - 30,
        );

        path.quadraticBezierTo(
          controlPoint.dx,
          controlPoint.dy,
          toPos.dx,
          toPos.dy,
        );

        canvas.drawPath(path, paint);

        // Dibujar borde del camino
        paint.color = Colors.brown.shade900;
        paint.strokeWidth = 8;
        canvas.drawPath(path, paint);

        paint.strokeWidth = 6;
      }
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Painter para nubes decorativas
class CloudsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Dibujar algunas nubes
    _drawCloud(canvas, paint, Offset(size.width * 0.2, size.height * 0.1), 60);
    _drawCloud(canvas, paint, Offset(size.width * 0.7, size.height * 0.2), 80);
    _drawCloud(canvas, paint, Offset(size.width * 0.4, size.height * 0.4), 70);
    _drawCloud(canvas, paint, Offset(size.width * 0.8, size.height * 0.6), 90);
  }

  void _drawCloud(Canvas canvas, Paint paint, Offset center, double size) {
    canvas.drawCircle(center, size * 0.5, paint);
    canvas.drawCircle(center.translate(-size * 0.3, 0), size * 0.4, paint);
    canvas.drawCircle(center.translate(size * 0.3, 0), size * 0.4, paint);
    canvas.drawCircle(center.translate(0, -size * 0.2), size * 0.3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
=======
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
    
    final isLockedMode = widget.type == _LevelButtonType.lock && !widget.isUnlocked;
    
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
        duration: const Duration(milliseconds: 100), // Rápido para sentir el "clic"
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
            color: Colors.black.withOpacity( 0.5),
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
                  color: gradientColors.last.withOpacity( 0.6),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity( 0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Center(
        child: Text(
          '${widget.levelId}',
          style: TextStyle(
            fontFamily: 'GameFont', // Asegúrate de tener esta fuente o usa una default
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: textColor,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity( 0.5),
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
          decoration: BoxDecoration(
            color: Colors.transparent, // Transparente para ver la madera del fondo
            shape: BoxShape.circle,
            // Eliminamos borde para que parezca parte del cartel
          ),
          child: const Center(
            child: Icon(
              Icons.arrow_back,
              color: Colors.white, // O un color crema que combine mejor
              size: 32,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
>>>>>>> master
}
