import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:juego_happy/game/components/wall.dart';
import 'package:juego_happy/game/data/arena_data.dart';

class Arena extends Component with HasGameReference<FlameGame> {
  final ArenaData data;

  Arena({required this.data});

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    // Add background
    if (data.spritePath != null) {
      // Cargar la imagen de la arena
      final sprite = await game.loadSprite(data.spritePath!);
      add(
        SpriteComponent(
          sprite: sprite,
          size: Vector2(1600, 1200), // Arena size
          position: Vector2.zero(),
          priority: -1, // Renderizar detrás de todo
        ),
      );
    } else {
      add(
        RectangleComponent(
          size: Vector2(1600, 1200), // Arena size
          paint: Paint()..color = data.color ?? const Color(0xFF272727),
        ),
      );
    }

    // Add obstacles
    for (final rect in data.obstacles) {
      add(
        Wall(
          position: Vector2(rect.left, rect.top),
          size: Vector2(rect.width, rect.height),
        ),
      );
    }
  }
}
