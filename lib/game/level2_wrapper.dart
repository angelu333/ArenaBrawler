import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:juego_happy/game/level2_game.dart';
import 'package:juego_happy/models/character_model.dart';
import 'package:juego_happy/services/game_data_service.dart';

class Level2Wrapper extends StatefulWidget {
  final CharacterModel selectedCharacter;

  const Level2Wrapper({
    super.key,
    required this.selectedCharacter,
  });

  @override
  State<Level2Wrapper> createState() => _Level2WrapperState();
}

class _Level2WrapperState extends State<Level2Wrapper> {
  late final Level2Game game;
  final GameDataService _gameData = GameDataService();

  @override
  void initState() {
    super.initState();
    game = Level2Game(playerCharacter: widget.selectedCharacter);
  }

  void _exitGame({bool won = false}) async {
    await _gameData.addCoins(75); // Recompensa del nivel 2
    
    // Si ganó, desbloquear siguiente nivel
    if (won) {
      await _gameData.completeLevel(2, 3, 1000, 60.0);
      // Desbloquear nivel 3 (Jefe Final)
      await _gameData.unlockLevel(3);
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
            return _buildHud();
          },
          'AttackButton': (context, game) {
            return _buildAttackButton();
          },
          'DiamondCollected': (context, game) {
            return _buildDiamondMessage();
          },
          'NeedDiamond': (context, game) {
            return _buildNeedDiamondMessage();
          },
          'Victory': (context, game) {
            return _buildVictoryScreen();
          },
          'GameOver': (context, game) {
            return _buildGameOverScreen();
          },
        },
        initialActiveOverlays: const ['Hud', 'AttackButton'],
      ),
    );
  }

  Widget _buildHud() {
    return Positioned(
      top: 40,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                Row(
                  children: [
                    Icon(
                      game.hasDiamond ? Icons.diamond : Icons.diamond_outlined,
                      color: game.hasDiamond ? Colors.cyan : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      game.hasDiamond ? 'Diamante obtenido' : 'Busca el diamante',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _showPauseMenu,
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

  Widget _buildAttackButton() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(40.0),
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
      ),
    );
  }

  Widget _buildDiamondMessage() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.cyan.withAlpha((0.9 * 255).round()),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.diamond, size: 64, color: Colors.white),
            SizedBox(height: 16),
            Text(
              '¡DIAMANTE OBTENIDO!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Ahora ve a la salida',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeedDiamondMessage() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.withAlpha((0.9 * 255).round()),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          '¡Necesitas el diamante primero!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildVictoryScreen() {
    return Container(
  color: Colors.black.withAlpha((0.8 * 255).round()),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¡VICTORIA!',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              '¡Robaste el diamante!',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '+ 75 MONEDAS',
              style: TextStyle(
                fontSize: 24,
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _exitGame(won: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
              ),
              child: const Text(
                'CONTINUAR',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverScreen() {
    return Container(
  color: Colors.black.withAlpha((0.8 * 255).round()),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _exitGame(won: false),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
              ),
              child: const Text(
                'SALIR',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
