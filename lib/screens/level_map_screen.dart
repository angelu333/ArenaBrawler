import 'package:flutter/material.dart';
import 'package:juego_happy/data/character_data.dart';
import 'package:juego_happy/game/flame_game_wrapper.dart';
import 'package:juego_happy/game/level2_wrapper.dart';
import 'package:juego_happy/models/level_data.dart';
import 'package:juego_happy/services/game_data_service.dart';

class LevelMapScreen extends StatefulWidget {
  const LevelMapScreen({super.key});

  @override
  State<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends State<LevelMapScreen>
    with SingleTickerProviderStateMixin {
  final GameDataService _gameData = GameDataService();
  Map<int, Map<String, dynamic>> _progress = {};
  int _currentLevel = 1;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _loadProgress();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
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
          ),
        ],
      ),
    );
  }

  void _showLockedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Completa el nivel anterior para desbloquear!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _startLevel(LevelData level) async {
    // Obtener personaje seleccionado
    final selectedCharId = await _gameData.getSelectedCharacter();
    final character = CharacterData.availableCharacters.firstWhere(
      (c) => c.id == selectedCharId,
      orElse: () => CharacterData.availableCharacters[0],
    );

    if (!mounted) return;

    // Navegar según el nivel
    if (level.id == 2) {
      // Nivel 2: Laberinto con guardias y diamante
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Level2Wrapper(selectedCharacter: character),
        ),
      );
    } else {
      // Otros niveles: Juego normal de arena
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

    // Recargar progreso
    _loadProgress();
  }
}

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
}
