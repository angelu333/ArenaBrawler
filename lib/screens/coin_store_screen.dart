import 'package:flutter/material.dart';
import 'package:juego_happy/models/coin_package.dart';
import 'package:juego_happy/services/game_data_service.dart';
<<<<<<< HEAD
=======
import 'package:juego_happy/services/audio_service.dart';
>>>>>>> master

class CoinStoreScreen extends StatefulWidget {
  const CoinStoreScreen({super.key});

  @override
  State<CoinStoreScreen> createState() => _CoinStoreScreenState();
}

class _CoinStoreScreenState extends State<CoinStoreScreen> {
  final GameDataService _gameData = GameDataService();
<<<<<<< HEAD
  int _coins = 0;

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    final coins = await _gameData.getCoins();
    setState(() {
      _coins = coins;
    });
  }

  Future<void> _purchasePackage(CoinPackage package) async {
    // Mostrar diálogo de confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(package.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(package.description),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  '${package.coins} monedas',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  '\$${package.price} MXN',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Comprar'),
          ),
        ],
=======
  final AudioService _audioService = AudioService();

  Future<void> _purchasePackage(CoinPackage package) async {
    // Mostrar diálogo de confirmación personalizado
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.shade700, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity( 0.8),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                package.name.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'GameFont',
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                package.description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/coins/coin_icon.png',
                    width: 32,
                    height: 32,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.monetization_on, color: Colors.amber, size: 32),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${package.coins}',
                    style: const TextStyle(
                      fontFamily: 'GameFont',
                      fontSize: 32,
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white54,
                      ),
                      child: const Text('CANCELAR'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        '\$${package.price}',
                        style: const TextStyle(
                          fontFamily: 'GameFont',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
>>>>>>> master
      ),
    );

    if (confirmed == true) {
<<<<<<< HEAD
      // Simular compra (en producción aquí iría la integración de pagos)
      await _gameData.addCoins(package.coins);
      _loadCoins();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Compraste ${package.coins} monedas!'),
            backgroundColor: Colors.green,
          ),
        );
=======
      await _gameData.addCoins(package.coins);
      _audioService.playClickSound(); // Sonido de compra (o monedas cayendo)

      if (mounted) {
        // Forzar actualización de la pantalla padre (StoreScreen) si es necesario
        // Pero como StoreScreen lee GameDataService en _loadData, necesitamos notificarle.
        // Por simplicidad, asumimos que el usuario verá el cambio al volver o podemos usar un callback si fuera necesario.
        // Sin embargo, StoreScreen no se entera automáticamente. 
        // Idealmente usaríamos un Provider o ValueNotifier.
        // Por ahora, mostraremos un SnackBar bonito.
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  '¡+${package.coins} MONEDAS OBTENIDAS!',
                  style: const TextStyle(fontFamily: 'GameFont'),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        
        // Hack para actualizar el contador en StoreScreen:
        // Como no tenemos un estado global simple aquí, el usuario verá el cambio si cambia de tab o si recargamos.
        // Pero StoreScreen llama a _loadData en initState.
        // Una opción es que StoreScreen pase un callback, pero no quiero cambiar la firma del constructor si no es necesario.
        // Dejémoslo así por ahora, el usuario verá el cambio visualmente en el diálogo y luego en el HUD si se actualiza.
>>>>>>> master
      }
    }
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda de Monedas'),
        backgroundColor: Colors.amber.shade900,
        foregroundColor: Colors.white,
        actions: [
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.amber.shade900,
              Colors.orange.shade900,
            ],
          ),
        ),
        child: Column(
          children: [
            // Banner informativo
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withAlpha((0.3 * 255).round()),
                  width: 2,
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Compra monedas para desbloquear nuevos personajes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de paquetes
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: CoinPackage.packages.length,
                itemBuilder: (context, index) {
                  final package = CoinPackage.packages[index];
                  return _CoinPackageCard(
                    package: package,
                    onPurchase: () => _purchasePackage(package),
                  );
                },
              ),
            ),
          ],
        ),
      ),
=======
    // Ya no usamos Scaffold, solo el contenido para el TabBarView
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 140, 16, 16), // Padding top para el AppBar
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: CoinPackage.packages.length,
      itemBuilder: (context, index) {
        final package = CoinPackage.packages[index];
        return _CoinPackageCard(
          package: package,
          onPurchase: () => _purchasePackage(package),
        );
      },
>>>>>>> master
    );
  }
}

<<<<<<< HEAD
class _CoinPackageCard extends StatelessWidget {
=======
class _CoinPackageCard extends StatefulWidget {
>>>>>>> master
  final CoinPackage package;
  final VoidCallback onPurchase;

  const _CoinPackageCard({
    required this.package,
    required this.onPurchase,
  });

  @override
<<<<<<< HEAD
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPurchase,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              package.color.withAlpha((0.8 * 255).round()),
              package.color.withAlpha((0.6 * 255).round()),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withAlpha((0.3 * 255).round()),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: package.color.withAlpha((0.3 * 255).round()),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen o Icono
            Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.2 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: package.imagePath != null
                  ? ClipOval(
                      child: Image.asset(
                        'assets/images/${package.imagePath}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            package.icon,
                            size: 48,
                            color: Colors.white,
                          );
                        },
                      ),
                    )
                  : Icon(
                      package.icon,
                      size: 48,
                      color: Colors.white,
                    ),
            ),

            const SizedBox(height: 12),

            // Nombre
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                package.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
              ),
            ),

            const SizedBox(height: 8),

            // Cantidad de monedas
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.shade700,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on, size: 20, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    '${package.coins}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Precio
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '\$${package.price} MXN',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
=======
  State<_CoinPackageCard> createState() => _CoinPackageCardState();
}

class _CoinPackageCardState extends State<_CoinPackageCard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPurchase();
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2C3E50), // Dark blue-grey
                const Color(0xFF1A1A1A), // Almost black
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.package.color.withOpacity( 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.package.color.withOpacity( 0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Glow effect
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.package.color.withOpacity( 0.2),
                    boxShadow: [
                      BoxShadow(
                        color: widget.package.color.withOpacity( 0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icono
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: widget.package.imagePath != null
                            ? Image.asset(
                                'assets/images/${widget.package.imagePath}',
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  widget.package.icon,
                                  size: 48,
                                  color: widget.package.color,
                                ),
                              )
                            : Icon(
                                widget.package.icon,
                                size: 48,
                                color: widget.package.color,
                              ),
                      ),
                    ),
                    
                    // Info
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            widget.package.name.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'GameFont',
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.package.coins} MONEDAS',
                            style: TextStyle(
                              color: Colors.amber.shade400,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.shade700,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity( 0.3),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Text(
                              '\$${widget.package.price}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'GameFont',
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
>>>>>>> master
        ),
      ),
    );
  }
}
