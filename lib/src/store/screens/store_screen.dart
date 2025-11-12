import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juego_happy/data/character_data.dart';
import 'package:juego_happy/models/character_model.dart';
import 'package:juego_happy/models/user_profile.dart';
import 'package:juego_happy/services/user_data_service.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  late final String _uid;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Handle user not being logged in, maybe pop back to login screen
      Navigator.of(context).pop();
      return;
    }
    _uid = currentUser.uid;
  }

  void _handlePurchase(CharacterModel character) async {
    final result = await UserDataService.purchaseCharacter(_uid, character);
    if (mounted) {
      String message;
      switch (result) {
        case PurchaseResult.success:
          message = '¡${character.name} comprado!';
          break;
        case PurchaseResult.insufficientFunds:
          message = 'Oro insuficiente.';
          break;
        case PurchaseResult.error:
          message = 'Ocurrió un error durante la compra.';
          break;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfile>(
      stream: UserDataService.getProfileStream(_uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('No se encontró el perfil de usuario.')),
          );
        }

        final userProfile = snapshot.data!;
        final ownedIds = userProfile.ownedCharacters;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Personajes / Tienda'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Chip(
                  avatar: const Icon(Icons.monetization_on, color: Colors.amber),
                  label: Text(
                    userProfile.gold.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          body: ListView.builder(
            itemCount: CharacterData.availableCharacters.length,
            itemBuilder: (context, index) {
              final character = CharacterData.availableCharacters[index];
              final isOwned = ownedIds.contains(character.id);

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Placeholder for sprite
                      Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, size: 40),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(character.name, style: Theme.of(context).textTheme.titleLarge),
                            Text('HP: ${character.baseHealth}, ATK: ${character.attackDamage}'),
                          ],
                        ),
                      ),
                      if (isOwned)
                        ElevatedButton(
                          onPressed: () {
                            // Logic for selecting a character can be added here
                          },
                          child: const Text('SELECCIONAR'),
                        )
                      else
                        ElevatedButton(
                          onPressed: () => _handlePurchase(character),
                          child: Text('COMPRAR (${character.price})'),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
