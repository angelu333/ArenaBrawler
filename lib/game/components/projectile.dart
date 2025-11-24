import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:juego_happy/game/components/enemy_bot.dart';
import 'package:juego_happy/game/components/guard.dart';
import 'package:juego_happy/game/components/hit_effect.dart';
import 'package:juego_happy/game/components/player.dart';
import 'package:juego_happy/game/components/wall.dart';
import 'package:juego_happy/game/components/maze_wall.dart';

class Projectile extends CircleComponent
    with HasGameReference<FlameGame>, CollisionCallbacks {
  final Vector2 velocity;
  final double damage;
  final bool isFromPlayer;
  final bool isSpecial;

  Projectile({
    required Vector2 position,
    required this.velocity,
    required this.isFromPlayer,
    this.damage = 10.0,
    this.isSpecial = false,
  }) : super(
          position: position,
          radius: isSpecial ? 12 : 8,
          paint: Paint()
            ..color = isSpecial 
                ? Colors.orange 
                : (isFromPlayer ? Colors.lightBlueAccent : Colors.deepOrangeAccent)
            ..style = PaintingStyle.fill,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Hitbox más pequeño que el visual para mejor jugabilidad
    add(CircleHitbox(radius: 6));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.add(velocity * dt);

    // Remove the projectile if it goes too far (simple boundary check)
    if (position.x < -100 ||
        position.x > 3000 ||
        position.y < -100 ||
        position.y > 3000) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Wall || other is MazeWall) {
      // Efecto de impacto en pared
      try {
        game.world.add(HitEffect(position: position.clone()));
      } catch (e) {
        // Ignorar si no se puede agregar efecto
      }
      removeFromParent();
    } else if (other is Player && !isFromPlayer) {
      // Efecto de impacto en jugador
      try {
        game.world.add(HitEffect(position: position.clone()));
      } catch (e) {
        // Ignorar si no se puede agregar efecto
      }
      other.takeDamage(damage);
      removeFromParent();
    } else if (other is EnemyBot && isFromPlayer) {
      // Efecto de impacto en enemigo
      try {
        game.world.add(HitEffect(position: position.clone()));
      } catch (e) {
        // Ignorar si no se puede agregar efecto
      }
      other.takeDamage(damage);
      removeFromParent();
    } else if (other is Guard && isFromPlayer) {
      // Efecto de impacto en guardia
      try {
        game.world.add(HitEffect(position: position.clone()));
      } catch (e) {
        // Ignorar si no se puede agregar efecto
      }
      other.takeDamage(damage);
      removeFromParent();
    }
  }
}
