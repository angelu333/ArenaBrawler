import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:juego_happy/game/arena_brawler_game.dart';

/// Indicador visual de dirección de disparo
class AimIndicator extends PositionComponent
    with HasGameReference<ArenaBrawlerGame> {
  final Vector2 direction;
  static const double lineLength = 80.0;
  static const double dotSpacing = 15.0;
  static const int dotCount = 5;

  AimIndicator({required this.direction, required Vector2 position})
      : super(position: position, size: Vector2.all(10));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (direction.length2 == 0) return;

    final normalizedDir = direction.normalized();

    // Dibujar línea principal
    final paint = Paint()
  ..color = Colors.red.withAlpha((0.8 * 255).round())
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final endPoint = normalizedDir * lineLength;
    canvas.drawLine(Offset.zero, endPoint.toOffset(), paint);

    // Dibujar puntos a lo largo de la línea
    final dotPaint = Paint()
  ..color = Colors.red.withAlpha((0.6 * 255).round())
      ..style = PaintingStyle.fill;

    for (int i = 1; i <= dotCount; i++) {
      final dotPos = normalizedDir * (dotSpacing * i);
      canvas.drawCircle(dotPos.toOffset(), 3, dotPaint);
    }

    // Dibujar punta de flecha
    final arrowPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final arrowTip = normalizedDir * lineLength;
    final arrowLeft = arrowTip +
        Vector2(-normalizedDir.y, normalizedDir.x).normalized() * 8 -
        normalizedDir * 12;
    final arrowRight = arrowTip +
        Vector2(normalizedDir.y, -normalizedDir.x).normalized() * 8 -
        normalizedDir * 12;

    final path = Path()
      ..moveTo(arrowTip.x, arrowTip.y)
      ..lineTo(arrowLeft.x, arrowLeft.y)
      ..lineTo(arrowRight.x, arrowRight.y)
      ..close();

    canvas.drawPath(path, arrowPaint);
  }
}
