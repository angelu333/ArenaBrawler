<<<<<<< HEAD
=======
import 'dart:math';
import 'dart:ui';
>>>>>>> master
import 'package:flutter/material.dart';
import 'package:juego_happy/data/character_data.dart';
import 'package:juego_happy/models/character_model.dart';
import 'package:juego_happy/screens/coin_store_screen.dart';
import 'package:juego_happy/services/game_data_service.dart';
<<<<<<< HEAD
=======
import 'package:juego_happy/services/audio_service.dart';
>>>>>>> master

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GameDataService _gameData = GameDataService();
<<<<<<< HEAD
=======
  final AudioService _audioService = AudioService();
>>>>>>> master
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
<<<<<<< HEAD
      _showMessage('Ya posees este personaje');
=======
      _showMessage('¡Ya tienes este héroe!', isError: false);
>>>>>>> master
      return;
    }

    if (_coins < character.price) {
<<<<<<< HEAD
      _showMessage('No tienes suficientes monedas');
=======
      _showMessage('Monedas insuficientes', isError: true);
      _audioService.playClickSound(); // Sonido de error si tuviéramos
>>>>>>> master
      return;
    }

    final success = await _gameData.purchaseCharacter(
      character.id,
      character.price,
    );

    if (success) {
<<<<<<< HEAD
      _showMessage('¡${character.name} comprado!');
=======
      _audioService.playClickSound(); // Sonido de compra exitosa
      _showMessage('¡${character.name} reclutado!', isError: false);
>>>>>>> master
      _loadData();
    }
  }

<<<<<<< HEAD
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
=======
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'GameFont',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isError ? Colors.red.shade900 : Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
>>>>>>> master
    );
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
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
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400, // Responsive width
                childAspectRatio: 1.8, // Taller cards to prevent overflow
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
              Container(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Column(
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
                            Flexible(
                              child: Text(
                                '${character.price}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
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
=======
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'MERCADO DE HÉROES',
          style: TextStyle(
            fontFamily: 'GameFont',
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.amber,
            shadows: [
              Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4)
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          _CoinDisplay(coins: _coins),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity( 0.5),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white24),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.amber.shade700,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity( 0.4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(
                fontFamily: 'GameFont',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              tabs: const [
                Tab(text: 'HÉROES'),
                Tab(text: 'TESOROS'),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Color(0xFF2C3E50), // Azul oscuro grisáceo
              Color(0xFF000000), // Negro
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.amber))
            : TabBarView(
                controller: _tabController,
                children: [
                  // Pestaña Héroes
                  _buildHeroesGrid(),
                  // Pestaña Monedas (Placeholder mejorado)
                  const CoinStoreScreen(),
                ],
              ),
      ),
    );
  }

  Widget _buildHeroesGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 140, 16, 16), // Padding top para el AppBar
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columnas para mejor visualización
        childAspectRatio: 0.75, // Más alto que ancho
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: CharacterData.availableCharacters.length,
      itemBuilder: (context, index) {
        final character = CharacterData.availableCharacters[index];
        final isOwned = _ownedCharacters.contains(character.id);
        final canAfford = _coins >= character.price;

        return _HeroCard(
          character: character,
          isOwned: isOwned,
          canAfford: canAfford,
          onPurchase: () => _purchaseCharacter(character),
        );
      },
    );
  }
}

class _CoinDisplay extends StatelessWidget {
  final int coins;

  const _CoinDisplay({required this.coins});
>>>>>>> master

  @override
  Widget build(BuildContext context) {
    return Container(
<<<<<<< HEAD
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
=======
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity( 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade700, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity( 0.2),
            blurRadius: 8,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/coins/coin_icon.png',
            width: 24,
            height: 24,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.monetization_on, color: Colors.amber, size: 24),
          ),
          const SizedBox(width: 8),
          Text(
            '$coins',
            style: const TextStyle(
              fontFamily: 'GameFont',
              color: Colors.white,
              fontSize: 18,
>>>>>>> master
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
<<<<<<< HEAD
=======

class _HeroCard extends StatefulWidget {
  final CharacterModel character;
  final bool isOwned;
  final bool canAfford;
  final VoidCallback onPurchase;

  const _HeroCard({
    required this.character,
    required this.isOwned,
    required this.canAfford,
    required this.onPurchase,
  });

  @override
  State<_HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<_HeroCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRare = widget.character.price > 1000; // Ejemplo simple de rareza

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        if (!widget.isOwned) widget.onPurchase();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2C3E50),
                const Color(0xFF1A1A1A),
              ],
            ),
            border: Border.all(
              color: widget.isOwned
                  ? Colors.green.shade400
                  : (isRare ? Colors.amber.shade700 : Colors.blueGrey.shade400),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity( 0.5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
              if (widget.isOwned)
                BoxShadow(
                  color: Colors.green.withOpacity( 0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Fondo de brillo sutil
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isRare ? Colors.amber : Colors.blue)
                          .withOpacity( 0.1),
                    ),
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Imagen del personaje
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          'assets/images/${widget.character.profileAsset}',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white.withOpacity( 0.5),
                          ),
                        ),
                      ),
                    ),

                    // Info
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity( 0.4),
                          border: const Border(
                            top: BorderSide(color: Colors.white10),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.character.name.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'GameFont',
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            // Stats mini
                            Row(
                              children: [
                                _StatIcon(Icons.favorite, Colors.red,
                                    widget.character.baseHealth.toInt()),
                                const SizedBox(width: 8),
                                _StatIcon(Icons.whatshot, Colors.orange,
                                    widget.character.attackDamage.toInt()),
                              ],
                            ),

                            // Precio / Estado
                            if (widget.isOwned)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity( 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Colors.green.withOpacity( 0.5)),
                                ),
                                child: const Text(
                                  'ADQUIRIDO',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'GameFont',
                                    color: Colors.greenAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: widget.canAfford
                                        ? [Colors.amber.shade700, Colors.amber.shade900]
                                        : [Colors.grey.shade700, Colors.grey.shade800],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    if (widget.canAfford)
                                      BoxShadow(
                                        color: Colors.amber.withOpacity( 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (widget.character.price > 0) ...[
                                      Image.asset(
                                        'assets/images/coins/coin_icon.png',
                                        width: 16,
                                        height: 16,
                                        errorBuilder: (_, __, ___) => const Icon(
                                            Icons.monetization_on,
                                            size: 16,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      widget.character.price == 0
                                          ? 'GRATIS'
                                          : '${widget.character.price}',
                                      style: TextStyle(
                                        fontFamily: 'GameFont',
                                        color: widget.canAfford
                                            ? Colors.white
                                            : Colors.white54,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        shadows: const [
                                          Shadow(
                                            color: Colors.black,
                                            offset: Offset(1, 1),
                                            blurRadius: 2,
                                          )
                                        ],
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int value;

  const _StatIcon(this.icon, this.color, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 2),
        Text(
          '$value',
          style: TextStyle(
            color: Colors.white.withOpacity( 0.7),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
>>>>>>> master
