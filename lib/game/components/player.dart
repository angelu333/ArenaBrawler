import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:juego_happy/game/components/aim_indicator.dart';
import 'package:juego_happy/game/components/health_bar.dart';
import 'package:juego_happy/game/components/projectile.dart';
import 'package:juego_happy/game/components/wall.dart';
import 'package:juego_happy/models/character_model.dart';

class Player extends SpriteComponent
    with HasGameReference<FlameGame>, CollisionCallbacks {
  final CharacterModel character;
  late double maxSpeed;
  late double baseMaxSpeed;

  late final ValueNotifier<double> healthNotifier;

  static const double _projectileSpeed = 300.0;
  double _lastShotTime = 0.0;
  Vector2 _lastMoveDirection = Vector2(0, 1); // Default shoot down
  AimIndicator? _aimIndicator;

  // Sistema de habilidad especial
  double _lastSpecialUseTime = -999.0;
  bool _specialActive = false;
  double _specialActiveTime = 0.0;

  Player({required this.character}) {
    maxSpeed = character.baseSpeed * 20;
    baseMaxSpeed = maxSpeed;
    healthNotifier = ValueNotifier(character.baseHealth);
  }

  bool get canUseSpecial {
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    return currentTime - _lastSpecialUseTime >= character.specialAbilityCooldown;
  }

  double get specialCooldownRemaining {
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final remaining = character.specialAbilityCooldown - (currentTime - _lastSpecialUseTime);
    return remaining > 0 ? remaining : 0;
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    // Cargar el sprite del personaje desde assets
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



  void setMoveDirection(Vector2 direction) {
    if (direction.length2 > 0) {
      _lastMoveDirection = direction.normalized();
      _updateAimIndicator();
    }
  }

  void _updateAimIndicator() {
    // Remover indicador anterior
    _aimIndicator?.removeFromParent();

    // Crear nuevo indicador
    _aimIndicator = AimIndicator(
      direction: _lastMoveDirection,
      position: position.clone(),
    );
    game.world.add(_aimIndicator!);
  }

  void hideAimIndicator() {
    _aimIndicator?.removeFromParent();
    _aimIndicator = null;
  }

  void takeDamage(double damage) {
    // Si tiene escudo activo, no recibe daño
    if (_specialActive && character.specialAbility == SpecialAbility.shield) {
      return;
    }

    healthNotifier.value -= damage;
    if (healthNotifier.value <= 0) {
      healthNotifier.value = 0;
      // Notificar muerte según el tipo de juego
      try {
        final gameRef = game as dynamic;
        gameRef.onPlayerDeath();
      } catch (e) {
        // Ignorar si no tiene el método
      }
      removeFromParent();
    }
  }

  void useSpecialAbility() {
    if (!canUseSpecial) return;

    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    _lastSpecialUseTime = currentTime;
    _specialActive = true;
    _specialActiveTime = 0.0;

    switch (character.specialAbility) {
      case SpecialAbility.rapidFire:
        // Ráfaga: disparo rápido por 5 segundos
        break;
      case SpecialAbility.superShot:
        // Bola de fuego: un disparo poderoso
        _shootSuperShot();
        _specialActive = false;
        break;
      case SpecialAbility.heal:
        // Curación: recupera vida
        healthNotifier.value = (healthNotifier.value + 50).clamp(0, character.baseHealth);
        _specialActive = false;
        break;
      case SpecialAbility.speedBoost:
        // Velocidad: aumenta velocidad por 6 segundos
        maxSpeed = baseMaxSpeed * 2;
        break;
      case SpecialAbility.shield:
        // Escudo: inmune por 4 segundos
        break;
      case SpecialAbility.multiShot:
        // Lluvia de flechas: dispara 5 proyectiles
        _shootMultiShot();
        _specialActive = false;
        break;
    }
  }

  void _shootSuperShot() {
    final projectile = Projectile(
      position: position.clone(),
      velocity: _lastMoveDirection.normalized() * _projectileSpeed,
      damage: character.attackDamage * 3,
      isFromPlayer: true,
      isSpecial: true,
    );
    game.world.add(projectile);
  }

  void _shootMultiShot() {
    final baseAngle = atan2(_lastMoveDirection.y, _lastMoveDirection.x);
    for (int i = -2; i <= 2; i++) {
      final angle = baseAngle + (i * 0.3);
      final direction = Vector2(cos(angle), sin(angle));
      final projectile = Projectile(
        position: position.clone(),
        velocity: direction * _projectileSpeed,
        damage: character.attackDamage * 0.8,
        isFromPlayer: true,
      );
      game.world.add(projectile);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_specialActive) {
      _specialActiveTime += dt;

      // Desactivar habilidades con duración
      switch (character.specialAbility) {
        case SpecialAbility.rapidFire:
          if (_specialActiveTime >= 5.0) {
            _specialActive = false;
          }
          break;
        case SpecialAbility.speedBoost:
          if (_specialActiveTime >= 6.0) {
            maxSpeed = baseMaxSpeed;
            _specialActive = false;
          }
          break;
        case SpecialAbility.shield:
          if (_specialActiveTime >= 4.0) {
            _specialActive = false;
          }
          break;
        default:
          break;
      }
    }
  }

  void shoot() {
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    
    // Si tiene ráfaga activa, cooldown reducido
    final cooldown = (_specialActive && character.specialAbility == SpecialAbility.rapidFire)
        ? character.attackCooldownSec * 0.3
        : character.attackCooldownSec;

    if (currentTime - _lastShotTime < cooldown) {
      return;
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
}
