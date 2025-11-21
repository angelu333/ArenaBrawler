import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:juego_happy/game/arena_brawler_game.dart';

/// Indicador visual de dirección de disparo
class AimIndicator extends PositionComponent
    with HasGameReference<ArenaBrawlerGame> {
  final Vector2 direction;
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
    final endPoint = normalizedDir * 250.0; // Línea más larga

    // 1. Dibujar línea de trayectoria (Punteada/Gradiente)
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.red.withOpacity(0.8),
          Colors.red.withOpacity(0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromPoints(Offset.zero, endPoint.toOffset()))
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Dibujar línea punteada manualmente
    double dashWidth = 10;
    double dashSpace = 10;
    double distance = 0;
    while (distance < 250) {
      final start = normalizedDir * distance;
      final end = normalizedDir * (distance + dashWidth);
      canvas.drawLine(start.toOffset(), end.toOffset(), paint);
      distance += dashWidth + dashSpace;
    }

    // 2. Dibujar Retículo (Mira) al final
    final reticlePos = normalizedDir * 250.0;
    final reticlePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(reticlePos.toOffset(), 10, reticlePaint);
    canvas.drawCircle(reticlePos.toOffset(), 2, Paint()..color = Colors.red);
  }
}
