import 'package:flutter/material.dart';

class ArenaData {
  final String? spritePath;
  final Color? color;
  final List<Rect> obstacles;

  ArenaData({
    this.spritePath,
    this.color,
    required this.obstacles,
  });
}
