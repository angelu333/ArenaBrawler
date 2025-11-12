import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:juego_happy/game/arena_brawler_game.dart';
import 'package:juego_happy/game/components/enemy_bot.dart';
import 'package:juego_happy/game/components/player.dart';
import 'package:juego_happy/game/components/wall.dart';

class Projectile extends CircleComponent
    with HasGameReference<ArenaBrawlerGame>, CollisionCallbacks {
  final Vector2 velocity;
  final double damage;
  final bool isFromPlayer;

  Projectile({
    required Vector2 position,
    required this.velocity,
    required this.isFromPlayer,
    this.damage = 10.0,
  }) : super(
          position: position,
          radius: 5,
          paint: Paint()..color = isFromPlayer ? Colors.lightBlueAccent : Colors.deepOrangeAccent,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.add(velocity * dt);

    // Remove the projectile if it goes off-screen
    if (position.x < 0 ||
        position.x > ArenaBrawlerGame.worldSize.x ||
        position.y < 0 ||
        position.y > ArenaBrawlerGame.worldSize.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Wall) {
      removeFromParent();
    } else if (other is Player && !isFromPlayer) {
      other.takeDamage(damage);
      removeFromParent();
    } else if (other is EnemyBot && isFromPlayer) {
      other.takeDamage(damage);
      removeFromParent();
    }
  }
}
