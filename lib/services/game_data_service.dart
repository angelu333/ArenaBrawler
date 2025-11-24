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

  // ===== PROGRESO DE NIVELES =====

  static const String _currentLevelKey = 'current_level';

  // Obtener progreso de todos los niveles
  Future<Map<int, Map<String, dynamic>>> getLevelProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Cargar progreso guardado
    Map<int, Map<String, dynamic>> progress = {};
    
    for (int i = 1; i <= 7; i++) {
      final isCompleted = prefs.getBool('level_${i}_completed') ?? false;
      final isUnlocked = prefs.getBool('level_${i}_unlocked') ?? (i == 1);
      final stars = prefs.getInt('level_${i}_stars') ?? 0;
      final bestScore = prefs.getInt('level_${i}_score') ?? 0;
      final bestTime = prefs.getDouble('level_${i}_time') ?? 0.0;
      
      progress[i] = {
        'isCompleted': isCompleted,
        'isUnlocked': isUnlocked,
        'stars': stars,
        'bestScore': bestScore,
        'bestTime': bestTime,
      };
    }
    
    return progress;
  }

  // Guardar progreso de un nivel
  Future<void> saveLevelProgress(int levelId, {
    bool? isCompleted,
    int? stars,
    int? score,
    double? time,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (isCompleted != null) {
      await prefs.setBool('level_${levelId}_completed', isCompleted);
    }
    if (stars != null) {
      await prefs.setInt('level_${levelId}_stars', stars);
    }
    if (score != null) {
      await prefs.setInt('level_${levelId}_score', score);
    }
    if (time != null) {
      await prefs.setDouble('level_${levelId}_time', time);
    }
    
    // Siempre marcar como desbloqueado si se está guardando progreso
    await prefs.setBool('level_${levelId}_unlocked', true);
  }

  // Desbloquear nivel
  Future<void> unlockLevel(int levelId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('level_${levelId}_unlocked', true);
  }

  // Completar nivel
  Future<void> completeLevel(int levelId, int stars, int score, double time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('level_${levelId}_completed', true);
    await prefs.setInt('level_${levelId}_stars', stars);
    
    // Solo actualizar si es mejor que el anterior
    final currentScore = prefs.getInt('level_${levelId}_score') ?? 0;
    if (score > currentScore) {
      await prefs.setInt('level_${levelId}_score', score);
    }
    
    final currentTime = prefs.getDouble('level_${levelId}_time') ?? 0.0;
    if (time < currentTime || currentTime == 0.0) {
      await prefs.setDouble('level_${levelId}_time', time);
    }
  }

  // Obtener nivel actual
  Future<int> getCurrentLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentLevelKey) ?? 1;
  }

  // Guardar nivel actual
  Future<void> setCurrentLevel(int levelId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentLevelKey, levelId);
  }
}
