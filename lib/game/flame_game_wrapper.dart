import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:juego_happy/game/arena_brawler_game.dart';
import 'package:juego_happy/models/character_model.dart';

class FlameGameWrapper extends StatelessWidget {
  final CharacterModel selectedCharacter;

  const FlameGameWrapper({
    super.key,
    required this.selectedCharacter,
  });

  @override
  Widget build(BuildContext context) {
    final game = ArenaBrawlerGame(playerCharacter: selectedCharacter);

    return Scaffold(
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          'Hud': (context, game) {
            return Hud(game: game as ArenaBrawlerGame);
          },
          'AttackButton': (context, game) {
            return AttackButton(game: game as ArenaBrawlerGame);
          },
        },
        initialActiveOverlays: const ['Hud', 'AttackButton'],
      ),
    );
  }
}

class Hud extends StatelessWidget {
  final ArenaBrawlerGame game;

  const Hud({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Player: ${game.playerCharacter.name}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          ValueListenableBuilder<double>(
            valueListenable: game.player.healthNotifier,
            builder: (context, health, child) {
              return Text(
                'HP: ${health.toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AttackButton extends StatelessWidget {
  final ArenaBrawlerGame game;

  const AttackButton({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(24),
          ),
          onPressed: () {
            game.player.shoot();
          },
          child: const Icon(Icons.bolt, size: 40),
        ),
      ),
    );
  }
}
