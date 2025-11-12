import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:juego_happy/game/arena_brawler_game.dart';
import 'package:juego_happy/game/components/health_bar.dart';
import 'package:juego_happy/game/components/projectile.dart';
import 'package:juego_happy/game/components/wall.dart';
import 'package:juego_happy/models/character_model.dart';

class Player extends SpriteComponent
    with HasGameReference<ArenaBrawlerGame>, CollisionCallbacks {
  final CharacterModel character;
  late double maxSpeed;

  late final ValueNotifier<double> healthNotifier;

  static const double _projectileSpeed = 300.0;
  double _lastShotTime = 0.0;
  Vector2 _lastMoveDirection = Vector2(0, 1); // Default shoot down

  Player({required this.character}) {
    maxSpeed = character.baseSpeed * 20; // Scale speed for gameplay
    healthNotifier = ValueNotifier(character.baseHealth);
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    // Cargar el sprite del personaje desde assets
    sprite = await game.loadSprite(character.spriteAsset);
    size = Vector2.all(96.0); // Aumentado de 64 a 96
    anchor = Anchor.center;

    add(RectangleHitbox());
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
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    if (currentTime - _lastShotTime < character.attackCooldownSec) {
      return; // Cooldown not over
    }

    _lastShotTime = currentTime;

    final projectile = Projectile(
      position: position.clone(),
      velocity: _lastMoveDirection.normalized() * _projectileSpeed,
      damage: character.attackDamage,
      isFromPlayer: true,
    );

    game.world.add(projectile);
  }

  void setMoveDirection(Vector2 direction) {
    if (direction.length2 > 0) {
      _lastMoveDirection = direction.normalized();
    }
  }

  void takeDamage(double damage) {
    healthNotifier.value -= damage;
    if (healthNotifier.value <= 0) {
      // Handle player death
      removeFromParent();
    }
  }
}
