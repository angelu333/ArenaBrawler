import 'package:flutter/material.dart';
import 'package:juego_happy/data/character_data.dart';
import 'package:juego_happy/models/character_model.dart';
import 'package:juego_happy/screens/coin_store_screen.dart';
import 'package:juego_happy/services/game_data_service.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GameDataService _gameData = GameDataService();
  List<String> _ownedCharacters = [];
  int _coins = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final owned = await _gameData.getOwnedCharacters();
    final coins = await _gameData.getCoins();
    setState(() {
      _ownedCharacters = owned;
      _coins = coins;
      _isLoading = false;
    });
  }

  Future<void> _purchaseCharacter(CharacterModel character) async {
    if (_ownedCharacters.contains(character.id)) {
      _showMessage('Ya posees este personaje');
      return;
    }

    if (_coins < character.price) {
      _showMessage('No tienes suficientes monedas');
      return;
    }

    final success = await _gameData.purchaseCharacter(
      character.id,
      character.price,
    );

    if (success) {
      _showMessage('¡${character.name} comprado!');
      _loadData();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda'),
        backgroundColor: Colors.orange.shade900,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.person),
              text: 'Personajes',
            ),
            Tab(
              icon: Icon(Icons.monetization_on),
              text: 'Monedas',
            ),
          ],
        ),
        actions: [
          // Mostrar monedas en el AppBar
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.shade700,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '$_coins',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pestaña de Personajes
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.orange.shade900,
                  Colors.red.shade900,
                ],
              ),
            ),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 columnas para landscape
                childAspectRatio: 2.5, // Más ancho que alto
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: CharacterData.availableCharacters.length,
              itemBuilder: (context, index) {
                final character = CharacterData.availableCharacters[index];
                final isOwned = _ownedCharacters.contains(character.id);
                final canAfford = _coins >= character.price;

                return _StoreCharacterCard(
                  character: character,
                  isOwned: isOwned,
                  canAfford: canAfford,
                  onPurchase: () => _purchaseCharacter(character),
                );
              },
            ),
          ),

          // Pestaña de Monedas
          const CoinStoreScreen(),
        ],
      ),
    );
  }
}

class _StoreCharacterCard extends StatelessWidget {
  final CharacterModel character;
  final bool isOwned;
  final bool canAfford;
  final VoidCallback onPurchase;

  const _StoreCharacterCard({
    required this.character,
    required this.isOwned,
    required this.canAfford,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade800,
              Colors.blue.shade800,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Imagen del personaje
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
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

              const SizedBox(width: 16),

              // Info del personaje
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      character.description,
                      style: TextStyle(
                        color: Colors.white.withAlpha((0.8 * 255).round()),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Stats
                    Row(
                      children: [
                        _StatChip(
                          icon: Icons.favorite,
                          value: character.baseHealth.toInt().toString(),
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        _StatChip(
                          icon: Icons.flash_on,
                          value: character.baseSpeed.toInt().toString(),
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        _StatChip(
                          icon: Icons.whatshot,
                          value: character.attackDamage.toInt().toString(),
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Botón de compra
              Column(
                children: [
                  if (isOwned)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check, color: Colors.white, size: 20),
                          SizedBox(width: 4),
                          Text(
                            'POSEÍDO',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (character.price == 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'GRATIS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: canAfford ? onPurchase : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            canAfford ? Colors.amber.shade700 : Colors.grey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.monetization_on, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${character.price}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
  color: Colors.black.withAlpha((0.3 * 255).round()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
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
