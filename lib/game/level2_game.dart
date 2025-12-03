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
  Color backgroundColor() =>
      const Color(0xFF1a1a2e); // Azul muy oscuro para nivel 2

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
    const wallThickness = 60.0; // Muros más gruesos y visibles

    // Cargar sprite de pared
    Sprite? wallSprite;
    try {
      wallSprite = await loadSprite('level2_maze_walls/stone_wall.png');
    } catch (e) {
      // Ignorar error de carga de sprite
    }

    // Bordes del mapa
    if (wallSprite != null || true) {
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

    // Laberinto interior - Diseño más amplio y claro
    // Pasillos de al menos 200px de ancho
    final mazeWalls = [
      // Estructura central (alrededor del diamante)
      Rect.fromLTWH(
          worldSize.x / 2 - 300, worldSize.y / 2 - 300, 200, wallThickness),
      Rect.fromLTWH(
          worldSize.x / 2 + 100, worldSize.y / 2 - 300, 200, wallThickness),
      Rect.fromLTWH(
          worldSize.x / 2 - 300, worldSize.y / 2 + 300, 200, wallThickness),
      Rect.fromLTWH(
          worldSize.x / 2 + 100, worldSize.y / 2 + 300, 200, wallThickness),

      Rect.fromLTWH(
          worldSize.x / 2 - 300, worldSize.y / 2 - 300, wallThickness, 200),
      Rect.fromLTWH(
          worldSize.x / 2 + 300, worldSize.y / 2 - 300, wallThickness, 200),
      Rect.fromLTWH(
          worldSize.x / 2 - 300, worldSize.y / 2 + 100, wallThickness, 200),
      Rect.fromLTWH(
          worldSize.x / 2 + 300, worldSize.y / 2 + 100, wallThickness, 200),

      // Bloques grandes para definir áreas
      // Area Superior Izquierda
      Rect.fromLTWH(400, 400, 300, wallThickness),
      Rect.fromLTWH(400, 400, wallThickness, 400),

      // Area Superior Derecha
      Rect.fromLTWH(1700, 400, 300, wallThickness),
      Rect.fromLTWH(2000, 400, wallThickness, 400),

      // Area Inferior Izquierda
      Rect.fromLTWH(400, 1400, 300, wallThickness),
      Rect.fromLTWH(400, 1000, wallThickness, 400),

      // Area Inferior Derecha
      Rect.fromLTWH(1700, 1400, 300, wallThickness),
      Rect.fromLTWH(2000, 1000, wallThickness, 400),

      // Muros divisorios centrales
      Rect.fromLTWH(1000, 200, wallThickness, 400),
      Rect.fromLTWH(1400, 200, wallThickness, 400),

      Rect.fromLTWH(1000, 1200, wallThickness, 400),
      Rect.fromLTWH(1400, 1200, wallThickness, 400),
    ];

    // Agregar paredes del laberinto
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

    // Guardia 1 - Patrulla superior (Pasillo ancho)
    world.add(Guard(
      character: guardCharacter,
      position: Vector2(800, 500), // Centrado en y=500
      patrolPoints: [
        Vector2(600, 500),
        Vector2(1000, 500),
      ],
    ));

    // Guardia 2 - Patrulla central izquierda (Pasillo vertical)
    world.add(Guard(
      character: guardCharacter,
      position: Vector2(500, 800), // Centrado en x=500
      patrolPoints: [
        Vector2(500, 700),
        Vector2(500, 1000),
      ],
    ));

    // Guardia 3 - Patrulla central derecha (Pasillo vertical)
    world.add(Guard(
      character: guardCharacter,
      position: Vector2(1800, 800), // Centrado en x=1800
      patrolPoints: [
        Vector2(1800, 700),
        Vector2(1800, 1000),
      ],
    ));

    // Guardia 4 - Patrulla inferior (Pasillo horizontal)
    world.add(Guard(
      character: guardCharacter,
      position: Vector2(1200, 1300), // Centrado en y=1300
      patrolPoints: [
        Vector2(900, 1300),
        Vector2(1500, 1300),
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

      final moveVector =
          joystick.relativeDelta.normalized() * player.maxSpeed * dt;
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
