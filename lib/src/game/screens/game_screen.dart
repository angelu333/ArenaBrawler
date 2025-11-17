import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juego_happy/data/character_data.dart';
import 'package:juego_happy/models/character_model.dart';
import 'package:juego_happy/models/user_profile.dart';
import 'package:juego_happy/services/user_data_service.dart';
import 'package:juego_happy/game/flame_game_wrapper.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final String _uid;
  CharacterModel? _selectedCharacter;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Navigator.of(context).pop();
      return;
    }
    _uid = currentUser.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tu Personaje'),
      ),
      body: StreamBuilder<UserProfile>(
        stream: UserDataService.getProfileStream(_uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No se encontró el perfil de usuario.'));
          }

          final userProfile = snapshot.data!;
          final ownedCharacters = CharacterData.availableCharacters
              .where((char) => userProfile.ownedCharacters.contains(char.id))
              .toList();

          return Column(
            children: [
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: ownedCharacters.length,
                  itemBuilder: (context, index) {
                    final character = ownedCharacters[index];
                    final isSelected = _selectedCharacter?.id == character.id;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCharacter = character;
                        });
                      },
                      child: Card(
                        elevation: isSelected ? 8 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(Icons.person, size: 50),
                            ),
                            const SizedBox(height: 8),
                            Text(character.name, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
                            Text('HP: ${character.baseHealth}'),
                            Text('ATK: ${character.attackDamage}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: _selectedCharacter == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FlameGameWrapper(
                                selectedCharacter: _selectedCharacter!,
                              ),
                            ),
                          );
                        },
                  child: const Text('INICIAR DUELO'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
