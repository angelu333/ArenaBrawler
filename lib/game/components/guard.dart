import 'dart:async';
import 'dart:math';
import 'dart:ui'; // Para lerpDouble
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart'; // Importar efectos
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:juego_happy/game/components/health_bar.dart';
import 'package:juego_happy/game/components/player.dart';
import 'package:juego_happy/game/components/projectile.dart';
import 'package:juego_happy/game/components/wall.dart';
import 'package:juego_happy/game/components/maze_wall.dart';
import 'package:juego_happy/models/character_model.dart';

/// Guardia que patrulla y persigue al jugador si lo ve
class Guard extends SpriteComponent
    with HasGameReference<FlameGame>, CollisionCallbacks {
  final CharacterModel character;
  final List<Vector2> patrolPoints;
  late final ValueNotifier<double> healthNotifier;
  late double maxSpeed;

  static const double _projectileSpeed = 250.0;
  static const double _visionRange = 350.0;
  static const double _visionAngle = 90.0; // Grados - más amplio
  static const double _chaseRange = 500.0; // Rango de persecución más amplio
  double _lastShotTime = 0.0;
  final double _shootCooldown = 2.5; // Más lento (antes 1.8)

  int _currentPatrolIndex = 0;
  bool _isChasing = false;
  Vector2 _facingDirection = Vector2(0, 1);

  // Animación de movimiento
  double _wobbleTimer = 0.0;
  final double _wobbleSpeed = 10.0; // Un poco más lento que el jugador
  final double _wobbleAmount = 0.08;

  Guard({
    required this.character,
    required this.patrolPoints,
    required Vector2 position,
  }) : super(position: position) {
    maxSpeed = character.baseSpeed * 8; // Más lento (antes 12)
    // Menos vida para que sean fáciles de matar (60% de la vida base)
    healthNotifier = ValueNotifier(character.baseHealth * 0.6);
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

    final distanceToPlayer = (player.position - position).length;

    // Verificar si ve al jugador o está en rango de persecución
    if (_canSeePlayer(player) || (_isChasing && distanceToPlayer < _chaseRange)) {
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
    var angleDiff = (angleToPlayer - facingAngle).abs();
    
    // Normalizar el ángulo para manejar el wrap-around
    if (angleDiff > pi) {
      angleDiff = 2 * pi - angleDiff;
    }

    const visionAngleRad = _visionAngle * (pi / 180) / 2;

    return angleDiff < visionAngleRad;
  }

  void _patrol(double dt) {
    if (patrolPoints.isEmpty) return;

    // Animar movimiento
    _wobbleTimer += dt * _wobbleSpeed;
    angle = sin(_wobbleTimer) * _wobbleAmount;

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
    // Animar movimiento rápido
    _wobbleTimer += dt * _wobbleSpeed * 1.5;
    angle = sin(_wobbleTimer) * _wobbleAmount;

    final toPlayer = player.position - position;
    final distance = toPlayer.length;
    final direction = toPlayer.normalized();
    _facingDirection = direction;

    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;

    if (distance > 180) {
      // Perseguir mientras dispara
      position.add(direction * maxSpeed * dt);
      
      // Disparar mientras persigue
      if (currentTime - _lastShotTime > _shootCooldown) {
        shoot(direction);
        _lastShotTime = currentTime;
      }
    } else {
      // Mantener distancia y disparar
      if (distance < 120) {
        // Retroceder un poco
        position.add(direction * -maxSpeed * 0.5 * dt);
      }
      
      // Disparar
      if (currentTime - _lastShotTime > _shootCooldown) {
        shoot(direction);
        _lastShotTime = currentTime;
      }
    }
  }

  void shoot(Vector2 direction) {
    try {
      // Efecto de retroceso
      add(MoveEffect.by(
        -direction * 5,
        EffectController(duration: 0.05, alternate: true),
      ));

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
    if (other is Wall || other is MazeWall) {
      _handleWallCollision(other);
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Wall || other is MazeWall) {
      _handleWallCollision(other);
    }
  }

  void _handleWallCollision(PositionComponent wall) {
    final rect = toRect();
    final otherRect = wall.toRect();
    
    if (!rect.overlaps(otherRect)) return;
    
    final intersection = rect.intersect(otherRect);

    if (intersection.width < intersection.height) {
      if (rect.center.dx < otherRect.center.dx) {
        position.x = otherRect.left - width / 2 - 1;
      } else {
        position.x = otherRect.right + width / 2 + 1;
      }
    } else {
      if (rect.center.dy < otherRect.center.dy) {
        position.y = otherRect.top - height / 2 - 1;
      } else {
        position.y = otherRect.bottom + height / 2 + 1;
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
    
    // Flash rojo
    add(ColorEffect(
      Colors.red,
      EffectController(duration: 0.2, alternate: true),
    ));

    if (healthNotifier.value <= 0) {
      _die();
    }
  }

  void _die() {
    // Animación de muerte
    add(ScaleEffect.to(
      Vector2.zero(),
      EffectController(duration: 0.5, curve: Curves.easeIn),
      onComplete: () {
        try {
          final gameRef = game as dynamic;
          gameRef.onEnemyDeath(this); // Notificar muerte para victoria
        } catch (e) {
          // Ignorar
        }
        removeFromParent();
      },
    ));
    add(RotateEffect.by(
      pi * 2,
      EffectController(duration: 0.5),
    ));
  }
}
