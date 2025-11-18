/// Datos de un nivel individual
class LevelData {
  final int id;
  final String name;
  final String description;
  final int difficulty; // 1-5
  final int enemyCount;
  final String arenaId;
  final int coinsReward;
  final LevelPosition position; // Posición en el mapa

  const LevelData({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.enemyCount,
    required this.arenaId,
    required this.coinsReward,
    required this.position,
  });

  static final List<LevelData> allLevels = [
    // Mundo 1: Tutorial
    const LevelData(
      id: 1,
      name: 'Primera Batalla',
      description: 'Aprende los controles básicos',
      difficulty: 1,
      enemyCount: 1,
      arenaId: 'arena_1',
      coinsReward: 50,
      position: LevelPosition(x: 0.5, y: 0.9),
    ),
    const LevelData(
      id: 2,
      name: 'Doble Problema',
      description: 'Enfrenta a dos enemigos',
      difficulty: 2,
      enemyCount: 2,
      arenaId: 'arena_1',
      coinsReward: 75,
      position: LevelPosition(x: 0.5, y: 0.75),
    ),
    const LevelData(
      id: 3,
      name: 'Emboscada',
      description: 'Tres enemigos te esperan',
      difficulty: 2,
      enemyCount: 3,
      arenaId: 'arena_2',
      coinsReward: 100,
      position: LevelPosition(x: 0.3, y: 0.6),
    ),
    const LevelData(
      id: 4,
      name: 'Camino Alternativo',
      description: 'Otra ruta, misma dificultad',
      difficulty: 2,
      enemyCount: 3,
      arenaId: 'arena_2',
      coinsReward: 100,
      position: LevelPosition(x: 0.7, y: 0.6),
    ),
    const LevelData(
      id: 5,
      name: 'Horda',
      description: 'Sobrevive a la horda',
      difficulty: 3,
      enemyCount: 5,
      arenaId: 'arena_2',
      coinsReward: 150,
      position: LevelPosition(x: 0.5, y: 0.45),
    ),
    const LevelData(
      id: 6,
      name: 'Arena Mortal',
      description: 'La arena más peligrosa',
      difficulty: 4,
      enemyCount: 4,
      arenaId: 'arena_3',
      coinsReward: 200,
      position: LevelPosition(x: 0.5, y: 0.3),
    ),
    const LevelData(
      id: 7,
      name: 'Jefe Final',
      description: 'El enemigo más poderoso',
      difficulty: 5,
      enemyCount: 1, // Un jefe muy fuerte
      arenaId: 'arena_3',
      coinsReward: 500,
      position: LevelPosition(x: 0.5, y: 0.1),
    ),
  ];

  // Conexiones entre niveles (qué nivel desbloquea cuál)
  static final Map<int, List<int>> connections = {
    1: [2], // Nivel 1 desbloquea nivel 2
    2: [3, 4], // Nivel 2 desbloquea 3 y 4 (bifurcación)
    3: [5], // Nivel 3 desbloquea 5
    4: [5], // Nivel 4 también desbloquea 5
    5: [6], // Nivel 5 desbloquea 6
    6: [7], // Nivel 6 desbloquea el jefe
  };
}

/// Posición del nivel en el mapa (0.0 a 1.0)
class LevelPosition {
  final double x; // Horizontal (0 = izquierda, 1 = derecha)
  final double y; // Vertical (0 = arriba, 1 = abajo)

  const LevelPosition({required this.x, required this.y});
}

/// Estado de progreso de un nivel
class LevelProgress {
  final int levelId;
  final bool isCompleted;
  final bool isUnlocked;
  final int stars; // 0-3 estrellas
  final int bestScore;
  final double bestTime;

  const LevelProgress({
    required this.levelId,
    this.isCompleted = false,
    this.isUnlocked = false,
    this.stars = 0,
    this.bestScore = 0,
    this.bestTime = 0,
  });

  LevelProgress copyWith({
    bool? isCompleted,
    bool? isUnlocked,
    int? stars,
    int? bestScore,
    double? bestTime,
  }) {
    return LevelProgress(
      levelId: levelId,
      isCompleted: isCompleted ?? this.isCompleted,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      stars: stars ?? this.stars,
      bestScore: bestScore ?? this.bestScore,
      bestTime: bestTime ?? this.bestTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'levelId': levelId,
      'isCompleted': isCompleted,
      'isUnlocked': isUnlocked,
      'stars': stars,
      'bestScore': bestScore,
      'bestTime': bestTime,
    };
  }

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      levelId: json['levelId'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      stars: json['stars'] as int? ?? 0,
      bestScore: json['bestScore'] as int? ?? 0,
      bestTime: (json['bestTime'] as num?)?.toDouble() ?? 0,
    );
  }
}
