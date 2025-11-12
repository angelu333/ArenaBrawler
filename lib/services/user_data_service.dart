import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:juego_happy/models/character_model.dart';
import 'package:juego_happy/models/user_profile.dart';

enum PurchaseResult { success, insufficientFunds, error }

class UserDataService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> createUserProfile(String uid, String email) async {
    // Deriving a simple username from the email
    final username = email.split('@').first;

    final userProfile = UserProfile(
      uid: uid,
      username: username,
    );

    await _db.collection('users').doc(uid).set(userProfile.toJson());
  }

  static Stream<UserProfile> getProfileStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserProfile.fromJson(snapshot.data()!);
      } else {
        throw Exception("User profile not found!");
      }
    });
  }

  static Future<PurchaseResult> purchaseCharacter(
      String uid, CharacterModel character) async {
    final userDocRef = _db.collection('users').doc(uid);

    try {
      return await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDocRef);

        if (!snapshot.exists) {
          throw Exception("User document does not exist!");
        }

        final userProfile = UserProfile.fromJson(snapshot.data()!);

        if (userProfile.gold >= character.price) {
          final newGold = userProfile.gold - character.price;
          final newOwnedCharacters = List<String>.from(userProfile.ownedCharacters)
            ..add(character.id);

          transaction.update(userDocRef, {
            'gold': newGold,
            'ownedCharacters': newOwnedCharacters,
          });
          return PurchaseResult.success;
        } else {
          return PurchaseResult.insufficientFunds;
        }
      });
    } catch (e) {
      return PurchaseResult.error;
    }
  }
}
