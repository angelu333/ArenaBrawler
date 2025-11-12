import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String username;
  final int gold;
  final List<String> ownedCharacters;

  UserProfile({
    required this.uid,
    required this.username,
    this.gold = 1000,
    List<String>? ownedCharacters,
  }) : ownedCharacters = ownedCharacters ?? ['default'];

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      username: json['username'] as String,
      gold: json['gold'] as int,
      ownedCharacters: List<String>.from(json['ownedCharacters'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'gold': gold,
      'ownedCharacters': ownedCharacters,
    };
  }
}
