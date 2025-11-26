import 'dart:async';
import 'dart:math';
import 'dart:ui'; // Para lerpDouble
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart'; // Importar efectos
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Necesario para Colors
import 'package:juego_happy/game/components/aim_indicator.dart';
import 'package:juego_happy/game/components/health_bar.dart';
import 'package:juego_happy/game/components/projectile.dart';
import 'package:juego_happy/game/components/wall.dart';
import 'package:juego_happy/game/components/maze_wall.dart';
import 'package:juego_happy/models/character_model.dart';

class Player extends SpriteAnimationGroupComponent<PlayerState>
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

  // Variables para detección de movimiento
  Vector2 _lastPosition = Vector2.zero();
  bool _isMoving = false;
  bool _isAttacking = false;
  double _attackTimer = 0.0;
  static const double _attackDuration = 0.3; // Duración de la animación de ataque

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
    
    // Cargar animaciones si es el Archer (o si el asset es un spritesheet)
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
    
    // Asumiendo spritesheet de 4 filas (Down, Left, Right, Up) y 4 columnas
    // Ajustar tamaño de frame según la imagen. Si es 110x110 aprox por frame?
    // El usuario no especificó tamaño, pero generamos un spritesheet.
    // Vamos a asumir que la imagen se divide equitativamente.
    // Usar configuración del personaje
    final frames = character.framesPerAnimation;
    final stepTime = character.stepTime;

    final frameWidth = image.width / frames;
    final frameHeight = image.height / 4; // Asumimos 4 direcciones siempre
    final textureSize = Vector2(frameWidth, frameHeight);

    final downAnimation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: frames,
        stepTime: stepTime,
        textureSize: textureSize,
        texturePosition: Vector2(0, 0),
      ),
    );

    final leftAnimation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: frames,
        stepTime: stepTime,
        textureSize: textureSize,
        texturePosition: Vector2(0, frameHeight),
      ),
    );

    final rightAnimation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: frames,
        stepTime: stepTime,
        textureSize: textureSize,
        texturePosition: Vector2(0, frameHeight * 2),
      ),
    );

    final upAnimation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: frames,
        stepTime: stepTime,
        textureSize: textureSize,
        texturePosition: Vector2(0, frameHeight * 3),
      ),
    );

    // Crear mapa local mutable
    final anims = {
      PlayerState.idle: downAnimation,
      PlayerState.runDown: downAnimation,
      PlayerState.runLeft: leftAnimation,
      PlayerState.runRight: rightAnimation,
      PlayerState.runUp: upAnimation,
    };

    // Cargar animaciones de ataque si existen
    print('Checking for attack animation for ${character.id}...');
    
    try {
      final attackAsset = character.spriteAsset.replaceAll('walk_spritesheet.png', 'attack_spritesheet.png');
      print('Generated attackAsset path: "$attackAsset"');
      
      // Intentar cargar la imagen
      final attackImage = await game.images.load(attackAsset);
      print('Attack image loaded! Size: ${attackImage.width}x${attackImage.height}');
      
      final attackFrameWidth = attackImage.width / 4;
      final attackFrameHeight = attackImage.height / 4;
      final attackTextureSize = Vector2(attackFrameWidth, attackFrameHeight);

      anims[PlayerState.attackDown] = SpriteAnimation.fromFrameData(
        attackImage,
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: _attackDuration / 4,
          textureSize: attackTextureSize,
          texturePosition: Vector2(0, 0),
          loop: false,
        ),
      );

      anims[PlayerState.attackLeft] = SpriteAnimation.fromFrameData(
        attackImage,
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: _attackDuration / 4,
          textureSize: attackTextureSize,
          texturePosition: Vector2(0, attackFrameHeight),
          loop: false,
        ),
      );

      anims[PlayerState.attackRight] = SpriteAnimation.fromFrameData(
        attackImage,
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: _attackDuration / 4,
          textureSize: attackTextureSize,
          texturePosition: Vector2(0, attackFrameHeight * 2),
          loop: false,
        ),
      );

      anims[PlayerState.attackUp] = SpriteAnimation.fromFrameData(
        attackImage,
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: _attackDuration / 4,
          textureSize: attackTextureSize,
          texturePosition: Vector2(0, attackFrameHeight * 3),
          loop: false,
        ),
      );
      
      print('Attack animations added to local map. Keys: ${anims.keys.toList()}');
      
    } catch (e) {
      print('Note: Could not load attack animation: $e');
    }

    // Asignar el mapa completo al componente
    animations = anims;
    current = PlayerState.idle;
  }

  @override
  void onRemove() {
    healthNotifier.dispose();
    super.onRemove();
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
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
      // Horizontal collision
      if (rect.center.dx < otherRect.center.dx) {
        position.x = otherRect.left - width / 2 - 1;
      } else {
        position.x = otherRect.right + width / 2 + 1;
      }
    } else {
      // Vertical collision
      if (rect.center.dy < otherRect.center.dy) {
        position.y = otherRect.top - height / 2 - 1;
      } else {
        position.y = otherRect.bottom + height / 2 + 1;
      }
    }
  }

  void setMoveDirection(Vector2 direction) {
    // Solo actualiza la dirección de movimiento para la física
    // La dirección de disparo se maneja por separado
  }

  void setAimDirection(Vector2 direction) {
    if (direction.length2 > 0) {
      _lastMoveDirection = direction.normalized();
      _updateAimIndicator();
    } else {
      hideAimIndicator();
    }
  }

  void stopAiming() {
    hideAimIndicator();
    shoot();
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
    
    // Efecto visual de daño (Flash rojo)
    add(ColorEffect(
      Colors.red,
      EffectController(duration: 0.2, alternate: true),
    ));

    if (healthNotifier.value <= 0) {
      healthNotifier.value = 0;
      _die();
    }
  }

  void _die() {
    // Animación de muerte dramática
    // 1. Girar
    add(RotateEffect.by(
      pi * 4, // 2 vueltas
      EffectController(duration: 1.0, curve: Curves.easeOut),
    ));
    // 2. Encogerse
    add(ScaleEffect.to(
      Vector2.zero(),
      EffectController(duration: 1.0, curve: Curves.easeIn),
      onComplete: () {
        // Notificar muerte al juego y remover
        try {
          final gameRef = game as dynamic;
          gameRef.onPlayerDeath();
        } catch (e) {
          // Ignorar si no tiene el método
        }
        removeFromParent();
      },
    ));
  }

  void useSpecialAbility() {
    if (!canUseSpecial) return;

    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    _lastSpecialUseTime = currentTime;
    _specialActive = true;
    _specialActiveTime = 0.0;

    // Efecto visual de habilidad
    add(ScaleEffect.by(
      Vector2.all(1.2),
      EffectController(duration: 0.2, alternate: true),
    ));

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
        add(ColorEffect(Colors.green, EffectController(duration: 0.5, alternate: true)));
        _specialActive = false;
        break;
      case SpecialAbility.speedBoost:
        // Velocidad: aumenta velocidad por 6 segundos
        maxSpeed = baseMaxSpeed * 2;
        break;
      case SpecialAbility.shield:
        // Escudo: inmune por 4 segundos
        add(ColorEffect(Colors.blue, EffectController(duration: 4.0)));
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

    if (_isAttacking) {
      _attackTimer -= dt;
      if (_attackTimer <= 0) {
        _isAttacking = false;
      } else {
        // Mientras ataca, mantenemos el estado de ataque y no actualizamos movimiento
        return; 
      }
    }

    // Detectar movimiento comparando posición
    final displacement = position - _lastPosition;
    _isMoving = displacement.length2 > 0.001; // Umbral pequeño
    
    if (_isMoving) {
      // Determinar dirección predominante
      if (displacement.x.abs() > displacement.y.abs()) {
        // Movimiento horizontal
        if (displacement.x > 0) {
          current = PlayerState.runRight;
        } else {
          current = PlayerState.runLeft;
        }
      } else {
        // Movimiento vertical
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
  
  // Método helper para animar movimiento (ya no se usa wobble, pero se mantiene por compatibilidad si alguien lo llama)
  void animateMovement(double dt, bool isMoving) {
    // Deprecated: ahora usamos SpriteAnimationGroupComponent
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

    // Efecto de retroceso (Recoil)
    final recoilDir = -_lastMoveDirection.normalized();
    add(MoveEffect.by(
      recoilDir * 5, 
      EffectController(duration: 0.05, alternate: true),
    ));

    final projectile = Projectile(
      position: position.clone(),
      velocity: _lastMoveDirection.normalized() * _projectileSpeed,
      damage: character.attackDamage,
      isFromPlayer: true,
    );

    game.world.add(projectile);

    // Activar animación de ataque
    _isAttacking = true;
    _attackTimer = _attackDuration;
    
    PlayerState targetState = PlayerState.idle;

    // Determinar dirección del ataque basado en _lastMoveDirection
    if (_lastMoveDirection.x.abs() > _lastMoveDirection.y.abs()) {
      if (_lastMoveDirection.x > 0) {
        targetState = PlayerState.attackRight;
      } else {
        targetState = PlayerState.attackLeft;
      }
    } else {
      if (_lastMoveDirection.y > 0) {
        targetState = PlayerState.attackDown;
      } else {
        targetState = PlayerState.attackUp;
      }
    }

    // Solo cambiar el estado si la animación existe
    if (animations?.containsKey(targetState) ?? false) {
      current = targetState;
      // Reiniciar el ticker de la animación actual para que empiece desde el frame 0
      animationTicker?.reset();
    } else {
      // Si no hay animación de ataque, no cambiamos el estado visual pero mantenemos el flag _isAttacking
      // para evitar cambios de movimiento durante el "tiempo de ataque"
    }
  }
}

enum PlayerState {
  idle,
  runUp,
  runDown,
  runLeft,
  runRight,
  attackUp,
  attackDown,
  attackLeft,
  attackRight,
}
