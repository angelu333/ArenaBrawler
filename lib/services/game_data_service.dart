import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para manejar datos del juego localmente
class GameDataService {
  static const String _coinsKey = 'player_coins';
  static const String _ownedCharactersKey = 'owned_characters';
  static const String _selectedCharacterKey = 'selected_character';

  // Obtener monedas del jugador
  Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinsKey) ?? 1000; // Empezar con 1000 monedas
  }

  // Guardar monedas
  Future<void> saveCoins(int coins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinsKey, coins);
  }

  // Obtener personajes que posee el jugador
  Future<List<String>> getOwnedCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    final owned = prefs.getStringList(_ownedCharactersKey);
    return owned ?? ['default']; // Siempre tiene el personaje default
  }

  // Agregar un personaje comprado
  Future<void> addOwnedCharacter(String characterId) async {
    final prefs = await SharedPreferences.getInstance();
    final owned = await getOwnedCharacters();
    if (!owned.contains(characterId)) {
      owned.add(characterId);
      await prefs.setStringList(_ownedCharactersKey, owned);
    }
  }

  // Obtener personaje seleccionado actualmente
  Future<String> getSelectedCharacter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedCharacterKey) ?? 'default';
  }

  // Guardar personaje seleccionado
  Future<void> saveSelectedCharacter(String characterId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedCharacterKey, characterId);
  }

  // Comprar un personaje
  Future<bool> purchaseCharacter(String characterId, int price) async {
    final coins = await getCoins();
    if (coins >= price) {
      await saveCoins(coins - price);
      await addOwnedCharacter(characterId);
      return true;
    }
    return false;
  }

  // Agregar monedas (por ganar partidas, etc)
  Future<void> addCoins(int amount) async {
    final coins = await getCoins();
    await saveCoins(coins + amount);
  }
}
