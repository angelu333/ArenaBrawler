import 'package:flutter/material.dart';
import 'package:juego_happy/models/coin_package.dart';
import 'package:juego_happy/services/game_data_service.dart';

class CoinStoreScreen extends StatefulWidget {
  const CoinStoreScreen({super.key});

  @override
  State<CoinStoreScreen> createState() => _CoinStoreScreenState();
}

class _CoinStoreScreenState extends State<CoinStoreScreen> {
  final GameDataService _gameData = GameDataService();
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
      ),
    );

    if (confirmed == true) {
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
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
    );
  }
}

class _CoinPackageCard extends StatelessWidget {
  final CoinPackage package;
  final VoidCallback onPurchase;

  const _CoinPackageCard({
    required this.package,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPurchase,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              package.color.withOpacity(0.8),
              package.color.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: package.color.withOpacity(0.3),
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
                color: Colors.white.withOpacity(0.2),
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
        ),
      ),
    );
  }
}
