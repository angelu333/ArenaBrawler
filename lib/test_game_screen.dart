import 'package:flutter/material.dart';
import 'package:juego_happy/data/character_data.dart';
import 'package:juego_happy/game/flame_game_wrapper.dart';

class TestGameScreen extends StatelessWidget {
  const TestGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usar el primer personaje (Aventurero Novato) para pruebas
    final testCharacter = CharacterData.availableCharacters[0];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba del Juego'),
        backgroundColor: Colors.black87,
      ),
      body: FlameGameWrapper(selectedCharacter: testCharacter),
    );
  }
}
