import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:juego_happy/game/components/player.dart';

/// Punto de salida del nivel
class ExitPoint extends RectangleComponent
    with HasGameReference<FlameGame>, CollisionCallbacks {
  final bool requiresDiamond;
  bool _playerInside = false;

  ExitPoint({
    required Vector2 position,
    required Vector2 size,
    this.requiresDiamond = false,
  }) : super(
          position: position,
          size: size,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Dibujar puerta/salida
    final paint = Paint()
      ..color = Colors.green.withAlpha((0.5 * 255).round())
      ..style = PaintingStyle.fill;

    canvas.drawRect(size.toRect(), paint);

    // Borde
    final borderPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawRect(size.toRect(), borderPaint);

    // Texto "SALIDA"
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'SALIDA',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.x - textPainter.width) / 2,
        (size.y - textPainter.height) / 2,
      ),
    );
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Player) {
      _playerInside = true;
      _checkWinCondition();
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);

    if (other is Player) {
      _playerInside = false;
    }
  }

  void _checkWinCondition() {
    if (_playerInside) {
      // Verificar si tiene el diamante si es requerido
      try {
        final gameRef = game as dynamic;
        if (gameRef.onPlayerReachedExit != null) {
          gameRef.onPlayerReachedExit();
        }
      } catch (e) {
        // Ignorar si no es Level2Game
      }
    }
  }
}
