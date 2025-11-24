import 'package:flame/components.dart';
import 'package:flutter/material.dart';

// A generic health bar that can be used by any component with a health notifier.
class HealthBar extends PositionComponent {
  final ValueNotifier<double> healthNotifier;
  final double maxHealth;

  HealthBar({
    required this.healthNotifier,
    required this.maxHealth,
    Vector2? position,
    Vector2? size,
  }) : super(position: position, size: size ?? Vector2(50, 5));

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Calculate health percentage
    final double healthPercentage = healthNotifier.value / maxHealth;

    // Draw background bar
    canvas.drawRect(
      size.toRect(),
      Paint()..color = Colors.grey[800]!,
    );

    // Draw foreground health bar
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x * healthPercentage, size.y),
      Paint()..color = Colors.green,
    );
  }
}
