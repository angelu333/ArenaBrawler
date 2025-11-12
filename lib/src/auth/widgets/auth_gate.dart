import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:juego_happy/src/auth/screens/login_screen.dart';
import 'package:juego_happy/src/lobby/screens/lobby_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const LobbyScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
