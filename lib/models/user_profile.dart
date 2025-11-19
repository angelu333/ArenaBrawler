class UserProfile {
  final String userId;
  final String uid; // Para compatibilidad con Firebase
  final String displayName;
  final String username; // Para compatibilidad con Firebase
  final int coins;
  final int gold; // Para compatibilidad con Firebase
  final int gems;
  final List<String> ownedCharacters;
  final String selectedCharacter;
  final Map<int, LevelProgress> levelProgress;

  const UserProfile({
    required this.userId,
    required this.displayName,
    String? uid,
    String? username,
    int? coins,
    int? gold,
    this.gems = 50,
    this.ownedCharacters = const ['default'],
    this.selectedCharacter = 'default',
    this.levelProgress = const {},
  })  : uid = uid ?? userId,
        username = username ?? displayName,
        coins = coins ?? gold ?? 1000,
        gold = gold ?? coins ?? 1000;

  UserProfile copyWith({
    String? userId,
    String? displayName,
    int? coins,
    int? gems,
    List<String>? ownedCharacters,
    String? selectedCharacter,
    Map<int, LevelProgress>? levelProgress,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      ownedCharacters: ownedCharacters ?? this.ownedCharacters,
      selectedCharacter: selectedCharacter ?? this.selectedCharacter,
      levelProgress: levelProgress ?? this.levelProgress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'uid': uid,
      'displayName': displayName,
      'username': username,
      'coins': coins,
      'gold': gold,
      'gems': gems,
      'ownedCharacters': ownedCharacters,
      'selectedCharacter': selectedCharacter,
      'levelProgress': levelProgress.map((key, value) => MapEntry(key.toString(), value.toJson())),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final userId = json['userId'] as String? ?? json['uid'] as String? ?? '';
    final displayName = json['displayName'] as String? ?? json['username'] as String? ?? '';
    final coins = json['coins'] as int? ?? json['gold'] as int? ?? 1000;
    
    return UserProfile(
      userId: userId,
      displayName: displayName,
      coins: coins,
      gems: json['gems'] as int? ?? 50,
      ownedCharacters: (json['ownedCharacters'] as List<dynamic>?)?.cast<String>() ?? ['default'],
      selectedCharacter: json['selectedCharacter'] as String? ?? 'default',
      levelProgress: {},
    );
  }
}

class LevelProgress {
  final int levelId;
  final bool isCompleted;
  final bool isUnlocked;
  final int stars;
  final int bestScore;
  final double bestTime;

  const LevelProgress({
    required this.levelId,
    this.isCompleted = false,
    this.isUnlocked = false,
    this.stars = 0,
    this.bestScore = 0,
    this.bestTime = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'levelId': levelId,
      'isCompleted': isCompleted,
      'isUnlocked': isUnlocked,
      'stars': stars,
      'bestScore': bestScore,
      'bestTime': bestTime,
    };
  }
}
