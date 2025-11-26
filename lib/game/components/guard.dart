import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:juego_happy/game/components/health_bar.dart';
import 'package:juego_happy/game/components/player.dart';
import 'package:juego_happy/game/components/projectile.dart';
import 'package:juego_happy/game/components/wall.dart';
import 'package:juego_happy/game/components/maze_wall.dart';
import 'package:juego_happy/models/character_model.dart';

/// Guardia que patrulla y persigue al jugador si lo ve
class Guard extends SpriteAnimationGroupComponent<PlayerState>
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

  // Variables para detección de movimiento
  Vector2 _lastPosition = Vector2.zero();
  bool _isMoving = false;

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

    // Cargar animaciones
    if (character.spriteAsset.contains('spritesheet')) {
      await _loadAnimations();
    } else {
      // Fallback para imagen estática
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

    size = Vector2.all(110.0);
    anchor = Anchor.center;

    add(CircleHitbox(radius: 20));
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
  void render(Canvas canvas) {
    super.render(canvas);
    // Vision cone hidden as requested
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Buscar al jugador en el mundo
    final player = _findPlayer();
    if (player == null || !player.isMounted) {
      _patrol(dt);
    } else {
      final distanceToPlayer = (player.position - position).length;

      // Verificar si ve al jugador o está en rango de persecución
      if (_canSeePlayer(player) ||
          (_isChasing && distanceToPlayer < _chaseRange)) {
        _isChasing = true;
        _chasePlayer(player, dt);
      } else {
        _isChasing = false;
        _patrol(dt);
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
    // Usar un hitbox más pequeño para la resolución de colisiones
    // El sprite es 110x110, pero el cuerpo físico es mucho más pequeño (40x40)
    final hitboxSize = Vector2.all(40);
    final rect = Rect.fromCenter(
      center: position.toOffset(),
      width: hitboxSize.x,
      height: hitboxSize.y,
    );
    final otherRect = wall.toRect();

    if (!rect.overlaps(otherRect)) return;

    final intersection = rect.intersect(otherRect);

    if (intersection.width < intersection.height) {
      if (rect.center.dx < otherRect.center.dx) {
        position.x = otherRect.left - hitboxSize.x / 2 - 1;
      } else {
        position.x = otherRect.right + hitboxSize.x / 2 + 1;
      }
    } else {
      if (rect.center.dy < otherRect.center.dy) {
        position.y = otherRect.top - hitboxSize.y / 2 - 1;
      } else {
        position.y = otherRect.bottom + hitboxSize.y / 2 + 1;
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
