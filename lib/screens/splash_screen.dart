import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Inicia el temporizador
    Timer(
      const Duration(seconds: 3), // Duración de 3 segundos
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Esta es tu UI de carga (la parte visual)
    return Scaffold(
      backgroundColor: Colors.indigo[900], // Fondo oscuro
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Usa tu personaje de pixel art aquí
            Image.asset('assets/images/tu_personaje.png', width: 150),
            const SizedBox(height: 20),
            const Text(
              'ARENA BRAWLER',
              style: TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
