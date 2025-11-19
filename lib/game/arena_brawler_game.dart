import 'dart:async';
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:juego_happy/data/character_data.dart';
import 'package:juego_happy/game/components/arena.dart';
import 'package:juego_happy/game/components/enemy_bot.dart';
import 'package:juego_happy/game/components/joystick.dart';
import 'package:juego_happy/game/components/player.dart';
import 'package:juego_happy/game/data/arena_data.dart';
import 'package:juego_happy/models/character_model.dart';

class ArenaBrawlerGame extends FlameGame with HasCollisionDetection {
  final CharacterModel playerCharacter;
  final int levelId;
  late final Player player;
  late final DirectionJoystick joystick;
  final List<EnemyBot> enemies = [];
  bool isGameOver = false;
  bool hasWon = false;

  static final Vector2 worldSize = Vector2(1600, 1200);

  ArenaBrawlerGame({required this.playerCharacter, this.levelId = 1});

  void onPlayerDeath() {
    if (!isGameOver) {
      isGameOver = true;
      pauseEngine();
      overlays.add('GameOver');
    }
  }

  void onEnemyDeath(EnemyBot enemy) {
    enemies.remove(enemy);
    // Verificar si todos los enemigos han sido eliminados
    if (enemies.isEmpty && !hasWon && !isGameOver) {
      hasWon = true;
      pauseEngine();
      overlays.add('Victory');
    }
  }

  @override
  Color backgroundColor() => const Color(0xFF0d2818); // Verde muy oscuro

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    
    // Configurar viewport para que la cámara no muestre fuera de la arena
    camera.viewfinder.visibleGameSize = Vector2(800, 600);

    // Seleccionar arena según el nivel
    String arenaPath = 'arenas/arena_1.png';
    if (levelId >= 6) {
      arenaPath = 'arenas/arena_3.png';
    } else if (levelId >= 3) {
      arenaPath = 'arenas/arena_2.png';
    }

    final arenaData = ArenaData(
      spritePath: arenaPath,
      obstacles: [], // No obstacles/walls for Level 1
    );

    world.add(Arena(data: arenaData));

    // Add joystick
    joystick = DirectionJoystick();

    // Add player
    player = Player(character: playerCharacter);
    player.position = Vector2(worldSize.x / 2, worldSize.y * 0.7);
    world.add(player);

    // Add enemies based on level
    _addEnemiesForLevel();

    camera.viewport.add(joystick);

    // Set camera to follow the player
    camera.follow(player);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!joystick.isDragged) {
      return;
    }

    // Update player's move direction
    player.setMoveDirection(joystick.relativeDelta);

    // Calculate new position
    final moveVector =
        joystick.relativeDelta.normalized() * player.maxSpeed * dt;
    player.position.add(moveVector);
  }

  void _addEnemiesForLevel() {
    final enemyCharacter = CharacterData.availableCharacters.firstWhere(
      (char) => char.id == 'warrior',
      orElse: () => CharacterData.availableCharacters[1],
    );

    // Determinar número de enemigos según el nivel
    int enemyCount = 1;
    if (levelId == 2) {
      enemyCount = 2;
    } else if (levelId == 3 || levelId == 4) {
      enemyCount = 3;
    } else if (levelId == 5) {
      enemyCount = 5;
    } else if (levelId == 6) {
      enemyCount = 4;
    }

    // Posiciones para los enemigos
    final positions = [
      Vector2(worldSize.x / 2, worldSize.y * 0.3),
      Vector2(worldSize.x * 0.3, worldSize.y * 0.3),
      Vector2(worldSize.x * 0.7, worldSize.y * 0.3),
      Vector2(worldSize.x * 0.3, worldSize.y * 0.5),
      Vector2(worldSize.x * 0.7, worldSize.y * 0.5),
    ];

    for (int i = 0; i < enemyCount && i < positions.length; i++) {
      final enemy = EnemyBot(character: enemyCharacter);
      enemy.position = positions[i];
      enemies.add(enemy);
      world.add(enemy);
    }
  }
}
