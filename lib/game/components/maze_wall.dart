import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Pared con sprite para el laberinto del nivel 2
class MazeWall extends PositionComponent with CollisionCallbacks {
  final Sprite? sprite;
  final Paint _wallPaint = Paint()..color = const Color(0xFF4A4A4A); // Gris oscuro

  MazeWall({
    required Vector2 position,
    required Vector2 size,
    this.sprite,
  }) : super(
          position: position,
          size: size,
          anchor: Anchor.topLeft,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Hitbox sólido que cubre toda la pared
    add(RectangleHitbox(
      size: size,
      isSolid: true,
      collisionType: CollisionType.passive,
    ));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (sprite != null) {
      // Tiling logic: Repeat the sprite to fill the size
      final spriteW = sprite!.srcSize.x;
      final spriteH = sprite!.srcSize.y;
      
      // Evitar bucle infinito si el sprite es muy pequeño o 0
      if (spriteW <= 0 || spriteH <= 0) return;

      for (double y = 0; y < size.y; y += spriteH) {
        for (double x = 0; x < size.x; x += spriteW) {
          // Calcular espacio restante
          final w = (x + spriteW > size.x) ? size.x - x : spriteW;
          final h = (y + spriteH > size.y) ? size.y - y : spriteH;

          canvas.save();
          // Recortar el área donde vamos a dibujar este pedazo
          canvas.clipRect(Rect.fromLTWH(x, y, w, h));
          // Dibujar el sprite completo en la posición (el clip se encarga de cortar lo que sobra)
          sprite!.render(
            canvas,
            position: Vector2(x, y),
            size: Vector2(spriteW, spriteH),
          );
          canvas.restore();
        }
      }
    } else {
      // Renderizar pared sólida si no hay sprite
      canvas.drawRect(size.toRect(), _wallPaint);
      
      // Borde para que se distinga
      final borderPaint = Paint()
        ..color = const Color(0xFF2A2A2A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(size.toRect(), borderPaint);
    }
  }
}
