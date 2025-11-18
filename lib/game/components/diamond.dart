import 'dart:async';
import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:juego_happy/game/arena_brawler_game.dart';
import 'package:juego_happy/game/components/player.dart';

/// Diamante que el jugador debe recoger
class Diamond extends CircleComponent
    with HasGameReference<ArenaBrawlerGame>, CollisionCallbacks {
  bool isCollected = false;

  Diamond({required Vector2 position})
      : super(
          position: position,
          radius: 20,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (isCollected) return;

    // Dibujar diamante brillante
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.cyan.shade200,
          Colors.blue.shade400,
          Colors.blue.shade700,
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));

    canvas.drawCircle(Offset.zero, radius, paint);

    // Borde brillante
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(Offset.zero, radius, borderPaint);

    // Estrella interior
    _drawStar(canvas, 6);
  }

  void _drawStar(Canvas canvas, int points) {
    final paint = Paint()
      ..color = Colors.white.withAlpha((0.8 * 255).round())
      ..style = PaintingStyle.fill;

    final path = Path();
    final angle = (3.14159 * 2) / points;

    for (int i = 0; i < points; i++) {
      final x = radius * 0.5 * (i % 2 == 0 ? 1 : 0.5) * math.cos(i * angle);
      final y = radius * 0.5 * (i % 2 == 0 ? 1 : 0.5) * math.sin(i * angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Player && !isCollected) {
      collect();
    }
  }

  void collect() {
    isCollected = true;
    removeFromParent();
    // Notificar al juego que se recogió el diamante
    try {
      final gameRef = game as dynamic;
      if (gameRef.onDiamondCollected != null) {
        gameRef.onDiamondCollected();
      }
    } catch (e) {
      // Ignorar si no es Level2Game
    }
  }
}
