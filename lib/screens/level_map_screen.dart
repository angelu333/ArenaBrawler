import 'package:flutter/material.dart';
import 'package:juego_happy/models/level_data.dart';
import 'package:juego_happy/services/game_data_service.dart';
// 'dart:math' removed because it was unused

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
        child: SafeArea(
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withAlpha((0.5 * 255).round()),
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
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withAlpha((0.5 * 255).round()),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'MAPA DE NIVELES',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 24,
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
          ],
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
    final x = level.position.x * screenSize.width;
    final y = level.position.y * screenSize.height;

    return Positioned(
      left: x - 40,
      top: y - 40,
      child: GestureDetector(
        onTap: isUnlocked
            ? () => _onLevelTap(level)
            : () => _showLockedMessage(),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = isCurrent
                ? 1.0 + (_pulseController.value * 0.1)
                : 1.0;

            return Transform.scale(
              scale: scale,
              child: Column(
                children: [
                  // Nodo del nivel
                  Container(
                    width: 80,
                    height: 80,
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
                          color: Colors.black.withAlpha((0.3 * 255).round()),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                        if (isCurrent)
                          BoxShadow(
                            color: Colors.yellow.withAlpha((0.5 * 255).round()),
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
                              fontSize: 32,
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
                          const Center(
                            child: Icon(
                              Icons.lock,
                              size: 40,
                              color: Colors.white70,
                            ),
                          ),

                        // Check de completado
                        if (isCompleted)
                          Positioned(
                            top: 5,
                            right: 5,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),

                        // Indicador de jugador actual
                        if (isCurrent)
                          const Positioned(
                            bottom: -10,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.yellow,
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Estrellas
                  if (isCompleted)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        return Icon(
                          index < stars ? Icons.star : Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        );
                      }),
                    ),

                  // Nombre del nivel
                  if (isUnlocked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha((0.7 * 255).round()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        level.name,
                        style: const TextStyle(
                          fontSize: 12,
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

  void _startLevel(LevelData level) {
    // TODO: Navegar a la pantalla del juego con este nivel
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Iniciando ${level.name}...')),
    );
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
        paint.color = isUnlocked
            ? Colors.yellow.shade700
            : Colors.brown.shade700;

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
  ..color = Colors.white.withAlpha((0.3 * 255).round())
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
