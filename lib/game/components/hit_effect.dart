import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Efecto visual cuando un proyectil impacta
class HitEffect extends CircleComponent {
  HitEffect({required Vector2 position})
      : super(
          position: position,
          radius: 10,
          paint: Paint()
            ..color = Colors.red.withOpacity(0.8)
            ..style = PaintingStyle.fill,
        );

  double _lifetime = 0.0;
  static const double _maxLifetime = 0.3; // 0.3 segundos

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifetime += dt;

    // Expandir y desvanecer
    radius = 10 + (_lifetime / _maxLifetime) * 20;
    final opacity = (0.8 * (1 - _lifetime / _maxLifetime)).clamp(0.0, 1.0);
    paint.color = Colors.red.withOpacity(opacity);

    if (_lifetime >= _maxLifetime) {
      removeFromParent();
    }
  }
}
