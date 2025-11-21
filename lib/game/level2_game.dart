import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:juego_happy/data/character_data.dart';
import 'package:juego_happy/game/components/diamond.dart';
import 'package:juego_happy/game/components/exit_point.dart';
import 'package:juego_happy/game/components/guard.dart';
import 'package:juego_happy/game/components/joystick.dart';
import 'package:juego_happy/game/components/shooting_joystick.dart';
import 'package:juego_happy/game/components/maze_wall.dart'; // Importar el nuevo componente
import 'package:juego_happy/game/components/player.dart';
import 'package:juego_happy/models/character_model.dart';

class Level2Game extends FlameGame
    with HasCollisionDetection
    implements Level2GameInterface {
  final CharacterModel playerCharacter;
  late final Player player;
  late final DirectionJoystick joystick;
  bool isGameOver = false;
  bool hasDiamond = false;
  bool hasWon = false;

  static final Vector2 worldSize = Vector2(2400, 1800); // Mapa más grande

  Level2Game({required this.playerCharacter});

  @override
  Color backgroundColor() => const Color(0xFF1a1a2e); // Azul muy oscuro para nivel 2

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    camera.viewfinder.visibleGameSize = Vector2(800, 600);

    // Agregar fondo de arena 3
    try {
      final sprite = await loadSprite('arenas/arena_3.png');
      world.add(
        SpriteComponent(
          sprite: sprite,
          size: worldSize,
          position: Vector2.zero(),
          priority: -1,
        ),
      );
    } catch (e) {
      // Si falla, usar color de respaldo
      world.add(
        RectangleComponent(
          size: worldSize,
          position: Vector2.zero(),
          paint: Paint()..color = const Color(0xFF2a1a4d),
          priority: -1,
        ),
      );
    }

    // Crear laberinto
    await _createMaze();

    // Agregar diamante en el centro
    final diamond = Diamond(
      position: Vector2(worldSize.x / 2, worldSize.y / 2),
    );
    world.add(diamond);

    // Agregar punto de salida (esquina superior izquierda)
    final exitPoint = ExitPoint(
      position: Vector2(100, 100),
      size: Vector2(80, 80),
      requiresDiamond: true,
    );
    world.add(exitPoint);

    // Agregar joystick
    joystick = DirectionJoystick();
    shootingJoystick = ShootingJoystick();

    // Agregar jugador (cerca de la salida)
    player = Player(character: playerCharacter);
    player.position = Vector2(150, 150);

    world.add(player);
    camera.viewport.add(joystick);
    camera.viewport.add(shootingJoystick);

    // Agregar guardias patrullando
    _addGuards();

    // Seguir al jugador con la cámara
    camera.follow(player);
  }

  Future<void> _createMaze() async {
    const wallThickness = 40.0; // Más grueso para que se vea mejor
    
    // Cargar sprite de pared
    Sprite? wallSprite;
    try {
      wallSprite = await loadSprite('level2_maze_walls/wall_straight.png');
    } catch (e) {
      // Ignorar error de carga de sprite
    }

    // Bordes del mapa
    if (wallSprite != null) {
      world.add(MazeWall(
        position: Vector2(0, 0),
        size: Vector2(worldSize.x, wallThickness),
        sprite: wallSprite,
      ));
      world.add(MazeWall(
        position: Vector2(0, worldSize.y - wallThickness),
        size: Vector2(worldSize.x, wallThickness),
        sprite: wallSprite,
      ));
      world.add(MazeWall(
        position: Vector2(0, 0),
        size: Vector2(wallThickness, worldSize.y),
        sprite: wallSprite,
      ));
      world.add(MazeWall(
        position: Vector2(worldSize.x - wallThickness, 0),
        size: Vector2(wallThickness, worldSize.y),
        sprite: wallSprite,
      ));
    }

    // Laberinto interior - Diseño complejo
    final mazeWalls = [
      // Paredes horizontales
      const Rect.fromLTWH(300, 300, 400, 20),
      const Rect.fromLTWH(800, 300, 400, 20),
      const Rect.fromLTWH(1400, 300, 400, 20),
      
      const Rect.fromLTWH(400, 600, 500, 20),
      const Rect.fromLTWH(1100, 600, 500, 20),
      
      const Rect.fromLTWH(300, 900, 400, 20),
      const Rect.fromLTWH(900, 900, 600, 20),
      
      const Rect.fromLTWH(400, 1200, 500, 20),
      const Rect.fromLTWH(1200, 1200, 400, 20),
      
      const Rect.fromLTWH(300, 1500, 600, 20),
      const Rect.fromLTWH(1100, 1500, 500, 20),

      // Paredes verticales
      const Rect.fromLTWH(600, 100, 20, 400),
      const Rect.fromLTWH(1200, 100, 20, 400),
      const Rect.fromLTWH(1800, 100, 20, 400),
      
      const Rect.fromLTWH(400, 500, 20, 300),
      const Rect.fromLTWH(1000, 500, 20, 300),
      const Rect.fromLTWH(1600, 500, 20, 300),
      
      const Rect.fromLTWH(700, 800, 20, 400),
      const Rect.fromLTWH(1300, 800, 20, 400),
      const Rect.fromLTWH(1900, 800, 20, 400),
      
      const Rect.fromLTWH(500, 1100, 20, 300),
      const Rect.fromLTWH(1100, 1100, 20, 300),
      const Rect.fromLTWH(1700, 1100, 20, 300),

      // Habitaciones y pasillos
      const Rect.fromLTWH(800, 700, 300, 20),
      const Rect.fromLTWH(1400, 700, 300, 20),
      
      const Rect.fromLTWH(900, 400, 20, 200),
      const Rect.fromLTWH(1500, 400, 20, 200),
      
      // Obstáculos cerca del centro
      Rect.fromLTWH(worldSize.x / 2 - 200, worldSize.y / 2 - 100, 150, 20),
      Rect.fromLTWH(worldSize.x / 2 + 50, worldSize.y / 2 - 100, 150, 20),
      Rect.fromLTWH(worldSize.x / 2 - 200, worldSize.y / 2 + 80, 150, 20),
      Rect.fromLTWH(worldSize.x / 2 + 50, worldSize.y / 2 + 80, 150, 20),
    ];

    // Agregar paredes del laberinto
    // Si wallSprite es null, MazeWall usará el color de respaldo
    if (wallSprite != null || true) {
      for (final rect in mazeWalls) {
        world.add(MazeWall(
          position: Vector2(rect.left, rect.top),
          size: Vector2(rect.width, rect.height),
          sprite: wallSprite,
        ));
      }
    }
  }

  void _addGuards() {
    final guardCharacter = CharacterData.availableCharacters.firstWhere(
      (char) => char.id == 'warrior',
      orElse: () => CharacterData.availableCharacters[1],
    );

    // Guardia 1 - Patrulla superior
    world.add(Guard(
      character: guardCharacter,
      position: Vector2(800, 400),
      patrolPoints: [
        Vector2(600, 400),
        Vector2(1200, 400),
        Vector2(1200, 600),
        Vector2(600, 600),
      ],
    ));

    // Guardia 2 - Patrulla central
    world.add(Guard(
      character: guardCharacter,
      position: Vector2(worldSize.x / 2 - 300, worldSize.y / 2),
      patrolPoints: [
        Vector2(worldSize.x / 2 - 300, worldSize.y / 2 - 200),
        Vector2(worldSize.x / 2 - 300, worldSize.y / 2 + 200),
      ],
    ));

    // Guardia 3 - Patrulla derecha
    world.add(Guard(
      character: guardCharacter,
      position: Vector2(worldSize.x / 2 + 300, worldSize.y / 2),
      patrolPoints: [
        Vector2(worldSize.x / 2 + 300, worldSize.y / 2 - 200),
        Vector2(worldSize.x / 2 + 300, worldSize.y / 2 + 200),
      ],
    ));

    // Guardia 4 - Patrulla inferior
    world.add(Guard(
      character: guardCharacter,
      position: Vector2(1200, 1400),
      patrolPoints: [
        Vector2(800, 1400),
        Vector2(1600, 1400),
        Vector2(1600, 1600),
        Vector2(800, 1600),
      ],
    ));
  }

  late final ShootingJoystick shootingJoystick;
  bool _wasShooting = false;

  @override
  void update(double dt) {
    super.update(dt);
    
    // 1. Movimiento
    if (joystick.isDragged) {
      player.setMoveDirection(joystick.relativeDelta);
      player.animateMovement(dt, true);
      
      final moveVector = joystick.relativeDelta.normalized() * player.maxSpeed * dt;
      player.position.add(moveVector);
    } else {
      player.animateMovement(dt, false);
    }

    // 2. Disparo
    if (shootingJoystick.isDragged) {
      _wasShooting = true;
      player.setAimDirection(shootingJoystick.relativeDelta);
    } else {
      if (_wasShooting) {
        _wasShooting = false;
        player.stopAiming();
      }
    }
  }

  @override
  void onDiamondCollected() {
    hasDiamond = true;
    overlays.add('DiamondCollected');
    Future.delayed(const Duration(seconds: 2), () {
      overlays.remove('DiamondCollected');
    });
  }

  @override
  void onPlayerReachedExit() {
    if (hasDiamond && !hasWon) {
      hasWon = true;
      pauseEngine();
      overlays.add('Victory');
    } else if (!hasDiamond) {
      overlays.add('NeedDiamond');
      Future.delayed(const Duration(seconds: 2), () {
        overlays.remove('NeedDiamond');
      });
    }
  }

  void onPlayerDeath() {
    if (!isGameOver) {
      isGameOver = true;
      pauseEngine();
      overlays.add('GameOver');
    }
  }
}

abstract class Level2GameInterface {
  void onDiamondCollected();
  void onPlayerReachedExit();
}
