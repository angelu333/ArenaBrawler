import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:juego_happy/game/arena_brawler_game.dart';
import 'package:juego_happy/models/character_model.dart';
import 'package:juego_happy/models/level_data.dart';
import 'package:juego_happy/services/game_data_service.dart';

class FlameGameWrapper extends StatefulWidget {
  final CharacterModel selectedCharacter;
  final int levelId;

  const FlameGameWrapper({
    super.key,
    required this.selectedCharacter,
    this.levelId = 1,
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
    game = ArenaBrawlerGame(
      playerCharacter: widget.selectedCharacter,
      levelId: widget.levelId,
    );
  }

  void _exitGame({bool won = false}) async {
    // Dar monedas según el nivel
    // Dar monedas según el nivel
    int coins = 50;
    if (widget.levelId == 2) coins = 100;
    if (widget.levelId == 3) coins = 500;

    await _gameData.addCoins(coins);

    // Si ganó, desbloquear siguiente nivel
    if (won) {
      await _gameData.completeLevel(widget.levelId, 3, 1000, 60.0);
      // Desbloquear siguiente(s) nivel(es)
      final nextLevels = LevelData.connections[widget.levelId] ?? [];
      for (final nextLevel in nextLevels) {
        await _gameData.unlockLevel(nextLevel);
      }
    }

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
          'SpecialButton': (context, game) {
            return SpecialButton(game: game as ArenaBrawlerGame);
          },
          'GameOver': (context, game) {
            return GameOverOverlay(
              game: game as ArenaBrawlerGame,
              onRestart: () {
                Navigator.of(context).pop();
              },
              onExit: () => _exitGame(won: false),
            );
          },
          'Victory': (context, game) {
            return VictoryOverlay(
              game: game as ArenaBrawlerGame,
              levelId: widget.levelId,
              onContinue: () => _exitGame(won: true),
            );
          },
        },
        initialActiveOverlays: const ['Hud'],
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
              color: Colors.black.withAlpha((0.5 * 255).round()),
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
              backgroundColor: Colors.black.withAlpha((0.5 * 255).round()),
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
    return Positioned(
      right: 40,
      bottom: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(24),
          backgroundColor: Colors.red.withAlpha((0.8 * 255).round()),
        ),
        onPressed: () {
          game.player.shoot();
        },
        child: const Icon(Icons.bolt, size: 40, color: Colors.white),
      ),
    );
  }
}

class SpecialButton extends StatefulWidget {
  final ArenaBrawlerGame game;

  const SpecialButton({super.key, required this.game});

  @override
  State<SpecialButton> createState() => _SpecialButtonState();
}

class _SpecialButtonState extends State<SpecialButton> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 40,
      bottom: 130,
      child: StreamBuilder(
        stream: Stream.periodic(const Duration(milliseconds: 100)),
        builder: (context, snapshot) {
          final canUse = widget.game.player.canUseSpecial;
          final cooldown = widget.game.player.specialCooldownRemaining;
          final character = widget.game.playerCharacter;

          return Stack(
            alignment: Alignment.center,
            children: [
              // Botón
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(24),
                  backgroundColor: canUse
                      ? Colors.purple.withAlpha((0.8 * 255).round())
                      : Colors.grey.withAlpha((0.5 * 255).round()),
                ),
                onPressed: canUse
                    ? () {
                        widget.game.player.useSpecialAbility();
                        setState(() {});
                      }
                    : null,
                child: Icon(
                  _getAbilityIcon(character.specialAbility),
                  size: 40,
                  color: Colors.white,
                ),
              ),
              // Cooldown overlay
              if (!canUse)
                Positioned.fill(
                  child: Center(
                    child: Text(
                      cooldown.toStringAsFixed(0),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  IconData _getAbilityIcon(SpecialAbility ability) {
    switch (ability) {
      case SpecialAbility.rapidFire:
        return Icons.flash_on;
      case SpecialAbility.superShot:
        return Icons.whatshot;
      case SpecialAbility.heal:
        return Icons.favorite;
      case SpecialAbility.speedBoost:
        return Icons.speed;
      case SpecialAbility.shield:
        return Icons.shield;
      case SpecialAbility.multiShot:
        return Icons.grain;
    }
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
      color: Colors.black.withAlpha((0.8 * 255).round()),
      child: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Texto GAME OVER estilo arcade/pixelado
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha((0.3 * 255).round()),
                      border: Border.all(color: Colors.red, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withAlpha((0.5 * 255).round()),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: const Text(
                        'GAME OVER',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 48,
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
                  ),

                  const SizedBox(height: 30),

                  // Estadísticas
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha((0.5 * 255).round()),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Personaje: ${game.playerCharacter.name}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '+ 50 MONEDAS',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 20,
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Botones
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: _ArcadeButton(
                            text: 'REINTENTAR',
                            color: Colors.green,
                            onPressed: onRestart,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Flexible(
                          child: _ArcadeButton(
                            text: 'SALIR',
                            color: Colors.red,
                            onPressed: onExit,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha((0.5 * 255).round()),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class VictoryOverlay extends StatelessWidget {
  final ArenaBrawlerGame game;
  final int levelId;
  final VoidCallback onContinue;

  const VictoryOverlay({
    super.key,
    required this.game,
    required this.levelId,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    int coins = 50;
    if (levelId == 2) coins = 100;
    if (levelId == 3) coins = 500;

    return Container(
      color: Colors.black.withAlpha((0.8 * 255).round()),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Texto VICTORIA estilo arcade
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha((0.3 * 255).round()),
                  border: Border.all(color: Colors.green, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withAlpha((0.5 * 255).round()),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Text(
                  '¡VICTORIA!',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: Colors.green,
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
                  color: Colors.black.withAlpha((0.5 * 255).round()),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      'Nivel $levelId Completado',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
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
                    Text(
                      '+ $coins MONEDAS',
                      style: const TextStyle(
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

              // Botón continuar
              _ArcadeButton(
                text: 'CONTINUAR',
                color: Colors.green,
                onPressed: onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
