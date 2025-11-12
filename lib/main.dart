import 'package:flutter/material.dart';
import 'package:juego_happy/test_game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Happy Game - Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TestGameScreen(), // Pantalla de prueba directa
    );
  }
}
