import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:juego_happy/game/arena_brawler_game.dart';
import 'package:juego_happy/game/components/health_bar.dart';

import 'package:juego_happy/game/components/player.dart';
import 'package:juego_happy/game/components/projectile.dart';
import 'package:juego_happy/game/components/wall.dart';
import 'package:juego_happy/models/character_model.dart';

class EnemyBot extends SpriteAnimationGroupComponent<PlayerState>
    with HasGameReference<ArenaBrawlerGame>, CollisionCallbacks {
  final CharacterModel character;
  late final ValueNotifier<double> healthNotifier;
  late double maxSpeed;

  static const double _projectileSpeed = 200.0; // Reducido para ser más esquivable
  double _lastShotTime = 0.0;
  final double _shootCooldown;

  // Variables para detección de movimiento
  Vector2 _lastPosition = Vector2.zero();
  bool _isMoving = false;

  EnemyBot({required this.character})
      : _shootCooldown = 2.0 + Random().nextDouble() * 1.0, // 2-3 seconds
        super() {
    maxSpeed = character.baseSpeed * 15;
    healthNotifier = ValueNotifier(character.baseHealth);
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    
    // Cargar animaciones si es un spritesheet
    if (character.spriteAsset.contains('spritesheet')) {
      await _loadAnimations();
    } else {
      // Fallback para otros personajes (imagen estática)
      final sprite = await game.loadSprite(character.spriteAsset);
      animations = {
        PlayerState.idle: SpriteAnimation.spriteList([sprite], stepTime: 1),
        PlayerState.runDown: SpriteAnimation.spriteList([sprite], stepTime: 1),
        PlayerState.runLeft: SpriteAnimation.spriteList([sprite], stepTime: 1),
        PlayerState.runRight: SpriteAnimation.spriteList([sprite], stepTime: 1),
        PlayerState.runUp: SpriteAnimation.spriteList([sprite], stepTime: 1),
      };
      current = PlayerState.idle;
    }

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
    
    _lastPosition = position.clone();
  }

  Future<void> _loadAnimations() async {
    final image = await game.images.load(character.spriteAsset);
    
    final frameWidth = image.width / 4;
    final frameHeight = image.height / 4;
    final textureSize = Vector2(frameWidth, frameHeight);

    final downAnimation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.15,
        textureSize: textureSize,
        texturePosition: Vector2(0, 0),
      ),
    );

    final leftAnimation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.15,
        textureSize: textureSize,
        texturePosition: Vector2(0, frameHeight),
      ),
    );

    final rightAnimation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.15,
        textureSize: textureSize,
        texturePosition: Vector2(0, frameHeight * 2),
      ),
    );

    final upAnimation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.15,
        textureSize: textureSize,
        texturePosition: Vector2(0, frameHeight * 3),
      ),
    );

    animations = {
      PlayerState.idle: downAnimation,
      PlayerState.runDown: downAnimation,
      PlayerState.runLeft: leftAnimation,
      PlayerState.runRight: rightAnimation,
      PlayerState.runUp: upAnimation,
    };
    
    current = PlayerState.idle;
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

    // Actualizar animación basada en movimiento
    final displacement = position - _lastPosition;
    _isMoving = displacement.length2 > 0.001;
    
    if (_isMoving) {
      if (displacement.x.abs() > displacement.y.abs()) {
        if (displacement.x > 0) {
          current = PlayerState.runRight;
        } else {
          current = PlayerState.runLeft;
        }
      } else {
        if (displacement.y > 0) {
          current = PlayerState.runDown;
        } else {
          current = PlayerState.runUp;
        }
      }
    } else {
      current = PlayerState.idle;
    }
    _lastPosition = position.clone();
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
      healthNotifier.value = 0;
      // Notificar al juego que el enemigo murió
      game.onEnemyDeath(this);
      removeFromParent();
    }
  }
}
