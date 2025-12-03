import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:juego_happy/data/character_data.dart';
import 'package:juego_happy/models/character_model.dart';
import 'package:juego_happy/screens/level_map_screen.dart';
import 'package:juego_happy/services/game_data_service.dart';

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
    if (mounted) {
      setState(() {
        _ownedCharacters = owned;
        _selectedCharacterId = selected;
        _isLoading = false;
      });
    }
  }

  void _selectCharacter(String characterId) {
    setState(() {
      _selectedCharacterId = characterId;
    });
    _gameData.saveSelectedCharacter(characterId);
  }

  void _startGame() {
    if (widget.selectOnly) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LevelMapScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6366F1),
          ),
        ),
      );
    }

    final ownedCharactersList = CharacterData.availableCharacters
        .where((c) => _ownedCharacters.contains(c.id))
        .toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'ELIGE TU HÉROE',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A), // Deep Slate Blue
            ),
          ),
          // Ambient Glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withOpacity(0.2), // Indigo
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.4),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEC4899).withOpacity(0.2), // Pink
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEC4899).withOpacity(0.4),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 280,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                    ),
                    itemCount: ownedCharactersList.length,
                    itemBuilder: (context, index) {
                      final character = ownedCharactersList[index];
                      final isSelected = character.id == _selectedCharacterId;

                      return _HeroCard(
                        character: character,
                        isSelected: isSelected,
                        onTap: () => _selectCharacter(character.id),
                      );
                    },
                  ),
                ),

                // Action Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
                  child: Container(
                    width: double.infinity,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _startGame,
                        borderRadius: BorderRadius.circular(32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_arrow_rounded,
                                color: Colors.white, size: 32),
                            const SizedBox(width: 12),
                            Text(
                              widget.selectOnly ? 'CONFIRMAR SELECCIÓN' : 'INICIAR BATALLA',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final CharacterModel character;
  final bool isSelected;
  final VoidCallback onTap;

  const _HeroCard({
    required this.character,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: isSelected ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFFEC4899) : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFEC4899).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Character Image
                  Expanded(
                    flex: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/${character.profileAsset}',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white54,
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Name
                  Text(
                    character.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Special Ability Tag
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF6366F1).withOpacity(0.5),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        character.specialAbilityName.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFE0E7FF),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Stats
                  _StatBar(
                    label: 'HP',
                    value: character.baseHealth / 200, // Normalize assuming max ~200
                    color: const Color(0xFFEF4444), // Red
                    icon: Icons.favorite_rounded,
                  ),
                  const SizedBox(height: 6),
                  _StatBar(
                    label: 'SPD',
                    value: character.baseSpeed / 200, // Normalize
                    color: const Color(0xFF3B82F6), // Blue
                    icon: Icons.bolt_rounded,
                  ),
                  const SizedBox(height: 6),
                  _StatBar(
                    label: 'ATK',
                    value: character.attackDamage / 100, // Normalize
                    color: const Color(0xFFF59E0B), // Amber
                    icon: Icons.whatshot_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  const _StatBar({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color.withOpacity(0.8)),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
