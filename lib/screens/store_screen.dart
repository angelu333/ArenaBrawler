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

class _StoreScreenState extends State<StoreScreen>
    with SingleTickerProviderStateMixin {
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
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Imagen del personaje (Recortada)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/${character.profileAsset}',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Info del personaje
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      character.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      character.description,
                      style: TextStyle(
                        color: Colors.white.withAlpha((0.8 * 255).round()),
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Stats
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _StatChip(
                          icon: Icons.favorite,
                          value: character.baseHealth.toInt().toString(),
                          color: Colors.red,
                        ),
                        _StatChip(
                          icon: Icons.flash_on,
                          value: character.baseSpeed.toInt().toString(),
                          color: Colors.blue,
                        ),
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

              const SizedBox(width: 8),

              // Botón de compra
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isOwned)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 20),
                    )
                  else if (character.price == 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'FREE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: canAfford ? onPurchase : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        backgroundColor:
                            canAfford ? Colors.amber.shade700 : Colors.grey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.monetization_on, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${character.price}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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
