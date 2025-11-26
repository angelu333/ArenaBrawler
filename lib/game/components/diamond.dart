import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:juego_happy/game/components/player.dart';

/// Diamante que el jugador debe recoger
/// Diamante que el jugador debe recoger
class Diamond extends SpriteComponent
    with HasGameReference<FlameGame>, CollisionCallbacks {
  bool isCollected = false;

  Diamond({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(40),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await game.loadSprite('coins/gem_icon.png');
    add(CircleHitbox(radius: 20));

    // Efecto de flotación
    add(MoveEffect.by(
      Vector2(0, -10),
      EffectController(
        duration: 1,
        alternate: true,
        infinite: true,
        curve: Curves.easeInOut,
      ),
    ));
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Player && !isCollected) {
      collect();
    }
  }

  void collect() {
    isCollected = true;
    removeFromParent();
    // Notificar al juego que se recogió el diamante
    try {
      final gameRef = game as dynamic;
      if (gameRef.onDiamondCollected != null) {
        gameRef.onDiamondCollected();
      }
    } catch (e) {
      // Ignorar si no es Level2Game
    }
  }
}
