import 'package:flutter/material.dart';
import 'package:juego_happy/data/character_data.dart';
import 'package:juego_happy/game/flame_game_wrapper.dart';
import 'package:juego_happy/models/character_model.dart';
import 'package:juego_happy/services/game_data_service.dart';

class CharacterSelectionScreen extends StatefulWidget {
  const CharacterSelectionScreen({super.key});

  @override
  State<CharacterSelectionScreen> createState() =>
      _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen> {
  final GameDataService _gameData = GameDataService();
  List<String> _ownedCharacters = [];
  String _selectedCharacterId = 'default';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final owned = await _gameData.getOwnedCharacters();
    final selected = await _gameData.getSelectedCharacter();
    setState(() {
      _ownedCharacters = owned;
      _selectedCharacterId = selected;
      _isLoading = false;
    });
  }

  void _selectCharacter(String characterId) {
    setState(() {
      _selectedCharacterId = characterId;
    });
    _gameData.saveSelectedCharacter(characterId);
  }

  void _startGame() {
    final character = CharacterData.availableCharacters.firstWhere(
      (c) => c.id == _selectedCharacterId,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlameGameWrapper(selectedCharacter: character),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final ownedCharactersList = CharacterData.availableCharacters
        .where((c) => _ownedCharacters.contains(c.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tu Personaje'),
        backgroundColor: Colors.purple.shade900,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade900,
              Colors.blue.shade900,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: ownedCharactersList.length,
                itemBuilder: (context, index) {
                  final character = ownedCharactersList[index];
                  final isSelected = character.id == _selectedCharacterId;

                  return _CharacterCard(
                    character: character,
                    isSelected: isSelected,
                    onTap: () => _selectCharacter(character.id),
                  );
                },
              ),
            ),

            // Botón para iniciar juego
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow, size: 32),
                      SizedBox(width: 12),
                      Text(
                        'INICIAR BATALLA',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final CharacterModel character;
  final bool isSelected;
  final VoidCallback onTap;

  const _CharacterCard({
    required this.character,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.yellow : Colors.white.withAlpha((0.3 * 255).round()),
            width: isSelected ? 4 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.yellow.withAlpha((0.5 * 255).round()),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen del personaje
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/images/${character.spriteAsset}',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ),

            // Nombre
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                character.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 8),

            // Stats
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatIcon(
                    icon: Icons.favorite,
                    value: character.baseHealth.toInt().toString(),
                    color: Colors.red,
                  ),
                  _StatIcon(
                    icon: Icons.flash_on,
                    value: character.baseSpeed.toInt().toString(),
                    color: Colors.blue,
                  ),
                  _StatIcon(
                    icon: Icons.whatshot,
                    value: character.attackDamage.toInt().toString(),
                    color: Colors.orange,
                  ),
                ],
              ),
            ),

            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: const BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'SELECCIONADO',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatIcon extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _StatIcon({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
