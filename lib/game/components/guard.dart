import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:juego_happy/game/components/health_bar.dart';
import 'package:juego_happy/game/components/player.dart';
import 'package:juego_happy/game/components/projectile.dart';
import 'package:juego_happy/game/components/wall.dart';
import 'package:juego_happy/models/character_model.dart';

/// Guardia que patrulla y persigue al jugador si lo ve
class Guard extends SpriteComponent
    with HasGameReference<FlameGame>, CollisionCallbacks {
  final CharacterModel character;
  final List<Vector2> patrolPoints;
  late final ValueNotifier<double> healthNotifier;
  late double maxSpeed;

  static const double _projectileSpeed = 200.0;
  static const double _visionRange = 250.0;
  static const double _visionAngle = 60.0; // Grados
  double _lastShotTime = 0.0;
  final double _shootCooldown = 2.5;

  int _currentPatrolIndex = 0;
  bool _isChasing = false;
  Vector2 _facingDirection = Vector2(0, 1);

  Guard({
    required this.character,
    required this.patrolPoints,
    required Vector2 position,
  }) : super(position: position) {
    maxSpeed = character.baseSpeed * 12;
    healthNotifier = ValueNotifier(character.baseHealth);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await game.loadSprite(character.spriteAsset);
    size = Vector2.all(110.0);
    anchor = Anchor.center;

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
  void render(Canvas canvas) {
    super.render(canvas);

    // Dibujar cono de visión si está patrullando
    if (!_isChasing) {
      _drawVisionCone(canvas);
    }
  }

  void _drawVisionCone(Canvas canvas) {
    final paint = Paint()
  ..color = Colors.yellow.withAlpha((0.2 * 255).round())
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);

    const angleRad = _visionAngle * (pi / 180);
    final leftAngle = atan2(_facingDirection.y, _facingDirection.x) - angleRad / 2;
    final rightAngle = atan2(_facingDirection.y, _facingDirection.x) + angleRad / 2;

    path.lineTo(
      cos(leftAngle) * _visionRange,
      sin(leftAngle) * _visionRange,
    );
    path.lineTo(
      cos(rightAngle) * _visionRange,
      sin(rightAngle) * _visionRange,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Buscar al jugador en el mundo
    final player = _findPlayer();
    if (player == null || !player.isMounted) {
      _patrol(dt);
      return;
    }

    // Verificar si ve al jugador
    if (_canSeePlayer(player)) {
      _isChasing = true;
      _chasePlayer(player, dt);
    } else {
      _isChasing = false;
      _patrol(dt);
    }
  }

  bool _canSeePlayer(Player player) {
    final toPlayer = player.position - position;
    final distance = toPlayer.length;

    if (distance > _visionRange) return false;

    // Verificar ángulo de visión
    final angleToPlayer = atan2(toPlayer.y, toPlayer.x);
    final facingAngle = atan2(_facingDirection.y, _facingDirection.x);
    final angleDiff = (angleToPlayer - facingAngle).abs();

    const visionAngleRad = _visionAngle * (pi / 180) / 2;

    return angleDiff < visionAngleRad;
  }

  void _patrol(double dt) {
    if (patrolPoints.isEmpty) return;

    final target = patrolPoints[_currentPatrolIndex];
    final toTarget = target - position;
    final distance = toTarget.length;

    if (distance < 10) {
      // Llegó al punto, ir al siguiente
      _currentPatrolIndex = (_currentPatrolIndex + 1) % patrolPoints.length;
    } else {
      // Moverse hacia el punto
      final direction = toTarget.normalized();
      _facingDirection = direction;
      position.add(direction * maxSpeed * dt);
    }
  }

  void _chasePlayer(Player player, double dt) {
    final toPlayer = player.position - position;
    final distance = toPlayer.length;

    if (distance > 150) {
      // Perseguir
      final direction = toPlayer.normalized();
      _facingDirection = direction;
      position.add(direction * maxSpeed * dt);
    } else {
      // Disparar
      final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
      if (currentTime - _lastShotTime > _shootCooldown) {
        shoot(toPlayer.normalized());
        _lastShotTime = currentTime;
      }
    }
  }

  void shoot(Vector2 direction) {
    try {
      final gameRef = game as dynamic;
      final projectile = Projectile(
        position: position.clone(),
        velocity: direction * _projectileSpeed,
        damage: character.attackDamage,
        isFromPlayer: false,
      );
      gameRef.world.add(projectile);
    } catch (e) {
      // Ignorar si no se puede agregar
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Wall) {
      final rect = toRect();
      final otherRect = other.toRect();
      final intersection = rect.intersect(otherRect);

      if (intersection.width < intersection.height) {
        if (rect.left < otherRect.left) {
          position.x = otherRect.left - width / 2;
        } else {
          position.x = otherRect.right + width / 2;
        }
      } else {
        if (rect.top < otherRect.top) {
          position.y = otherRect.top - height / 2;
        } else {
          position.y = otherRect.bottom + height / 2;
        }
      }
    }
  }

  Player? _findPlayer() {
    try {
      final gameRef = game as dynamic;
      return gameRef.player as Player?;
    } catch (e) {
      return null;
    }
  }

  void takeDamage(double damage) {
    healthNotifier.value -= damage;
    _isChasing = true; // Alertar al guardia
    if (healthNotifier.value <= 0) {
      removeFromParent();
    }
  }
}
