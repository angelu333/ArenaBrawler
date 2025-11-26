import 'package:flutter/material.dart';
import 'package:juego_happy/data/character_data.dart';
import 'package:juego_happy/models/character_model.dart';
import 'package:juego_happy/screens/level_map_screen.dart';
import 'package:juego_happy/services/game_data_service.dart';
import 'package:juego_happy/widgets/character_unlocked_splash.dart';

class CharacterSelectionScreen extends StatefulWidget {
  final bool selectOnly;

  const CharacterSelectionScreen({super.key, this.selectOnly = false});

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

  Future<void> _purchaseCharacter(CharacterModel character) async {
    // Obtener monedas actuales
    final currentCoins = await _gameData.getCoins();
    
    // Verificar si tiene suficientes monedas
    if (currentCoins < character.price) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Necesitas ${character.price - currentCoins} monedas más',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    
    // Descontar monedas
    await _gameData.saveCoins(currentCoins - character.price);
    
    // Agregar personaje a owned usando el método existente
    await _gameData.addOwnedCharacter(character.id);
    
    // Mostrar splash screen premium
    if (mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CharacterUnlockedSplash(character: character),
      );
    }
    
    // Recargar datos
    await _loadData();
    
    // Seleccionar el personaje recién comprado
    _selectCharacter(character.id);
  }

  void _startGame() {
    if (widget.selectOnly) {
      // Solo seleccionar y volver
      Navigator.pop(context);
    } else {
      // Ir al mapa de niveles
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LevelMapScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final allCharacters = CharacterData.availableCharacters;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tu Personaje'),
        backgroundColor: const Color(0xFF1A0F2E),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0F2E), // Deep dark purple
              Color(0xFF0D1B2A), // Dark navy blue
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 columnas para mejor visualización
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: allCharacters.length,
                itemBuilder: (context, index) {
                  final character = allCharacters[index];
                  final isOwned = _ownedCharacters.contains(character.id);
                  final isSelected = character.id == _selectedCharacterId;

                  return _CharacterCard(
                    character: character,
                    isOwned: isOwned,
                    isSelected: isSelected,
                    onTap: () {
                      if (isOwned) {
                        _selectCharacter(character.id);
                      } else {
                        _purchaseCharacter(character);
                      }
                    },
                  );
                },
              ),
            ),

            // Botón para iniciar juego o confirmar selección
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow, size: 32),
                      const SizedBox(width: 12),
                      Text(
                        widget.selectOnly ? 'CONFIRMAR' : 'INICIAR BATALLA',
                        style: const TextStyle(
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
  final bool isOwned;
  final bool isSelected;
  final VoidCallback onTap;

  const _CharacterCard({
    required this.character,
    required this.isOwned,
    required this.isSelected,
    required this.onTap,
  });
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

  Future<void> _purchaseCharacter(CharacterModel character) async {
    // Obtener monedas actuales
    final currentCoins = await _gameData.getCoins();
    
    // Verificar si tiene suficientes monedas
    if (currentCoins < character.price) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Necesitas ${character.price - currentCoins} monedas más',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    
    // Descontar monedas
    await _gameData.saveCoins(currentCoins - character.price);
    
    // Agregar personaje a owned usando el método existente
    await _gameData.addOwnedCharacter(character.id);
    
    // Mostrar splash screen premium
    if (mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CharacterUnlockedSplash(character: character),
      );
    }
    
    // Recargar datos
    await _loadData();
    
    // Seleccionar el personaje recién comprado
    _selectCharacter(character.id);
  }

  void _startGame() {
    if (widget.selectOnly) {
      // Solo seleccionar y volver
      Navigator.pop(context);
    } else {
      // Ir al mapa de niveles
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LevelMapScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final allCharacters = CharacterData.availableCharacters;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tu Personaje'),
        backgroundColor: const Color(0xFF1A0F2E),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0F2E), // Deep dark purple
              Color(0xFF0D1B2A), // Dark navy blue
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 columnas para mejor visualización
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: allCharacters.length,
                itemBuilder: (context, index) {
                  final character = allCharacters[index];
                  final isOwned = _ownedCharacters.contains(character.id);
                  final isSelected = character.id == _selectedCharacterId;

                  return _CharacterCard(
                    character: character,
                    isOwned: isOwned,
                    isSelected: isSelected,
                    onTap: () {
                      if (isOwned) {
                        _selectCharacter(character.id);
                      } else {
                        _purchaseCharacter(character);
                      }
                    },
                  );
                },
              ),
            ),

            // Botón para iniciar juego o confirmar selección
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow, size: 32),
                      const SizedBox(width: 12),
                      Text(
                        widget.selectOnly ? 'CONFIRMAR' : 'INICIAR BATALLA',
                        style: const TextStyle(
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
  final bool isOwned;
  final bool isSelected;
  final VoidCallback onTap;

  const _CharacterCard({
    required this.character,
    required this.isOwned,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected 
                    ? Colors.yellow 
                    : isOwned 
                        ? Colors.cyan.withAlpha((0.5 * 255).round())
                        : Colors.white.withAlpha((0.2 * 255).round()),
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
                  : isOwned
                      ? [
                          BoxShadow(
                            color: Colors.cyan.withAlpha((0.3 * 255).round()),
                            blurRadius: 10,
                            spreadRadius: 1,
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
                    child: ColorFiltered(
                      colorFilter: isOwned
                          ? const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.multiply,
                            )
                          : const ColorFilter.matrix([
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0, 0, 0, 1, 0,
                            ]),
                      child: Opacity(
                        opacity: isOwned ? 1.0 : 0.5,
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
                  ),
                ),

                // Nombre
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    character.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isOwned ? Colors.white : Colors.white.withAlpha((0.6 * 255).round()),
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatIcon(
                            icon: Icons.favorite,
                            value: character.baseHealth.toInt().toString(),
                            color: Colors.red,
                            isLocked: !isOwned,
                          ),
                          _StatIcon(
                            icon: Icons.flash_on,
                            value: character.baseSpeed.toInt().toString(),
                            color: Colors.blue,
                            isLocked: !isOwned,
                          ),
                          _StatIcon(
                            icon: Icons.whatshot,
                            value: character.attackDamage.toInt().toString(),
                            color: Colors.orange,
                            isLocked: !isOwned,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Habilidad especial
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.purple.withAlpha((0.3 * 255).round()),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          character.specialAbilityName,
                          style: TextStyle(
                            color: isOwned ? Colors.white : Colors.white.withAlpha((0.5 * 255).round()),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
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
          
          // Lock overlay for unowned characters
          if (!isOwned)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((0.5 * 255).round()),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.3 * 255).round()),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.monetization_on, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${character.price}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatIcon extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final bool isLocked;

  const _StatIcon({
    required this.icon,
    required this.value,
    required this.color,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLocked ? 0.5 : 1.0,
      child: Column(
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
      ),
    );
  }
}
