import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Wall extends RectangleComponent with CollisionCallbacks {
  Wall({
    required Vector2 position,
    required Vector2 size,
  }) : super(
          position: position,
          size: size,
          paint: Paint()
            ..color = const Color(0xFF8B4513) // Color café para paredes
            ..style = PaintingStyle.fill,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(isSolid: true));
    
    // Agregar borde para que se vea mejor
    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..color = const Color(0xFF654321)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      ),
    );
  }
}
