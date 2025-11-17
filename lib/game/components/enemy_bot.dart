import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:juego_happy/game/arena_brawler_game.dart';
import 'package:juego_happy/game/components/health_bar.dart';

import 'package:juego_happy/game/components/projectile.dart';
import 'package:juego_happy/game/components/wall.dart';
import 'package:juego_happy/models/character_model.dart';

class EnemyBot extends SpriteComponent
    with HasGameReference<ArenaBrawlerGame>, CollisionCallbacks {
  final CharacterModel character;
  late final ValueNotifier<double> healthNotifier;
  late double maxSpeed;

  static const double _projectileSpeed = 200.0; // Reducido para ser más esquivable
  double _lastShotTime = 0.0;
  final double _shootCooldown;

  EnemyBot({required this.character})
      : _shootCooldown = 2.0 + Random().nextDouble() * 1.0, // 2-3 seconds
        super() {
    maxSpeed = character.baseSpeed * 15;
    healthNotifier = ValueNotifier(character.baseHealth);
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    // Cargar el sprite del personaje enemigo desde assets
    sprite = await game.loadSprite(character.spriteAsset);
    size = Vector2.all(110.0); // Tamaño más grande
    anchor = Anchor.center;

    // Hitbox circular más pequeño para mejor precisión
    add(CircleHitbox(radius: 30));
    add(HealthBar(
      healthNotifier: healthNotifier,
      maxHealth: character.baseHealth,
      position: Vector2(0, size.y - 15),
      size: Vector2(size.x, 5),
    ));
  }

  @override
  void onRemove() {
    healthNotifier.dispose();
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);

    final player = game.player;
    if (!player.isMounted) return;

    final distanceToPlayer = position.distanceTo(player.position);

    if (distanceToPlayer > 200) {
      final direction = (player.position - position).normalized();
      position.add(direction * maxSpeed * dt);
    } else {
      final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
      if (currentTime - _lastShotTime > _shootCooldown) {
        shoot();
        _lastShotTime = currentTime;
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Wall) {
      final rect = toRect();
      final otherRect = other.toRect();
      final intersection = rect.intersect(otherRect);

      if (intersection.width < intersection.height) {
        // Horizontal collision
        if (rect.left < otherRect.left) {
          position.x = otherRect.left - width / 2;
        } else {
          position.x = otherRect.right + width / 2;
        }
      } else {
        // Vertical collision
        if (rect.top < otherRect.top) {
          position.y = otherRect.top - height / 2;
        } else {
          position.y = otherRect.bottom + height / 2;
        }
      }
    }
  }

  void shoot() {
    if (!game.player.isMounted) return;
    final direction = (game.player.position - position).normalized();
    final projectile = Projectile(
      position: position.clone(),
      velocity: direction * _projectileSpeed,
      damage: character.attackDamage,
      isFromPlayer: false,
    );
    game.world.add(projectile);
  }

  void takeDamage(double damage) {
    healthNotifier.value -= damage;
    if (healthNotifier.value <= 0) {
      removeFromParent();
    }
  }
}
