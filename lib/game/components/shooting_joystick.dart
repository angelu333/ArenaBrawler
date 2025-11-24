import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class ShootingJoystick extends JoystickComponent {
  ShootingJoystick()
      : super(
          knob: CircleComponent(
            radius: 30,
            paint: BasicPalette.red.withAlpha(200).paint(),
          ),
          background: CircleComponent(
            radius: 70,
            paint: BasicPalette.red.withAlpha(100).paint(),
          ),
          margin: const EdgeInsets.only(right: 40, bottom: 40),
          anchor: Anchor.bottomRight, // Anclar a la derecha
        );
}
