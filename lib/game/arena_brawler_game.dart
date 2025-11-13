import 'dart:async';
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Rect;
import 'package:juego_happy/data/character_data.dart';
import 'package:juego_happy/game/components/arena.dart';
import 'package:juego_happy/game/components/enemy_bot.dart';
import 'package:juego_happy/game/components/joystick.dart';
import 'package:juego_happy/game/components/player.dart';
import 'package:juego_happy/game/data/arena_data.dart';
import 'package:juego_happy/models/character_model.dart';

class ArenaBrawlerGame extends FlameGame with HasCollisionDetection {
  final CharacterModel playerCharacter;
  late final Player player;
  late final DirectionJoystick joystick;
  late final EnemyBot enemyBot;
  bool isGameOver = false;

  static final Vector2 worldSize = Vector2(1600, 1200);

  ArenaBrawlerGame({required this.playerCharacter});

  void onPlayerDeath() {
    if (!isGameOver) {
      isGameOver = true;
      pauseEngine();
      overlays.add('GameOver');
    }
  }

  @override
  Color backgroundColor() => const Color(0xFF2a2a2a);

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    
    // Configurar viewport para que la cámara no muestre fuera de la arena
    camera.viewfinder.visibleGameSize = Vector2(800, 600);

    final arenaData = ArenaData(
      spritePath: 'arenas/arena_1.png', // Usar la primera arena
      obstacles: [
        // World boundaries
        Rect.fromLTWH(0, 0, worldSize.x, 10), // Top
        Rect.fromLTWH(0, worldSize.y - 10, worldSize.x, 10), // Bottom
        Rect.fromLTWH(0, 0, 10, worldSize.y), // Left
        Rect.fromLTWH(worldSize.x - 10, 0, 10, worldSize.y), // Right
        // Some obstacles
        Rect.fromLTWH(worldSize.x * 0.25, worldSize.y * 0.5 - 50, 20, 100),
        Rect.fromLTWH(worldSize.x * 0.75, worldSize.y * 0.5 - 50, 20, 100),
      ],
    );

    world.add(Arena(data: arenaData));

    // Add joystick
    joystick = DirectionJoystick();

    // Add player
    player = Player(character: playerCharacter);
    player.position = Vector2(worldSize.x / 2, worldSize.y * 0.7);

    // Add enemy bot
    final enemyCharacter = CharacterData.availableCharacters.firstWhere(
      (char) => char.id == 'warrior',
      orElse: () => CharacterData.availableCharacters[1], // Fallback
    );
    enemyBot = EnemyBot(character: enemyCharacter);
    enemyBot.position = Vector2(worldSize.x / 2, worldSize.y * 0.3);

    // Add components to the world
    world.add(player);
    world.add(enemyBot);
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
}
