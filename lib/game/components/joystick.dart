import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class DirectionJoystick extends JoystickComponent {
  DirectionJoystick()
      : super(
          knob: CircleComponent(
            radius: 30,
            paint: BasicPalette.blue.withAlpha(200).paint(),
          ),
          background: CircleComponent(
            radius: 70,
            paint: BasicPalette.blue.withAlpha(100).paint(),
          ),
          margin: const EdgeInsets.only(left: 40, bottom: 40),
        );
}
