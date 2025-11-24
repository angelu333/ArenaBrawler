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
    // Nivel 1: Tutorial / Arena Básica
    const LevelData(
      id: 1,
      name: 'Primera Batalla',
      description: 'Aprende los controles básicos',
      difficulty: 1,
      enemyCount: 1,
      arenaId: 'arena_1',
      coinsReward: 50,
      position: LevelPosition(x: 0.2, y: 0.5), // Izquierda
    ),
    // Nivel 2: El Laberinto (Misión de Robo)
    const LevelData(
      id: 2,
      name: 'El Laberinto',
      description: 'Roba el diamante y escapa',
      difficulty: 3,
      enemyCount: 4, // Guardias
      arenaId: 'arena_3', // Usa assets de arena 3
      coinsReward: 100,
      position: LevelPosition(x: 0.5, y: 0.5), // Centro
    ),
    // Nivel 3: Jefe Final
    const LevelData(
      id: 3,
      name: 'Jefe Final',
      description: 'La batalla final',
      difficulty: 5,
      enemyCount: 1, // Jefe
      arenaId: 'arena_3',
      coinsReward: 500,
      position: LevelPosition(x: 0.8, y: 0.5), // Derecha
    ),
  ];

  // Conexiones entre niveles (qué nivel desbloquea cuál)
  static final Map<int, List<int>> connections = {
    1: [2], // Nivel 1 desbloquea nivel 2
    2: [3], // Nivel 2 desbloquea nivel 3
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
