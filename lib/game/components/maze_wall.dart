import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// Pared con sprite para el laberinto del nivel 2
class MazeWall extends SpriteComponent with CollisionCallbacks {
  MazeWall({
    required Vector2 position,
    required Vector2 size,
    required Sprite sprite,
  }) : super(
          sprite: sprite,
          position: position,
          size: size,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(isSolid: true));
  }
}
