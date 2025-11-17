import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:juego_happy/game/arena_brawler_game.dart';
import 'package:juego_happy/models/character_model.dart';
import 'package:juego_happy/services/game_data_service.dart';

class FlameGameWrapper extends StatefulWidget {
  final CharacterModel selectedCharacter;

  const FlameGameWrapper({
    super.key,
    required this.selectedCharacter,
  });

  @override
  State<FlameGameWrapper> createState() => _FlameGameWrapperState();
}

class _FlameGameWrapperState extends State<FlameGameWrapper> {
  late final ArenaBrawlerGame game;
  final GameDataService _gameData = GameDataService();

  @override
  void initState() {
    super.initState();
    game = ArenaBrawlerGame(playerCharacter: widget.selectedCharacter);
  }

  void _exitGame() async {
    // Dar monedas por jugar (ejemplo: 50 monedas)
    await _gameData.addCoins(50);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showPauseMenu() {
    game.pauseEngine();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Pausa'),
        content: const Text('¿Qué deseas hacer?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              game.resumeEngine();
            },
            child: const Text('Continuar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exitGame();
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          'Hud': (context, game) {
            return Hud(
              game: game as ArenaBrawlerGame,
              onPause: _showPauseMenu,
            );
          },
          'AttackButton': (context, game) {
            return AttackButton(game: game as ArenaBrawlerGame);
          },
          'GameOver': (context, game) {
            return GameOverOverlay(
              game: game as ArenaBrawlerGame,
              onRestart: () {
                Navigator.of(context).pop();
              },
              onExit: _exitGame,
            );
          },
        },
        initialActiveOverlays: const ['Hud', 'AttackButton'],
      ),
    );
  }
}

class Hud extends StatelessWidget {
  final ArenaBrawlerGame game;
  final VoidCallback onPause;

  const Hud({
    super.key,
    required this.game,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Info del jugador
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.playerCharacter.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                ValueListenableBuilder<double>(
                  valueListenable: game.player.healthNotifier,
                  builder: (context, health, child) {
                    return Row(
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'HP: ${health.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Botón de pausa
          IconButton(
            onPressed: onPause,
            icon: const Icon(Icons.pause),
            iconSize: 32,
            color: Colors.white,
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withOpacity(0.5),
            ),
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
            backgroundColor: Colors.red.withOpacity(0.8),
          ),
          onPressed: () {
            game.player.shoot();
          },
          child: const Icon(Icons.bolt, size: 40, color: Colors.white),
        ),
      ),
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  final ArenaBrawlerGame game;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const GameOverOverlay({
    super.key,
    required this.game,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Texto GAME OVER estilo arcade/pixelado
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.3),
                border: Border.all(color: Colors.red, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Text(
                'GAME OVER',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 72,
                  fontWeight: FontWeight.w900,
                  color: Colors.red,
                  letterSpacing: 8,
                  shadows: [
                    Shadow(
                      color: Colors.white,
                      offset: Offset(2, 2),
                    ),
                    Shadow(
                      color: Colors.black,
                      offset: Offset(4, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Estadísticas
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    'Personaje: ${game.playerCharacter.name}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '+ 50 MONEDAS',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 24,
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ArcadeButton(
                  text: 'REINTENTAR',
                  color: Colors.green,
                  onPressed: onRestart,
                ),
                const SizedBox(width: 20),
                _ArcadeButton(
                  text: 'SALIR',
                  color: Colors.red,
                  onPressed: onExit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcadeButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const _ArcadeButton({
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
