import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Singleton pattern
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  /// Checks if a player name already exists in the database.
  Future<bool> isNameTaken(String name) async {
    try {
      final response = await _client
          .from('player_scores') // Using a descriptive table name
          .select('name')
          .eq('name', name)
          .maybeSingle();
      return response != null;
    } catch (e) {
      print('Error checking name availability: $e');
      // In case of error, we might want to allow retry or assume not taken depending on policy
      // For now, let's return false but log it.
      return false; 
    }
  }

  /// Saves the player's name and score.
  /// Returns true if successful, false if name is taken or error.
  Future<bool> savePlayerScore(String name, int score) async {
    try {
      // Double check name uniqueness just in case, though DB constraint should also handle it
      final taken = await isNameTaken(name);
      if (taken) {
        return false;
      }

      await _client.from('player_scores').insert({
        'name': name,
        'score': score,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error saving player score: $e');
      return false;
    }
  }
}
